library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity t2_shifter_level_3 is
    generic(
        nbit: integer := 64
    );
    port(
        data_i:        in  std_logic_vector((nbit+8)-2 downto 0);
        selection_i:   in  std_logic_vector(clog2(8)-1 downto 0);
        left_right_i:  in  std_logic;
        data_o:        out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture behav of t2_shifter_level_3 is
    signal selection_s: std_logic_vector(clog2(8)-1 downto 0);
begin
    selection_s <= selection_i when left_right_i = '1' else
                   not(selection_i);
    
    mux_proc: process (data_i, selection_s)
        variable shift_amount: integer;
    begin
        shift_amount := to_integer(unsigned(selection_s));
        data_o <= data_i(nbit-1+shift_amount downto shift_amount);
    end process mux_proc;
end behav;