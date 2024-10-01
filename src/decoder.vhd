library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port (
        instruction_i:  in  std_logic_vector(31 downto 0);
        opcode_o:       out std_logic_vector( 5 downto 0);
        func_o:         out std_logic_vector(10 downto 0);
        rs1_o:          out std_logic_vector( 4 downto 0);
        rs2_o:          out std_logic_vector( 4 downto 0);
        rd_o:           out std_logic_vector( 4 downto 0);
        i_immediate_o:  out std_logic_vector(31 downto 0);
        i_uimmediate_o: out std_logic_vector(31 downto 0);
        j_immediate_o:  out std_logic_vector(31 downto 0);

        reservation_station_i: out reservation_station_t;
        alu_operation_i:       out alu_operation_t;
        commit_type_i:         out commit_type_t
    );
end entity;

architecture behav of decoder is
begin
    opcode_o      <= instruction_i(31 downto 26);
    func_o        <= instruction_i(10 downto  0);
    rs1_o         <= instruction_i(25 downto 21);
    rs2_o         <= instruction_i(20 downto 16);
    rd_o          <= instruction_i(15 downto 11);

    extend_immediates_proc: process (instruction_i)
        variable i_immediate: std_logic_vector(15 downto 0);
        variable j_immediate: std_logic_vector(25 downto 0);
    begin
        i_immediate := instruction_i(15 downto 0);
        j_immediate := instruction_i(25 downto 0);

        i_immediate_o   <= std_logic_vector(resize(signed(i_immediate), 32));
        i_uimmediate_o  <= std_logic_vector(resize(unsigned(i_immediate), 32));
        j_immediate_o   <= std_logic_vector(resize(signed(j_immediate), 32));
    end process extend_immediates_proc;
end behav;