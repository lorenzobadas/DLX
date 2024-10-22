library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity tb_alu is
end tb_alu;

architecture test of tb_alu is
    signal alu_op:  alu_op_t;
    signal a:       std_logic_vector(nbit-1 downto 0);
    signal b:       std_logic_vector(nbit-1 downto 0);
    signal alu_out: std_logic_vector(nbit-1 downto 0);
    signal simulation_done: boolean := false;
begin
    test_proc: process
    begin

        for operation in alu_op_t'low to alu_op_t'high loop
            alu_op <= operation;

            wait for 10 ns;
        end loop;
        simulation_done <= true;
        wait for 10 ns;
        wait;
    end process test_proc;
end test;