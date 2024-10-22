library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity tb_alu is
end tb_alu;

architecture test of tb_alu is
    component alu is 
        generic(
            nbit: integer := 32
        );
        port(
            alu_op_i:   in  alu_op_t;
            a_i:        in  std_logic_vector(nbit-1 downto 0);
            b_i:        in  std_logic_vector(nbit-1 downto 0); 
            alu_out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    signal alu_op:  alu_op_t;
    signal a:       std_logic_vector(nbit-1 downto 0);
    signal b:       std_logic_vector(nbit-1 downto 0);
    signal alu_out: std_logic_vector(nbit-1 downto 0);
    signal simulation_done: boolean := false;
begin

    dut: alu
        generic map(
            nbit => 32
        )
        port map(
            alu_op_i  => alu_op,
            a_i       => a,
            b_i       => b,
            alu_out_o => alu_out
        );

    test_proc: process
    begin
        a <= (others => '0');
        b <= (others => '0');
        for operation in alu_op_t'low to alu_op_t'high loop
            alu_op <= operation;

            wait for 10 ns;
        end loop;
        simulation_done <= true;
        wait for 10 ns;
        wait;
    end process test_proc;
end test;