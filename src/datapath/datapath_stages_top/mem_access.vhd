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
        npc_i   : in  std_logic_vector(nbit-1 downto 0);
        aluout_i: in  std_logic_vector(nbit-1 downto 0);
        rdata2_i: in  std_logic_vector(nbit-1 downto 0);
        rdest_i : in  std_logic_vector(4 downto 0);
        lmd_i   : in std_logic_vector(dmem_width-1 downto 0);
        pc_o    : out std_logic_vector(nbit-1 downto 0);
        dmem_addr_o : out std_logic_vector(dmem_addr-1 downto 0);
        dmem_din_o  : out std_logic_vector(dmem_width-1 downto 0);
        rdest_o : out std_logic_vector(4 downto 0);
        -- Control signals
        PCSrc_i     : in std_logic;
        memWrite_i  : in std_logic
    );
end entity;

architecture struct of mem_access is

    component mux2to1 is
        generic(
            nbit: integer := 32
        );
        port(
            in0_i:  in  std_logic_vector(nbit-1 downto 0);
            in1_i:  in  std_logic_vector(nbit-1 downto 0);
            sel_i:  in  std_logic;
            out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    signal mem_data_out : std_logic_vector(nbit-1 downto 0);

begin
    dmem_addr_o <= aluout_i;
    dmem_din_o <= rdata2_i;
    rdest_o <= rdest_i;

    mux: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => npc_i,
            in1_i => aluout_i,
            sel_i => PCSrc_i,
            out_o => pc_o
        );

end architecture;
