library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

package mem_pkg is
    constant dmem_width : integer := 32;
    constant dmem_depth : integer := 256;
    constant dmem_addr  : integer := clog2(dmem_depth)-1;
    constant imem_width : integer := 32;
    constant imem_depth : integer := 256;
    constant imem_addr  : integer := clog2(imem_depth)-1;
end package;