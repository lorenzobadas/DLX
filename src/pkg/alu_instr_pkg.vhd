library ieee;
use ieee.std_logic_1164.all;

package alu_instr_pkg is 

    type alu_op_t is (
        alu_add,
        alu_sub,
        alu_and, 
        alu_or, 
        alu_xor, 
        alu_sll, 
        alu_srl, 
        alu_seq,
        alu_sne, 
        alu_sle,   
        alu_sge, 
        alu_sra,  
        alu_slt, 
        alu_sgt, 
        alu_sltu, 
        alu_sgeu, 
        alu_sleu, 
        alu_sgtu
    );

end package alu_instr_pkg;
