library ieee;
use ieee.std_logic_1164.all;
use work.instructions_pkg.all;
use work.alu_instr_pkg.all;

package ctrl_signals_pkg is

    type id_ctrl_t is record
        immSrc : std_logic; 
    end record;

    type ex_ctrl_t is record
        ALUSrc1 : std_logic;
        ALUSrc2 : std_logic;
        ALUOp   : alu_op_t;
        regDest : std_logic;
    end record;

    type mem_ctrl_t is record
        branchOnZero : std_logic;
        branchEn  : std_logic;
        jumpEn    : std_logic;
        memWrite  : std_logic;
        memDataFormat : std_logic_vector(1 downto 0);
        memDataSign   : std_logic;
    end record;

    type wb_ctrl_t is record
        memToReg  : std_logic;
        regWrite  : std_logic;
        jalEn     : std_logic;
    end record;

    type ctrl_signals_t is record
        id_ctrl   : id_ctrl_t;
        ex_ctrl   : ex_ctrl_t;
        mem_ctrl  : mem_ctrl_t;
        wb_ctrl   : wb_ctrl_t;
    end record;

    constant CTRL_SIGNALS_RESET : ctrl_signals_t := (
        id_ctrl  => (immSrc => '0'),
        ex_ctrl  => (ALUSrc1 => '0',
                     ALUSrc2 => '0',
                     ALUOp   => alu_add,
                     regDest => '0'),
        mem_ctrl => (branchOnZero => '0',
                     branchEn  => '0',
                     jumpEn    => '0',
                     memWrite  => '0',
                     memDataFormat => "00",
                     memDataSign   => '0'),
        wb_ctrl  => (memToReg => '0',
                     regWrite => '0',
                     jalEn    => '0')
    );

    procedure get_control_signals(
        signal opcode : in std_logic_vector(5 downto 0);
        signal func   : in std_logic_vector(10 downto 0);
        signal ctrl   : out ctrl_signals_t
    );

end package;

