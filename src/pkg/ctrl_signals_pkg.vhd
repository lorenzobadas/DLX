library ieee;
use ieee.std_logic_1164.all;
use work.instructions_pkg.all;
use work.alu_instr_pkg.all;

package ctrl_signals_pkg is
    type if_ctrl_t is record
        -- none  
    end record;

    type id_ctrl_t is record
        immSrc : std_logic; 
    end record;

    type ex_ctrl_t is record
        ALUSrc1 : std_logic;
        ALUSrc2 : std_logic;
        ALUOp   : alu_op_t;
        regDest   : std_logic;
    end record;

    type mem_ctrl_t is record
        branchOnZero : std_logic;
        branchEn  : std_logic;
        jumpEn    : std_logic;
        memRead   : std_logic;
        memWrite  : std_logic;
    end record;

    type wb_ctrl_t is record
        memToReg  : std_logic;
        regWrite  : std_logic;
        jalEn     : std_logic;
    end record;

    type ctrl_signals_t is record
        if_ctrl   : if_ctrl_t;
        id_ctrl   : id_ctrl_t;
        ex_ctrl   : ex_ctrl_t;
        mem_ctrl  : mem_ctrl_t;
        wb_ctrl   : wb_ctrl_t;
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
        ctrl.id_ctrl_t.immSrc    := '0';
        ctrl.ex_ctrl_t.ALUSrc1   := '0';
        ctrl.ex_ctrl_t.ALUSrc2   := '0';
        ctrl.ex_ctrl_t.ALUOp     := alu_add;
        ctrl.ex_ctrl_t.regDest   := '0';
        ctrl.mem_ctrl_t.branchOnZero := '0';
        ctrl.mem_ctrl_t.branchEn  := '0';
        ctrl.mem_ctrl_t.jumpEn    := '0';
        ctrl.mem_ctrl_t.memRead   := '0';
        ctrl.mem_ctrl_t.memWrite  := '0';
        ctrl.wb_ctrl_t.memToReg  := '0';
        ctrl.wb_ctrl_t.regWrite  := '0';
        ctrl.wb_ctrl_t.jalEn     := '0';

        case opcode is
            when "000000" => -- R-type
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '0'; -- rdata2
                ctrl.ex_ctrl_t.regDest := '1';
                ctrl.wb_ctrl_t.regWrite := '1';
                case func is
                    when func_sll   => ctrl.ex_ctrl_t.ALUOp := alu_sll;
                    when func_srl   => ctrl.ex_ctrl_t.ALUOp := alu_srl;
                    when func_add   => ctrl.ex_ctrl_t.ALUOp := alu_add;
                    when func_sub   => ctrl.ex_ctrl_t.ALUOp := alu_sub;
                    when func_and   => ctrl.ex_ctrl_t.ALUOp := alu_and;
                    when func_or    => ctrl.ex_ctrl_t.ALUOp := alu_or;
                    when func_xor   => ctrl.ex_ctrl_t.ALUOp := alu_xor;
                    when func_sne   => ctrl.ex_ctrl_t.ALUOp := alu_sne;
                    when func_sle   => ctrl.ex_ctrl_t.ALUOp := alu_sle;
                    when func_sge   => ctrl.ex_ctrl_t.ALUOp := alu_sge;
                    when func_seq   => ctrl.ex_ctrl_t.ALUOp := alu_seq;
                    when func_sra   => ctrl.ex_ctrl_t.ALUOp := alu_sra;
                    when func_slt   => ctrl.ex_ctrl_t.ALUOp := alu_slt;
                    when func_sgt   => ctrl.ex_ctrl_t.ALUOp := alu_sgt;
                    when func_sltu  => ctrl.ex_ctrl_t.ALUOp := alu_sltu;
                    when func_sgeu  => ctrl.ex_ctrl_t.ALUOp := alu_sgeu;
                    when func_sleu  => ctrl.ex_ctrl_t.ALUOp := alu_sleu;
                    when func_sgtu  => ctrl.ex_ctrl_t.ALUOp := alu_sgtu;
                    when others     => ctrl.ex_ctrl_t.ALUOp := alu_add;
                end case;
            when opcode_j =>
                ctrl.if_ctrl_t.immSrc  := '1'; -- j-type immediate
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ex_ctrl_t.ALUOp   := alu_add; -- npc + offset
                ctrl.ex_ctrl_t.jumpEn  := '1';
            when opcode_jal =>
                ctrl.if_ctrl_t.immSrc  := '1'; -- j-type immediate
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ex_ctrl_t.ALUOp   := alu_add; -- npc + offset
                ctrl.ex_ctrl_t.jumpEn  := '1';
                ctrl.wb_ctrl_t.jalEn   := '1'; -- write to r31
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_beqz =>
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ex_ctrl_t.ALUOp   := alu_add; -- npc + offset
                ctrl.ex_ctrl_t.branchEn:= '1';
                ctrl.ex_ctrl_t.branchOnZero := '1';
            when opcode_bnez =>
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm (offset)
                ctrl.ex_ctrl_t.ALUOp   := alu_add; -- npc + offset
                ctrl.ex_ctrl_t.branchEn:= '1';
                ctrl.ex_ctrl_t.branchOnZero := '0';
            when opcode_addi =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_add; -- rdata1 + imm
                ctrl.wb_ctrl_t.regWrite:= '1'; 
            when opcode_subi =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm 
                ctrl.ex_ctrl_t.ALUOp   := alu_sub; -- rdata1 - imm
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_andi =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_and; -- rdata1 & imm
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_ori =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_or; -- rdata1 | imm
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_xori =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_xor; -- rdata1 ^ imm
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_slli =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_sll; -- rdata1 << imm
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_nop =>
                -- do nothing and go to the next instruction
                null;
            when opcode_srli =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_srl; -- rdata1 >> imm
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_snei =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_sne; 
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_slei =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_sle; 
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_sgei =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_sge; 
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_lw =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_add;
                ctrl.mem_ctrl_t.memRead := '1';
                ctrl.mem_ctrl_t.memToReg:= '1';
                ctrl.wb_ctrl_t.regWrite:= '1';
            when opcode_sw =>
                ctrl.ex_ctrl_t.ALUSrc1 := '1'; -- rdata1
                ctrl.ex_ctrl_t.ALUSrc2 := '1'; -- imm
                ctrl.ex_ctrl_t.ALUOp   := alu_add;
                ctrl.mem_ctrl_t.memWrite:= '1';

            when others =>
                null;
        end case;
        return ctrl;
    end function;

end package body;
