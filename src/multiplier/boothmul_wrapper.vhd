library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity booth_multiplier_wrapper is
    generic (
        nbit : integer := 32  -- width of multiplier inputs
    );
    port (
        -- clock and reset
        clk_i      : in  std_logic;
        reset_i    : in  std_logic;
        flush_i    : in  std_logic;

        -- multiplier operands
        a_i        : in  std_logic_vector(nbit-1 downto 0);
        b_i        : in  std_logic_vector(nbit-1 downto 0);
        result_o   : out std_logic_vector((2*nbit)-1 downto 0);

        -- rs interface
        enable_i   : in  std_logic;  -- 1 if RS is loading new operation
        stall_o    : out std_logic;  -- 1 = stall RS (pipeline full)

        -- CDB
        bus_grant_i       : in  std_logic;   -- 1 if granted bus access
        arbiter_request_o : out std_logic    -- 1 if want to send data out
    );
end entity booth_multiplier_wrapper;

architecture structural of booth_multiplier_wrapper is

    component booth_pipeline_controller is
        generic (
            nbit : integer := 32
        );
        port (
            clk_i             : in  std_logic;
            reset_i           : in  std_logic;
            flush_i           : in  std_logic;
            enable_i          : in  std_logic;
            stall_o           : out std_logic;
            bus_grant_i       : in  std_logic;
            arbiter_request_o : out std_logic;
            load_o            : out std_logic_vector((nbit/2)-3 downto 0);
            mult_reset_o      : out std_logic
        );
    end component;

    component boothmul_pipelined is
        generic (
            nbit: integer := 32
        );
        port (
            a           : in  std_logic_vector(nbit-1 downto 0);
            b           : in  std_logic_vector(nbit-1 downto 0);
            res         : out std_logic_vector((2*nbit)-1 downto 0);
            en_pipeline : in  std_logic_vector((nbit/2)-2 downto 0);
            clk         : in  std_logic;
            clr         : in  std_logic_vector((nbit/2)-2 downto 0);
            rst         : in  std_logic
        );
    end component;

    signal load_signals     : std_logic_vector((nbit/2)-3 downto 0);
    signal enable_signals   : std_logic_vector((nbit/2)-2 downto 0);
    signal mult_reset       : std_logic;
    signal clear_signals    : std_logic_vector((nbit/2)-2 downto 0);

begin

    -- stage 0: controlled by enable_i (loads new operands from RS)
    -- stages 1-14: controlled by controller's load_signals
    enable_signals(0) <= enable_i;  -- stage 0: load when RS provides new data
    enable_signals((nbit/2)-2 downto 1) <= load_signals;  -- stages 1-14: controller manages
    clear_signals <= (others => '0');  

    controller_inst: booth_pipeline_controller
        generic map (
            nbit => nbit
        )
        port map (
            clk_i             => clk_i,
            reset_i           => reset_i,
            flush_i           => flush_i,
            enable_i          => enable_i,
            stall_o           => stall_o,
            bus_grant_i       => bus_grant_i,
            arbiter_request_o => arbiter_request_o,
            load_o            => load_signals,
            mult_reset_o      => mult_reset
        );

    multiplier_inst: boothmul_pipelined
        generic map (
            nbit => nbit
        )
        port map (
            a           => a_i,
            b           => b_i,
            res         => result_o,
            en_pipeline => enable_signals,
            clk         => clk_i,
            clr         => clear_signals,
            rst         => mult_reset
        );

end architecture structural;