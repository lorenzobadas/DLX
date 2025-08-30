library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_instr_pkg.all;

entity id_ex_regs is
    generic(
        nbit : integer := 32
    );
    port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        npc_i           : in  std_logic_vector(nbit-1 downto 0);
        rdata1_i        : in  std_logic_vector(nbit-1 downto 0);
        rdata2_i        : in  std_logic_vector(nbit-1 downto 0);
        imm_i           : in  std_logic_vector(nbit-1 downto 0);
        rdest_i_type_i  : in  std_logic_vector(4 downto 0);
        rdest_r_type_i  : in  std_logic_vector(4 downto 0);
        npc_o           : out std_logic_vector(nbit-1 downto 0);
        rdata1_o        : out std_logic_vector(nbit-1 downto 0);
        rdata2_o        : out std_logic_vector(nbit-1 downto 0);
        imm_o           : out std_logic_vector(nbit-1 downto 0);
        rdest_i_type_o  : out std_logic_vector(4 downto 0);
        rdest_r_type_o  : out std_logic_vector(4 downto 0);
        -- Control signals
        ALUSrc1_i       : in  std_logic;
        ALUSrc2_i       : in  std_logic;
        ALUOp_i         : in  alu_op_t;
        regDest_i       : in  std_logic;
        PCSrc_i         : in  std_logic;
        memRead_i       : in  std_logic;
        memWrite_i      : in  std_logic;
        memToReg_i      : in  std_logic;
        regWrite_i      : in  std_logic;
        jalEn_i         : in  std_logic;
        ALUSrc1_o       : out std_logic;
        ALUSrc2_o       : out std_logic;
        ALUOp_o         : out alu_op_t;
        regDest_o       : out std_logic;
        PCSrc_o         : out std_logic;
        memRead_o       : out std_logic;
        memWrite_o      : out std_logic;
        memToReg_o      : out std_logic;
        regWrite_o      : out std_logic;
        jalEn_o         : out std_logic
    );
end id_ex_regs;

architecture behav of id_ex_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            npc_o <= (others => '0');
            rdata1_o <= (others => '0');
            rdata2_o <= (others => '0');
            imm_o <= (others => '0');
            rdest_i_type_o <= (others => '0');
            rdest_r_type_o <= (others => '0');
            ALUSrc1_o <= '0';
            ALUSrc2_o <= '0';
            ALUOp_o <= alu_add;
            regDest_o <= '0';
            PCSrc_o <= '0';
            memRead_o <= '0';
            memWrite_o <= '0';
            memToReg_o <= '0';
            regWrite_o <= '0';
            jalEn_o <= '0';
        elsif rising_edge(clk_i) then
            npc_o <= npc_i;
            rdata1_o <= rdata1_i;
            rdata2_o <= rdata2_i;
            imm_o <= imm_i;
            rdest_i_type_o <= rdest_i_type_i;
            rdest_r_type_o <= rdest_r_type_i;
            ALUSrc1_o <= ALUSrc1_i;
            ALUSrc2_o <= ALUSrc2_i;
            ALUOp_o <= ALUOp_i;
            regDest_o <= regDest_i;
            PCSrc_o <= PCSrc_i;
            memRead_o <= memRead_i;
            memWrite_o <= memWrite_i;
            memToReg_o <= memToReg_i;
            regWrite_o <= regWrite_i;
            jalEn_o <= jalEn_i;
        end if;
    end process;
end behav;
