library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g_g is
    port (
        g_i: in  std_logic;
        p_i: in  std_logic;
        c_i: in  std_logic;
        g_o: out std_logic
    );
end entity;

architecture behav of g_g is
begin
    g_o <= g_i or (p_i and c_i);
end behav;