package body ctrl_signals_pkg is

    procedure get_control_signals(
        signal opcode : in std_logic_vector(5 downto 0);
        signal func   : in std_logic_vector(10 downto 0);
        signal ctrl   : out ctrl_signals_t
    ) is
    begin
        -- Default values
        ctrl <= CTRL_SIGNALS_RESET;

        case opcode is
            when "000000" => -- R-type
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '0'; -- rdata2
                ctrl.ex_ctrl.regDest <= '1';
                ctrl.wb_ctrl.regWrite <= '1';
                case func is
                    when func_sll   => ctrl.ex_ctrl.ALUOp <= alu_sll;
                    when func_srl   => ctrl.ex_ctrl.ALUOp <= alu_srl;
                    when func_add   => ctrl.ex_ctrl.ALUOp <= alu_add;
                    when func_sub   => ctrl.ex_ctrl.ALUOp <= alu_sub;
                    when func_and   => ctrl.ex_ctrl.ALUOp <= alu_and;
                    when func_or    => ctrl.ex_ctrl.ALUOp <= alu_or;
                    when func_xor   => ctrl.ex_ctrl.ALUOp <= alu_xor;
                    when func_sne   => ctrl.ex_ctrl.ALUOp <= alu_sne;
                    when func_sle   => ctrl.ex_ctrl.ALUOp <= alu_sle;
                    when func_sge   => ctrl.ex_ctrl.ALUOp <= alu_sge;
                    when func_seq   => ctrl.ex_ctrl.ALUOp <= alu_seq;
                    when func_sra   => ctrl.ex_ctrl.ALUOp <= alu_sra;
                    when func_slt   => ctrl.ex_ctrl.ALUOp <= alu_slt;
                    when func_sgt   => ctrl.ex_ctrl.ALUOp <= alu_sgt;
                    when func_sltu  => ctrl.ex_ctrl.ALUOp <= alu_sltu;
                    when func_sgeu  => ctrl.ex_ctrl.ALUOp <= alu_sgeu;
                    when func_sleu  => ctrl.ex_ctrl.ALUOp <= alu_sleu;
                    when func_sgtu  => ctrl.ex_ctrl.ALUOp <= alu_sgtu;
                    when others     => ctrl.ex_ctrl.ALUOp <= alu_add;
                end case;
            when opcode_j =>
                ctrl.id_ctrl.immSrc  <= '1'; -- j-type immediate
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm (offset)
                ctrl.ex_ctrl.ALUOp   <= alu_add; -- npc + offset
                ctrl.mem_ctrl.jumpEn  <= '1';
            when opcode_jal =>
                ctrl.id_ctrl.immSrc  <= '1'; -- j-type immediate
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm (offset)
                ctrl.ex_ctrl.ALUOp   <= alu_add; -- npc + offset
                ctrl.mem_ctrl.jumpEn  <= '1';
                ctrl.wb_ctrl.jalEn   <= '1'; -- write to r31
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_beqz =>
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm (offset)
                ctrl.ex_ctrl.ALUOp   <= alu_add; -- npc + offset
                ctrl.mem_ctrl.branchEn <= '1';
                ctrl.mem_ctrl.branchOnZero <= '1';
            when opcode_bnez =>
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm (offset)
                ctrl.ex_ctrl.ALUOp   <= alu_add; -- npc + offset
                ctrl.mem_ctrl.branchEn <= '1';
                ctrl.mem_ctrl.branchOnZero <= '0';
            when opcode_addi =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add; -- rdata1 + imm
                ctrl.wb_ctrl.regWrite<= '1'; 
            when opcode_subi =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm 
                ctrl.ex_ctrl.ALUOp   <= alu_sub; -- rdata1 - imm
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_andi =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_and; -- rdata1 & imm
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_ori =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_or; -- rdata1 | imm
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_xori =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_xor; -- rdata1 ^ imm
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_slli =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_sll; -- rdata1 << imm
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_nop =>
                -- do nothing and go to the next instruction
                null;
            when opcode_srli =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_srl; -- rdata1 >> imm
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_snei =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_sne; 
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_slei =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_sle; 
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_sgei =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_sge; 
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_lb =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memDataFormat <= "00"; -- byte
                ctrl.mem_ctrl.memDataSign   <= '1';  -- signed
                ctrl.wb_ctrl.memToReg<= '1';
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_lbu =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memDataFormat <= "00"; -- byte
                ctrl.mem_ctrl.memDataSign   <= '0';  -- unsigned
                ctrl.wb_ctrl.memToReg<= '1';
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_lh =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memDataFormat <= "01"; -- halfword
                ctrl.mem_ctrl.memDataSign   <= '1';  -- signed
                ctrl.wb_ctrl.memToReg<= '1';
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_lhu =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memDataFormat <= "01"; -- halfword
                ctrl.mem_ctrl.memDataSign   <= '0';  -- unsigned
                ctrl.wb_ctrl.memToReg<= '1';
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_lw =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memDataFormat <= "10"; -- word
                ctrl.wb_ctrl.memToReg<= '1';
                ctrl.wb_ctrl.regWrite<= '1';
            when opcode_sb =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memWrite<= '1';
                ctrl.mem_ctrl.memDataFormat <= "00"; -- byte
            when opcode_sh =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memWrite<= '1';
                ctrl.mem_ctrl.memDataFormat <= "01"; -- halfword
            when opcode_sw =>
                ctrl.ex_ctrl.ALUSrc1 <= '1'; -- rdata1
                ctrl.ex_ctrl.ALUSrc2 <= '1'; -- imm
                ctrl.ex_ctrl.ALUOp   <= alu_add;
                ctrl.mem_ctrl.memWrite<= '1';
                ctrl.mem_ctrl.memDataFormat <= "10"; -- word

            when others =>
                ctrl <= CTRL_SIGNALS_RESET;
        end case;
    end procedure;

end package body;
