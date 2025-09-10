library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

package mem_pkg is
    dmem_width : constant integer := 32;
    dmem_depth : constant integer := 256;
    dmem_addr  : constant integer := clog2(dmem_depth)-1 downto 0;
    imem_width : constant integer := 32;
    imem_depth : constant integer := 256;
    imem_addr  : constant integer := clog2(imem_depth)-1 downto 0;
end package;