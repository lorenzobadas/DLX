library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g_pg is
    port (
        p_i0: in  std_logic;
        p_i1: in  std_logic;
        g_i : in  std_logic;
        c_i : in  std_logic;
        p_o : out std_logic;
        g_o : out std_logic
    );
end entity;

architecture struct of g_pg is
    component g_g is
        port (
            g_i: in  std_logic;
            p_i: in  std_logic;
            c_i: in  std_logic;
            g_o: out std_logic
        );
    end component g_g;
    
    component g_p is
        port (
            p_i0: in  std_logic;
            p_i1: in  std_logic;
            p_o : out std_logic
        );
    end component g_p;
begin
    g_inst: g_g
        port map (
            g_i => g_i,
            p_i => p_i1,
            c_i => c_i,
            g_o => g_o
        );
    p_inst: g_p
        port map(
            p_i0 => p_i0,
            p_i1 => p_i1,
            p_o  => p_o
        );
end struct;