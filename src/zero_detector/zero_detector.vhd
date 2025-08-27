library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zero_detector is
    generic (
        nbit : integer := 32
    );
    port (
        a_i : in  std_logic_vector(nbit-1 downto 0);
        zero_o : out std_logic
    );
end entity;

architecture behav of zero_detector is
begin

    zero_o <= '1' when a_i = (others => '0') else '0';
    
end architecture;
