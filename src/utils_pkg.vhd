library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package utils_pkg is
    function clog2 (a: integer) return integer;
    function max (a: integer; b: integer) return integer;
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
end package body;