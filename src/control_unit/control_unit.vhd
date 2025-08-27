library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_instr_pkg.all;
use work.instructions_pkg.all;

entity control_unit is
    generic(
        nbit: integer := 32
    );
    port (
        instr_i: in std_logic_vector(nbit-1 downto 0);
        zero_i: in std_logic;
        immSrc_o: out std_logic;
        ALUSrc1_o: out std_logic;
        ALUSrc2_o: out std_logic;
        ALUOp_o: out alu_op_t;
        regDest_o: out std_logic;
        PCSrc_o: out std_logic;
        memRead_o: out std_logic;
        memWrite_o: out std_logic;
        memToReg_o: out std_logic;
        regWrite_o: out std_logic;
        jalEn_o: out std_logic
    );
end entity;

architecture behav of control_unit is
    signal opcode: std_logic_vector(5 downto 0);
    signal func: std_logic_vector(10 downto 0);
    signal branchEn, jumpEn, branchOnZero: std_logic;
begin
    func <= instr_i(31 downto 21);
    opcode <= instr_i(5 downto 0);

    process(opcode, func, zero_i)
    begin
        immSrc_o <= '0';
        ALUSrc1_o <= '0';
        ALUSrc2_o <= '0';
        ALUOp_o <= alu_add;
        regDest_o <= '0';
        branchEn <= '0';
        jumpEn <= '0';
        branchOnZero <= '0';
        memRead_o <= '0';
        memWrite_o <= '0';
        memToReg_o <= '0';
        regWrite_o <= '0';
        jalEn_o <= '0';

        case opcode is 
            when "000000" =>
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '0'; -- rdata2
                regDest_o <= '1';
                regWrite_o <= '1';
                case func is
                    when func_sll =>
                        ALUOp_o <= alu_sll;
                    when func_srl =>
                        ALUOp_o <= alu_srl;
                    when func_add =>
                        ALUOp_o <= alu_add;
                    when func_sub =>
                        ALUOp_o <= alu_sub;
                    when func_and =>
                        ALUOp_o <= alu_and;
                    when func_or =>
                        ALUOp_o <= alu_or;
                    when func_xor =>
                        ALUOp_o <= alu_xor;
                    when func_sne =>
                        ALUOp_o <= alu_sne;
                    when func_sle =>
                        ALUOp_o <= alu_sle;
                    when func_sge =>
                       ALUOp_o <= alu_sge;
                    when func_seq =>
                        ALUOp_o <= alu_seq;
                    when func_sra =>
                        ALUOp_o <= alu_sra;
                    when func_slt =>
                        ALUOp_o <= alu_slt;
                    when func_sgt =>
                        ALUOp_o <= alu_sgt;
                    when func_sltu =>
                        ALUOp_o <= alu_sltu;
                    when func_sgeu =>
                        ALUOp_o <= alu_sgeu;
                    when func_sleu =>
                        ALUOp_o <= alu_sleu;
                    when func_sgtu =>
                        ALUOp_o <= alu_sgtu;
                    when others =>
                        ALUOp_o <= alu_add;
                end case;

            when opcode_j =>
                immSrc_o <= '1'; -- j-type immediate
                ALUSrc1_o <= '0'; -- npc
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                jumpEn <= '1';
                regWrite_o <= '0';

            when opcode_jal =>
                immSrc_o <= '1'; -- j-type immediate
                ALUSrc1_o <= '0'; -- npc
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                jumpEn <= '1';
                memToReg_o <= '0';
                jalEn_o <= '1';
                regWrite_o <= '1';

            when opcode_beqz =>
                immSrc_o <= '0';
                ALUSrc1_o <= '0'; -- npc
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                regDest_o <= '0';
                branchEn <= '1';
                branchOnZero <= '1';
                regWrite_o <= '0';

            when opcode_bnez =>
                immSrc_o <= '0';
                ALUSrc1_o <= '0'; -- npc
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                regDest_o <= '0';
                branchEn <= '1';
                branchOnZero <= '0';
                regWrite_o <= '0';

            when opcode_addi =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_subi =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_sub;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_andi =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_and;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_ori =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_or;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_xori =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_xor;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_slli =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_sll;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';

            when opcode_nop =>
                -- do nothing and go to the next instruction
                branchEn <= '0';
                jumpEn <= '0';

            when opcode_srli =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_srl;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';

            when opcode_snei =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_sne;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_slei =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_sle;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_sgei =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_sge;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memToReg_o <= '0';
                regWrite_o <= '1';
                jalEn_o <= '0';
            
            when opcode_lw =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memRead_o <= '1';
                memWrite_o <= '0';
                memToReg_o <= '1';
                regWrite_o <= '1';
                jalEn_o <= '0';    
                       
            when opcode_sw =>
                immSrc_o <= '0'; -- i-type immediate
                ALUSrc1_o <= '1'; -- rdata1
                ALUSrc2_o <= '1'; -- imm (offset)
                ALUOp_o <= alu_add;
                regDest_o <= '0'; -- rdest_i_type
                branchEn <= '0';
                jumpEn <= '0';
                memRead_o <= '0';
                memWrite_o <= '1';
                regWrite_o <= '0';
            
            when others =>
                immSrc_o <= '0';
                ALUSrc1_o <= '0';
                ALUSrc2_o <= '0';
                ALUOp_o <= alu_add;
                regDest_o <= '0';
                branchEn <= '0';
                jumpEn <= '0';
                memRead_o <= '0';
                memWrite_o <= '0';
                memToReg_o <= '0';
                regWrite_o <= '0';
                jalEn_o <= '0';
        end case;

        PCSrc_o <= (branchEn and (zero_i xor (not branchOnZero))) or jumpEn;
        
    end process;
end architecture;
