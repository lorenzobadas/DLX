library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.UNIFORM;
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

    signal alu_op:  alu_op_t := alu_op_t'low;
    signal a:       std_logic_vector(nbit-1 downto 0);
    signal b:       std_logic_vector(nbit-1 downto 0);
    signal alu_out: std_logic_vector(nbit-1 downto 0);
    signal simulation_done: boolean := false;
    signal expected: std_logic_vector(nbit-1 downto 0);

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
            a <= rand_slv(nbit, 111);
            b <= rand_slv(nbit, 444);
            wait for 10 ns;
        end loop;
        simulation_done <= true;
        wait for 10 ns;
        wait;
    end process test_proc;

    expected_proc: process(a, b, alu_op)
    begin
        case alu_op is
            when alu_add =>
                expected <= std_logic_vector(unsigned(a) + unsigned(b));
            when alu_sub =>
                expected <= std_logic_vector(unsigned(a) - unsigned(b));
            when alu_and =>
                expected <= (a and b);
            when alu_or =>
                expected <= (a or b);
            when alu_xor =>
                expected <= (a xor b);
            when alu_sll =>
                expected <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(clog2(nbit)-1 downto 0)))));
            when alu_srl =>
                expected <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(clog2(nbit)-1 downto 0)))));
            when alu_seq =>
                if a = b then
                    expected <= std_logic_vector(to_signed(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sne =>
                if a /= b then
                    expected <= std_logic_vector(to_signed(1, alu_out'length));   
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sle =>
                if signed(a) <= signed(b) then
                    expected <= std_logic_vector(to_signed(1, alu_out'length));
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sge =>
                if signed(a) >= signed(b) then
                    expected <= std_logic_vector((to_signed(1, alu_out'length)));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sra =>
                expected <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(clog2(nbit)-1 downto 0)))));
            when alu_slt =>
                if signed(a) < signed(b) then
                    expected <= std_logic_vector(to_signed(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sgt =>
                if signed(a) > signed(b) then
                    expected <= std_logic_vector(to_signed(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sltu =>
                if unsigned(a) < unsigned(b) then
                    expected <= std_logic_vector(to_unsigned(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sgeu =>
                if unsigned(a) >= unsigned(b) then
                    expected <= std_logic_vector(to_unsigned(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sleu => 
                if unsigned(a) <= unsigned(b) then
                    expected <= std_logic_vector(to_unsigned(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when alu_sgtu => 
                if unsigned(a) > unsigned(b) then
                    expected <= std_logic_vector(to_unsigned(1, alu_out'length));    
                else
                    expected <= std_logic_vector(to_signed(0, alu_out'length));    
                end if;
            when others =>
                report "not an alu operation" severity error;
        end case;
    end process expected_proc;

    assert_proc: process
    begin
        if simulation_done then
            wait;
        end if;
        wait for 1 ns;
        case alu_op is
            when alu_add =>
                assert alu_out = expected report "alu_add failed" severity error;
            when alu_sub =>
                assert alu_out = expected report "alu_sub failed" severity error;
            when alu_and =>
                assert alu_out = expected report "alu_and failed" severity error;
            when alu_or =>
                assert alu_out = expected report "alu_or failed" severity error;
            when alu_xor =>
                assert alu_out = expected report "alu_xor failed" severity error;
            when alu_sll =>
                assert alu_out = expected report "alu_sll failed" severity error;
            when alu_srl =>
                assert alu_out = expected report "alu_srl failed" severity error;
            when alu_seq =>
                assert alu_out = expected report "alu_seq failed" severity error;
            when alu_sne =>
                assert alu_out = expected report "alu_sne failed" severity error;
            when alu_sle =>
                assert alu_out = expected report "alu_sle failed" severity error;
            when alu_sge =>
                assert alu_out = expected report "alu_sge failed" severity error;
            when alu_sra =>
                assert alu_out = expected report "alu_sra failed" severity error;
            when alu_slt =>
                assert alu_out = expected report "alu_slt failed" severity error;
            when alu_sgt =>
                assert alu_out = expected report "alu_sgt failed" severity error;
            when alu_sltu =>
                assert alu_out = expected report "alu_sltu failed" severity error;
            when alu_sgeu =>
                assert alu_out = expected report "alu_sgeu failed" severity error;
            when alu_sleu => 
                assert alu_out = expected report "alu_sleu failed" severity error;
            when alu_sgtu => 
                assert alu_out = expected report "alu_sgtu failed" severity error;
            when others =>
                report "not an alu operation" severity error;
        end case;
        wait for 9 ns;
    end process assert_proc;

end test;
