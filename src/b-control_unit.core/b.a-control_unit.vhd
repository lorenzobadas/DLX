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
        immSrc_o        : out std_logic;
        immUnsigned_o   : out std_logic;
        regDest_o       : out std_logic;
        jumpEn_o        : out std_logic;
        jrEn_o          : out std_logic;
        branchEn_o      : out std_logic;
        branchOnZero_o  : out std_logic;
        ALUSrc2_o       : out std_logic;
        ALUOp_o         : out alu_op_t;
        jalEn_o         : out std_logic;
        memWrite_o      : out std_logic;
        memDataFormat_o : out std_logic_vector(1 downto 0);
        memDataSign_o   : out std_logic;
        memToReg_o      : out std_logic;
        regWrite_o      : out std_logic
    );
end entity;

architecture behav of control_unit is
    signal opcode : std_logic_vector(5 downto 0);
    signal func   : std_logic_vector(10 downto 0);
    signal ctrl   : ctrl_signals_t;
    
begin
    opcode <= instr_i(31 downto 26);
    func   <= instr_i(10 downto 0);

    process(opcode, func)
    begin   
        get_control_signals(opcode, func, ctrl);
    end process;

    process(ctrl)
    begin
        immSrc_o        <= ctrl.id_ctrl.immSrc;
        immUnsigned_o   <= ctrl.id_ctrl.immUnsigned;
        regDest_o       <= ctrl.id_ctrl.regDest;
        jumpEn_o        <= ctrl.id_ctrl.jumpEn;
        jrEn_o          <= ctrl.id_ctrl.jrEn;
        branchEn_o      <= ctrl.id_ctrl.branchEn;
        branchOnZero_o  <= ctrl.id_ctrl.branchOnZero;
        ALUSrc2_o       <= ctrl.ex_ctrl.ALUSrc2;
        ALUOp_o         <= ctrl.ex_ctrl.ALUOp;
        jalEn_o         <= ctrl.ex_ctrl.jalEn;
        memWrite_o      <= ctrl.mem_ctrl.memWrite;
        memDataFormat_o <= ctrl.mem_ctrl.memDataFormat;
        memDataSign_o   <= ctrl.mem_ctrl.memDataSign;
        memToReg_o      <= ctrl.wb_ctrl.memToReg;
        regWrite_o      <= ctrl.wb_ctrl.regWrite;
    end process;
end architecture;
