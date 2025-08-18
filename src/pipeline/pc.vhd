library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    generic (
        nbit: integer := 32
    ); 
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        in_i:       in  std_logic_vector(nbit-1 downto 0);
        out_o:      out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture behav of pc is 
begin
    process (clk_i, reset_i)
         if reset_i = '1' then
            out_o <= (others => '0');
        elsif rising_edge(clk_i) then
            out_o <= in_i;
        end if
    end process;
end architecture;