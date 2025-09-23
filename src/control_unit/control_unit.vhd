library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_instr_pkg.all;
use work.instructions_pkg.all;
use work.ctrl_signals_pkg.all;

entity control_unit is
    generic(
        nbit : integer := 32
    );
    port (
        instr_i         : in std_logic_vector(nbit-1 downto 0);
        zero_i          : in std_logic;
        immSrc_o        : out std_logic;
        ALUSrc1_o       : out std_logic;
        ALUSrc2_o       : out std_logic;
        ALUOp_o         : out alu_op_t;
        regDest_o       : out std_logic;
        branchEn_o      : out std_logic;
        branchOnZero_o  : out std_logic;
        jumpEn_o        : out std_logic;
        memWrite_o      : out std_logic;
        memToReg_o      : out std_logic;
        regWrite_o      : out std_logic;
        jalEn_o         : out std_logic
    );
end entity;

architecture behav of control_unit is
    signal opcode: std_logic_vector(5 downto 0);
    signal func: std_logic_vector(10 downto 0);
    signal ctrl: ctrl_signals_t;
    
begin
    opcode <= instr_i(5 downto 0);
    func <= instr_i(31 downto 21);

    process(opcode, func, zero_i)
    begin
        get_control_signals(opcode, func, ctrl);

        immSrc_o    <= ctrl.id_ctrl.immSrc;
        ALUSrc1_o   <= ctrl.ex_ctrl.ALUSrc1;
        ALUSrc2_o   <= ctrl.ex_ctrl.ALUSrc2;
        ALUOp_o     <= ctrl.ex_ctrl.ALUOp;
        regDest_o   <= ctrl.ex_ctrl.regDest;
        branchEn_o  <= ctrl.mem_ctrl.branchEn;
        branchOnZero_o <= ctrl.mem_ctrl.branchOnZero;
        jumpEn_o    <= ctrl.mem_ctrl.jumpEn;
        memWrite_o  <= ctrl.mem_ctrl.memWrite;
        memToReg_o  <= ctrl.wb_ctrl.memToReg;
        regWrite_o  <= ctrl.wb_ctrl.regWrite;
        jalEn_o     <= ctrl.wb_ctrl.jalEn;
    end process;
end architecture;
