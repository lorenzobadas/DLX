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
        ir_i:       in  std_logic_vector(nbit-1 downto 0);
        waddr_i:    in  std_logic_vector(4 downto 0);
        wdata_i:    in  std_logic_vector(nbit-1 downto 0);
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
            wdata_i : in  std_logic_vector(nbit-1 downto 0);
            raddr1_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
            raddr2_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
            rdata1_o: out std_logic_vector(nbit-1 downto 0);
            rdata2_o: out std_logic_vector(nbit-1 downto 0)
        );
    end component;

begin
    pc_o <= pc_i;
    npc_o <= npc_i;
    imm_o <= (31 downto 16 => ir_i(15), ir_i(15 downto 0));
    rdest_i_type_o <= ir_i(20 downto 16);
    rdest_r_type_o <= ir_i(15 downto 11);
    reg_file: register_file
        generic map (
            nreg => nreg,
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            we_i => we_i,
            waddr_i => waddr_i,
            wdata_i => wdata_i,
            raddr1_i => ir_i(25 downto 21),
            raddr2_i => ir_i(20 downto 16),
            rdata1_o => rdata1_o,
            rdata2_o => rdata2_o
        );

end architecture;
