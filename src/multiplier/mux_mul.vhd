library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_mul is
    generic (
        nbit: integer := 32
    );
    port (
        i0 : in  std_logic_vector(nbit-1 downto 0); -- 0
        i1 : in  std_logic_vector(nbit-1 downto 0); -- A
        i2 : in  std_logic_vector(nbit-1 downto 0); -- -A
        i3 : in  std_logic_vector(nbit-1 downto 0); -- 2A
        i4 : in  std_logic_vector(nbit-1 downto 0); -- -2A
        sel: in  std_logic_vector(     2 downto 0);
        o  : out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture behav of mux_mul is
begin
    o <= i0 when sel = "000" else
         i1 when sel = "001" else
         i1 when sel = "010" else
         i3 when sel = "011" else
         i4 when sel = "100" else
         i2 when sel = "101" else
         i2 when sel = "110" else
         i0 when sel = "111";
end behav;