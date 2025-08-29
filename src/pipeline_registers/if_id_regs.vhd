library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.alu_instr_pkg.all;

entity if_id_regs is
    generic(
        nbit : integer := 32
    );
    port (
        clk_i    : in  std_logic;
        reset_i  : in  std_logic;
        pc_i     : in  std_logic_vector(nbit-1 downto 0);
        npc_i    : in  std_logic_vector(nbit-1 downto 0);
        instr_i  : in  std_logic_vector(nbit-1 downto 0);
        pc_o     : out std_logic_vector(nbit-1 downto 0);
        npc_o    : out std_logic_vector(nbit-1 downto 0);
        instr_o  : out std_logic_vector(nbit-1 downto 0);
        -- Control signals
        immSrc_i   : in  std_logic;
        ALUSrc1_i  : in  std_logic;
        ALUSrc2_i  : in  std_logic;
        ALUOp_i    : in  alu_op_t;
        regDest_i  : in  std_logic;
        PCSrc_i    : in  std_logic;
        memRead_i  : in  std_logic;
        memWrite_i : in  std_logic;
        memToReg_i : in  std_logic;
        regWrite_i : in  std_logic;
        jalEn_i    : in  std_logic;
        immSrc_o   : out std_logic;
        ALUSrc1_o  : out std_logic;
        ALUSrc2_o  : out std_logic;
        ALUOp_o    : out alu_op_t;
        regDest_o  : out std_logic;
        PCSrc_o    : out std_logic;
        memRead_o  : out std_logic;
        memWrite_o : out std_logic;
        memToReg_o : out std_logic;
        regWrite_o : out std_logic;
        jalEn_o    : out std_logic
    );
end if_id_regs;

architecture behav of if_id_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            pc_o <= (others => '0');
            npc_o <= (others => '0');
            instr_o <= (others => '0');
            immSrc_o <= '0';
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
            pc_o <= pc_i;
            npc_o <= npc_i;
            instr_o <= instr_i;
            immSrc_o <= immSrc_i;
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
