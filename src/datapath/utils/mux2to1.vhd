library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
    generic(
        nbit: integer := 32
    );
    port(
        in0_i:  in  std_logic_vector(nbit-1 downto 0);
        in1_i:  in  std_logic_vector(nbit-1 downto 0);
        sel_i:  in  std_logic;
        out_o:  out std_logic_vector(nbit-1 downto 0)
    );
end mux2to1;

architecture behav of mux2to1 is
begin
    out_o <= in0_i when sel_i= '0' else in1_i;
end behav;
