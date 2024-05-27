library ieee;
use ieee.std_logic_1164.all;

package instructions_pkg is
    -- R-TYPE INSTRUCTIONS (All R-type-instruction OpCodes == 0x00)
    constant opcode_add:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_sub:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_and:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_or:   std_logic_vector(5 downto 0) := "000000";
    constant opcode_xor:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_sge:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_sle:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_sne:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_sll:  std_logic_vector(5 downto 0) := "000000";
    constant opcode_srl:  std_logic_vector(5 downto 0) := "000000";
    -- FUNC FIELD
    constant func_add:    std_logic_vector(10 downto 0) := "00000100000"; -- 0x20
    constant func_sub:    std_logic_vector(10 downto 0) := "00000100010"; -- 0x22
    constant func_and:    std_logic_vector(10 downto 0) := "00000100100"; -- 0x24
    constant func_or:     std_logic_vector(10 downto 0) := "00000100101"; -- 0x25
    constant func_xor:    std_logic_vector(10 downto 0) := "00000100110"; -- 0x26
    constant func_sge:    std_logic_vector(10 downto 0) := "00000101101"; -- 0x2D
    constant func_sle:    std_logic_vector(10 downto 0) := "00000101100"; -- 0x2C
    constant func_sne:    std_logic_vector(10 downto 0) := "00000101001"; -- 0x29
    constant func_sll:    std_logic_vector(10 downto 0) := "00000000100"; -- 0x04
    constant func_srl:    std_logic_vector(10 downto 0) := "00000000110"; -- 0x06
    -- I-TYPE INSTRUCTIONS
    constant opcode_addi: std_logic_vector(5 downto 0) := "001000"; -- 0x08
    constant opcode_subi: std_logic_vector(5 downto 0) := "001010"; -- 0x0A
    constant opcode_andi: std_logic_vector(5 downto 0) := "001100"; -- 0x0C
    constant opcode_ori:  std_logic_vector(5 downto 0) := "001101"; -- 0x0D
    constant opcode_xori: std_logic_vector(5 downto 0) := "001110"; -- 0x0E
    constant opcode_sgei: std_logic_vector(5 downto 0) := "011101"; -- 0x1D
    constant opcode_slei: std_logic_vector(5 downto 0) := "011100"; -- 0x1C
    constant opcode_snei: std_logic_vector(5 downto 0) := "011001"; -- 0x19
    constant opcode_slli: std_logic_vector(5 downto 0) := "010100"; -- 0x14
    constant opcode_srli: std_logic_vector(5 downto 0) := "010110"; -- 0x16
    constant opcode_lw:   std_logic_vector(5 downto 0) := "100011"; -- 0x23
    constant opcode_sw:   std_logic_vector(5 downto 0) := "101011"; -- 0x2B
    constant opcode_beqz: std_logic_vector(5 downto 0) := "000100"; -- 0x04
    constant opcode_bnez: std_logic_vector(5 downto 0) := "000101"; -- 0x05
    constant opcode_nop:  std_logic_vector(5 downto 0) := "010101"; -- 0x15
    -- J-TYPE INSTRUCTIONS
    constant opcode_j:    std_logic_vector(5 downto 0) := "000010"; -- 0x02
    constant opcode_jal:  std_logic_vector(5 downto 0) := "000011"; -- 0x03
end instruction_pkg;