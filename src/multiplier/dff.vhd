library ieee;
use ieee.std_logic_1164.all;

entity dff is
    generic (
        nbit: integer := 32  -- Width of the data signal
    );
    port (
        clk : in std_logic;             -- Clock signal
        rst : in std_logic;             -- Reset signal (active high)
        clr : in std_logic;
        en  : in std_logic;
        d   : in std_logic_vector(nbit-1 downto 0);  -- Data input
        q   : out std_logic_vector(nbit-1 downto 0)  -- Data output
    );
end entity dff;

architecture Behavioral of dff is
begin
    process (clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');  -- Reset output to 0
        elsif rising_edge(clk) then
            if (clr = '1') then
                q <= (others => '0');
            elsif (en = '1') then 
                q <= d;  -- Capture data at rising clock edge
            end if;
        end if;
    end process;
end architecture Behavioral;
