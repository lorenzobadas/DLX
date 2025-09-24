library ieee;
use ieee.std_logic_1164.all;

entity mux3to1 is
    generic(
        nbit: integer := 32
    );
    port(
        in0_i:  in  std_logic_vector(nbit-1 downto 0);
        in1_i:  in  std_logic_vector(nbit-1 downto 0);
        in2_i:  in  std_logic_vector(nbit-1 downto 0);
        sel_i:  in  std_logic_vector(1 downto 0);
        out_o:  out std_logic_vector(nbit-1 downto 0)
    );
end mux3to1;

architecture behav of mux3to1 is
begin
    out_o <= in0_i when sel_i = "00" else in1_i when sel_i = "01" else in2_i;
    
    assert (sel_i = "00" or sel_i = "01" or sel_i = "10") report "mux3to1: sel_i is out of range" severity error;
end behav;
