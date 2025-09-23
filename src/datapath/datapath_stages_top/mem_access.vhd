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
        rdest_i : in  std_logic_vector(4 downto 0);
        zero_i  : in std_logic;
        PCSrc_o : out std_logic;
        dmem_addr_o : out std_logic_vector(dmem_addr_size-1 downto 0);
        dmem_din_o  : out std_logic_vector(dmem_width-1 downto 0);
        rdest_o : out std_logic_vector(4 downto 0);
        -- Control signals
        branchEn_i  : in std_logic;
        branchOnZero_i : in std_logic;
        jumpEn_i    : in std_logic;
        memWrite_i  : in std_logic
    );
end entity;

architecture struct of mem_access is
begin
    dmem_addr_o <= aluout_i(dmem_addr_size-1 downto 0);
    dmem_din_o <= rdata2_i;
    rdest_o <= rdest_i;
    PCSrc_o <= (branchEn_i and (zero_i xor (not branchOnZero_i))) or jumpEn_i;
end architecture;
