library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_pkg.all;

entity mem_access is
    generic (
        nbit : integer := 32
    );
    port (
        clk_i   : in  std_logic;
        reset_i : in  std_logic;
        aluout_i: in  std_logic_vector(nbit-1 downto 0);
        rdata2_i: in  std_logic_vector(nbit-1 downto 0);
        dmem_addr_o : out std_logic_vector(dmem_addr_size-1 downto 0);
        dmem_din_o  : out std_logic_vector(dmem_width-1 downto 0);
        -- Control signals
        memWrite_i  : in std_logic
    );
end entity;

architecture struct of mem_access is
begin
    dmem_addr_o <= aluout_i(dmem_addr_size-1 downto 0);
    dmem_din_o <= rdata2_i;
end architecture;
