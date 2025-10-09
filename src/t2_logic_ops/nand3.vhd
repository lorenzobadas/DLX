library ieee;
use ieee.std_logic_1164.all;

entity nand3 is
    port (
        a_i: in  std_logic;
        b_i: in  std_logic;
        c_i: in  std_logic;
        y_o: out std_logic
    );
end entity;

architecture behav of nand3 is
begin
    process(a_i, b_i, c_i)
    begin
        y_o <= not (a_i and b_i and c_i);
    end process;
end behav;
