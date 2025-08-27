library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_decode is
    generic (
        nbit: integer := 32
    ); 
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        pc_i:       in  std_logic_vector(nbit-1 downto 0);
        npc_i:      in  std_logic_vector(nbit-1 downto 0);
        instr_i:       in  std_logic_vector(nbit-1 downto 0);
        waddr_i:    in  std_logic_vector(4 downto 0);
        wbdata_i:    in  std_logic_vector(nbit-1 downto 0);
        rdata1_o:   out std_logic_vector(nbit-1 downto 0);
        rdata2_o:   out std_logic_vector(nbit-1 downto 0);
        imm_o:      out std_logic_vector(nbit-1 downto 0);
        pc_o:       out std_logic_vector(nbit-1 downto 0);
        npc_o:      out std_logic_vector(nbit-1 downto 0);
        rdest_i_type_o : out std_logic_vector(4 downto 0);
        rdest_r_type_o : out std_logic_vector(4 downto 0)
    );
end entity;

architecture struct of instr_decode is
    component register_file is
        generic (
            nreg : integer := 32;
            nbit : integer := 32
        );
        port (
            clk_i   : in  std_logic;
            we_i    : in  std_logic;
            waddr_i : in  std_logic_vector(clog2(nreg)-1 downto 0);
            wbdata_i : in  std_logic_vector(nbit-1 downto 0);
            raddr1_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
            raddr2_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
            rdata1_o: out std_logic_vector(nbit-1 downto 0);
            rdata2_o: out std_logic_vector(nbit-1 downto 0)
        );
    end component;

begin
    pc_o <= pc_i;
    npc_o <= npc_i;
    imm_o <= (31 downto 16 => instr_i(15), instr_i(15 downto 0));
    rdest_i_type_o <= instr_i(20 downto 16);
    rdest_r_type_o <= instr_i(15 downto 11);
    reg_file: register_file
        generic map (
            nreg => nreg,
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            we_i => we_i,
            waddr_i => waddr_i,
            wbdata_i => wbdata_i,
            raddr1_i => instr_i(25 downto 21),
            raddr2_i => instr_i(20 downto 16),
            rdata1_o => rdata1_o,
            rdata2_o => rdata2_o
        );

end architecture;
