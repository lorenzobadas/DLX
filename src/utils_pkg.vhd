library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package utils_pkg is
    function clog2 (a: integer) return integer;
    function max (a: integer; b: integer) return integer;
    function slv_to_string ( a: std_logic_vector) return string;
    function bv_to_string ( a: bit_vector) return string;
end package;

package body utils_pkg is
    function clog2 (a: integer) return integer is
    begin
        return integer(ceil(log2(real(a))));
    end function;

    function max (a: integer; b: integer) return integer is
    begin
        if a > b then
            return a;
        else
            return b;
        end if;
    end function;

    function slv_to_string ( a: std_logic_vector) return string is
        variable b : string (a'length-1 downto 1) := (others => NUL);
    begin
            for i in a'length-1 downto 1 loop
            b(i) := std_logic'image(a((i-1)))(2);
            end loop;
        return b;
    end function;

    function bv_to_string ( a: bit_vector) return string is
        variable b : string (a'length-1 downto 1) := (others => NUL);
    begin
            for i in a'length-1 downto 1 loop
            b(i) := bit'image(a((i-1)))(2);
            end loop;
        return b;
    end function;
end package body;