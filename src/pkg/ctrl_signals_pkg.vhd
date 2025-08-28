library ieee;
use ieee.std_logic_1164.all;
use work.instructions_pkg.all;
use work.alu_instr_pkg.all;

package ctrl_signals_pkg is
    type ctrl_signals_t is record
        immSrc    : std_logic;
        ALUSrc1   : std_logic;
        ALUSrc2   : std_logic;
        ALUOp     : alu_op_t;
        regDest   : std_logic;
        branchEn  : std_logic;
        branchOnZero : std_logic;
        jumpEn    : std_logic;
        memRead   : std_logic;
        memWrite  : std_logic;
        memToReg  : std_logic;
        regWrite  : std_logic;
        jalEn     : std_logic;
    end record;
end package;

package body ctrl_signals_pkg is

    function get_control_signals(
        opcode : std_logic_vector(5 downto 0);
        func   : std_logic_vector(10 downto 0)
    ) return ctrl_signals_t is
        variable ctrl : ctrl_signals_t;
    begin
        -- Default values
        ctrl.immSrc    := '0';
        ctrl.ALUSrc1   := '0';
        ctrl.ALUSrc2   := '0';
        ctrl.ALUOp     := alu_add;
        ctrl.regDest   := '0';
        ctrl.branchOnZero := '0';
        ctrl.branchEn  := '0';
        ctrl.jumpEn    := '0';
        ctrl.memRead   := '0';
        ctrl.memWrite  := '0';
        ctrl.memToReg  := '0';
        ctrl.regWrite  := '0';
        ctrl.jalEn     := '0';

        case opcode is
            when "000000" => -- R-type
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '0'; -- rdata2
                ctrl.regDest := '1';
                ctrl.regWrite := '1';
                case func is
                    when func_sll   => ctrl.ALUOp := alu_sll;
                    when func_srl   => ctrl.ALUOp := alu_srl;
                    when func_add   => ctrl.ALUOp := alu_add;
                    when func_sub   => ctrl.ALUOp := alu_sub;
                    when func_and   => ctrl.ALUOp := alu_and;
                    when func_or    => ctrl.ALUOp := alu_or;
                    when func_xor   => ctrl.ALUOp := alu_xor;
                    when func_sne   => ctrl.ALUOp := alu_sne;
                    when func_sle   => ctrl.ALUOp := alu_sle;
                    when func_sge   => ctrl.ALUOp := alu_sge;
                    when func_seq   => ctrl.ALUOp := alu_seq;
                    when func_sra   => ctrl.ALUOp := alu_sra;
                    when func_slt   => ctrl.ALUOp := alu_slt;
                    when func_sgt   => ctrl.ALUOp := alu_sgt;
                    when func_sltu  => ctrl.ALUOp := alu_sltu;
                    when func_sgeu  => ctrl.ALUOp := alu_sgeu;
                    when func_sleu  => ctrl.ALUOp := alu_sleu;
                    when func_sgtu  => ctrl.ALUOp := alu_sgtu;
                    when others     => ctrl.ALUOp := alu_add;
                end case;
            when opcode_j =>
                ctrl.immSrc  := '1'; -- j-type immediate
                ctrl.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ALUOp   := alu_add; -- npc + offset
                ctrl.jumpEn  := '1';
            when opcode_jal =>
                ctrl.immSrc  := '1'; -- j-type immediate
                ctrl.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ALUOp   := alu_add; -- npc + offset
                ctrl.jumpEn  := '1';
                ctrl.jalEn   := '1'; -- write to r31
                ctrl.regWrite:= '1';
            when opcode_beqz =>
                ctrl.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ALUOp   := alu_add; -- npc + offset
                ctrl.branchEn:= '1';
                ctrl.branchOnZero := '1';
            when opcode_bnez =>
                ctrl.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ALUOp   := alu_add; -- npc + offset
                ctrl.branchEn:= '1';
                ctrl.branchOnZero := '0';
            when opcode_addi =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_add; -- rdata1 + imm
                ctrl.regWrite:= '1'; 
            when opcode_subi =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm 
                ctrl.ALUOp   := alu_sub; -- rdata1 - imm
                ctrl.regWrite:= '1';
            when opcode_andi =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_and; -- rdata1 & imm
                ctrl.regWrite:= '1';
            when opcode_ori =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_or; -- rdata1 | imm
                ctrl.regWrite:= '1';
            when opcode_xori =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_xor; -- rdata1 ^ imm
                ctrl.regWrite:= '1';
            when opcode_slli =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_sll; -- rdata1 << imm
                ctrl.regWrite:= '1';
            when opcode_nop =>
                -- do nothing and go to the next instruction
                null;
            when opcode_srli =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_srl; -- rdata1 >> imm
                ctrl.regWrite:= '1';
            when opcode_snei =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_sne; 
                ctrl.regWrite:= '1';
            when opcode_slei =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_sle; 
                ctrl.regWrite:= '1';
            when opcode_sgei =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_sge; 
                ctrl.regWrite:= '1';
            when opcode_lw =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_add;
                ctrl.memRead := '1';
                ctrl.memToReg:= '1';
                ctrl.regWrite:= '1';
            when opcode_sw =>
                ctrl.ALUSrc1 := '1'; -- rdata1
                ctrl.ALUSrc2 := '1'; -- imm
                ctrl.ALUOp   := alu_add;
                ctrl.memWrite:= '1';
            
            when others =>
                null;
        end case;
        return ctrl;
    end function;

end package body;
