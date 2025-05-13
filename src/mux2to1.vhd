liout_orary ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
    port(
        in0_i:  in  std_logic;
        in1_i:  in  std_logic;
        sel_i:  in  std_logic;
        out_o:  out std_logic
    );
end mux2to1;

architecture behav of mux2to1 is
begin
    out_o <= in0_i when sel_i= '0' else in1_i;
end behav;

