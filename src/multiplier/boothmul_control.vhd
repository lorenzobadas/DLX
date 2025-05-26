library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity booth_pipeline_controller is
    generic (
        nbit : integer := 32  -- width of multiplier inputs
    );
    port (
        -- Clock and reset
        clk_i      : in  std_logic;
        reset_i    : in  std_logic;
        flush_i    : in  std_logic;  -- 1 if must flush internal status registers

        -- Reservation Station interface
        enable_i   : in  std_logic;  -- 1 if RS is loading something
        stall_o    : out std_logic;  -- 1 = stall RS (first stage full)

        -- CDB-Arbiter interface
        bus_grant_i       : in  std_logic;   -- 1 if granted bus access
        arbiter_request_o : out std_logic;   -- 1 if want to send data out

        -- Pipelined multiplier interface
        load_o        : out std_logic_vector((nbit/2)-3 downto 0);  -- 14 load signals for 32-bit
        mult_reset_o  : out std_logic                               -- Reset for multiplier pipeline
    );
end entity booth_pipeline_controller;

architecture behavioral of booth_pipeline_controller is

    constant n : integer := (nbit/2) - 2;  -- number of pipeline stages

    signal busy       : std_logic_vector(n-1 downto 0);
    signal busy_next  : std_logic_vector(n-1 downto 0);
    signal ready      : std_logic_vector(n-1 downto 0);
    signal mult_reset_reg : std_logic;

begin

    -- drive outputs
    load_o            <= ready;
    arbiter_request_o <= busy(n-1);
    stall_o           <= enable_i and busy(0) and not ready(0);
    mult_reset_o      <= mult_reset_reg;

    -- compute next busy‐vector (shift in “enable” at stage 0)
    busy_next_gen: process(busy, enable_i)
    begin
        busy_next(0) <= enable_i;
        for i in 1 to n-1 loop
            busy_next(i) <= busy(i-1);
        end loop;
    end process;

    -- OR-chain “ready”: a stage is ready if its next slot is empty
    -- or if that slot itself can shift out next cycle.
    comb_ctrl: process(busy, bus_grant_i)
        variable r : std_logic_vector(n-1 downto 0);
    begin
        -- last stage can shift only if bus is granted:
        r(n-1) := bus_grant_i;
        -- every other stage: either next stage is empty, or that stage is ready
        for i in n-2 downto 0 loop
            r(i) := (not busy(i+1)) or r(i+1);
        end loop;
        ready <= r;
    end process comb_ctrl;

    -- sequential: update busy[] and handle flush/reset
    seq_ctrl: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            busy           <= (others => '0');
            mult_reset_reg <= '1';
        elsif rising_edge(clk_i) then
            mult_reset_reg <= '0';
            if flush_i = '1' then
                busy           <= (others => '0');
                mult_reset_reg <= '1';
            else
                for i in 0 to n-1 loop
                    if ready(i) = '1' then
                        busy(i) <= busy_next(i);
                    end if;
                end loop;
            end if;
        end if;
    end process seq_ctrl;

end architecture behavioral;
