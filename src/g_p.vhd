library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g_p is
    port (
        p_i0: in  std_logic;
        p_i1: in  std_logic;
        p_o : out std_logic
    );
end entity;

architecture behav of g_p is
begin
    p_o <= p_i0 and p_i1;
end behav;