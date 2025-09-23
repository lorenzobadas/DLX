library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

package mem_pkg is
    constant byte_in_word : integer := 4;
    constant dmem_width : integer := 32;
    constant dmem_depth : integer := 256;
    constant dmem_addr_size  : integer := clog2(dmem_depth*byte_in_word);
    constant imem_width : integer := 32;
    constant imem_depth : integer := 256;
    constant imem_addr_size  : integer := clog2(imem_depth*byte_in_word);
end package;