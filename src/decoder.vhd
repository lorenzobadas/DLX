library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port (
        instruction_i: in  std_logic_vector(31 downto 0);
        opcode_o:      out std_logic_vector( 5 downto 0);
        func_o:        out std_logic_vector(10 downto 0);
        rs1_o:         out std_logic_vector( 4 downto 0);
        rs2_o:         out std_logic_vector( 4 downto 0);
        rd_o:          out std_logic_vector( 4 downto 0);
        i_immediate_o: out std_logic_vector(15 downto 0);
        j_immediate_o: out std_logic_vector(25 downto 0);
    );
end entity;

architecture behav of decoder is
begin
    opcode_o      <= instruction_i(31 downto 26);
    func_o        <= instruction_i(10 downto  0);
    rs1_o         <= instruction_i(25 downto 21);
    rs2_o         <= instruction_i(20 downto 16);
    rd_o          <= instruction_i(15 downto 11);
    i_immediate_o <= instruction_i(15 downto  0);
    j_immediate_o <= instruction_i(25 downto  0);
end behav;