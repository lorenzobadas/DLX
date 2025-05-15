library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_decoder is 
    port (
        opcode_i:              in   std_logic_vector(5 downto 0);
        func_i:                in   std_logic_vector(10 downto 0);
        reservation_station_o: out  reservation_station_t; -- lsu, alu, mult, none
        alu_operation_o:       out  alu_op_t; --TODO merge o3pkg form main, add none  
        commit_type_o:         out  commit_option_t --TODO rename -- none, branch, to_mem, to_rf
    );
end entity;

architecture behav of instr_decoder is      
begin
    decode_proc: process(opcode_i, func_i)
    begin
        reservation_station_o <= none;
        alu_operation_o       <= none;
        commit_type_o         <= none;

        case opcode_i is
            when opcode_addi | opcode_subi | opcode_andi | opcode_ori |
                opcode_xori | opcode_slli | opcode_srli |
                opcode_snei | opcode_slei | opcode_sgei =>
                reservation_station_o <= alu;
                commit_type_o         <= to_rf;

                case opcode_o is
                    when opcode_addi  => alu_operation_o <= alu_add;
                    when opcode_subi  => alu_operation_o <= alu_sub;
                    when opcode_andi  => alu_operation_o <= alu_and;
                    when opcode_ori   => alu_operation_o <= alu_or;
                    when opcode_xori  => alu_operation_o <= alu_xor;
                    when opcode_slli  => alu_operation_o <= alu_sll;
                    when opcode_srli  => alu_operation_o <= alu_srl;
                    when opcode_snei  => alu_operation_o <= alu_sne;
                    when opcode_slei  => alu_operation_o <= alu_sle;
                    when opcode_sgei  => alu_operation_o <= alu_sge;
                    when others       => alu_operation_o <= alu_none;
                end case;

            when opcode_lw =>
                reservation_station_o <= lsu;
                alu_operation_o       <= alu_add;
                commit_type_o         <= to_rf;

            when opcode_sw =>
                reservation_station_o <= lsu;
                alu_operation_o       <= alu_add;
                commit_type_o         <= to_mem;

            when opcode_beqz | opcode_bnez =>
                reservation_station_o <= branch;
                alu_operation_o       <= alu_sub;
                commit_type_o         <= none;

            when opcode_j | opcode_jal =>
                reservation_station_o <= branch;
                alu_operation_o       <= alu_nop; --TODO add also this to alu_op_t
                commit_type_o         <= none;

            when opcode_nop =>
                reservation_station_o <= alu;
                alu_operation_o       <= alu_nop;
                commit_type_o         <= none;

            when  opcode_sll | opcode_srl | opcode_add | 
                opcode_sub | opcode_and | opcode_or |
                opcode_xor | opcode_sne |
                opcode_sle | opcode_sge =>
                reservation_station_o <= alu;
                commit_type_o         <= to_rf;

                case func_o is
                    when "10000000000" => alu_operation_o <= alu_add;
                    when "10001000000" => alu_operation_o <= alu_sub;
                    when "10010000000" => alu_operation_o <= alu_and;
                    when "10010100000" => alu_operation_o <= alu_or;
                    when "10011000000" => alu_operation_o <= alu_xor;
                    when others        => alu_operation_o <= alu_none;
                end case;

            when others =>
                reservation_station_o <= none;
                alu_operation_o       <= none;
                commit_type_o         <= none;
        end case;    
end architecture behav;

