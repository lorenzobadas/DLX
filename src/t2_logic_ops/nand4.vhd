library ieee;
use ieee.std_logic_1164.all;

entity nand4 is
    port (
        a_i: in  std_logic;
        b_i: in  std_logic;
        c_i: in  std_logic;
        d_i: in  std_logic;
        y_o: out std_logic
    );
end entity;

architecture behav of nand4 is
begin
    process(a_i, b_i, c_i, d_i)
    begin
        y_o <= not (a_i and b_i and c_i and d_i);
    end process;
end behav;
