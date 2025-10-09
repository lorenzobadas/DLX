library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;
use work.utils_pkg.all;

entity tb_t2_logic is
end tb_t2_logic;

architecture test of tb_t2_logic is
    component t2_logic is
        generic (
            nbit: integer := 32
        );
        port (
            a_i:      in  std_logic_vector(nbit-1 downto 0);
            b_i:      in  std_logic_vector(nbit-1 downto 0);
            s_i:      in  std_logic_vector(3 downto 0);
            result_o: out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    signal a:       std_logic_vector(nbit-1 downto 0);
    signal b:       std_logic_vector(nbit-1 downto 0);
    signal s:       std_logic_vector(3 downto 0);
    signal result:  std_logic_vector(nbit-1 downto 0);
    signal simulation_done: boolean := false;
    signal expected: std_logic_vector(nbit-1 downto 0);
    constant iterations: integer := 1000;
begin

    dut: t2_logic
        generic map (
            nbit => nbit
        )
        port map (
            a_i      => a,
            b_i      => b,
            s_i      => s,
            result_o => result
        );

    test_proc: process
    begin
        a <= (others => '0');
        b <= (others => '0');
        s <= (others => '0');
        for i in 1 to iterations loop
            a <= rand_slv(nbit, i);
            b <= rand_slv(nbit, i+iterations);
            case i mod 3 is
                when 0 =>
                    s <= "1000"; -- AND
                when 1 =>
                    s <= "1110"; -- OR
                when 2 =>
                    s <= "0110"; -- XOR
                when others =>
                    s <= (others => '0');
            end case;
            wait for 10 ns;
        end loop;
        simulation_done <= true;
        wait for 10 ns;
        wait;
    end process test_proc;

    expected_proc: process(a, b, s)
    begin
        case s is
            when "1000" =>
                expected <= (a and b);
            when "1110" =>
                expected <= (a or b);
            when "0110" =>
                expected <= (a xor b);
            when others =>
                report "not an t2 logic operation" severity error;
        end case;
    end process expected_proc;

    assert_proc: process
    begin
        if simulation_done then
            wait;
        end if;
        wait for 1 ns;
        case s is
            when "1000" =>
                assert result = expected report "alu_and failed" severity error;
            when "1110" =>
                assert result = expected report "alu_or failed" severity error;
            when "0110" =>
                assert result = expected report "alu_xor failed" severity error;
            when others =>
                report "not an alu operation" severity error;
        end case;
        wait for 9 ns;
    end process assert_proc;

end test;
