library ieee;
use ieee.std_logic_1164.all;
use work.alu_instr_pkg.all;

entity comparator is
    generic (
        nbit : integer := 32
    );
    port (
        a_last_i:      in  std_logic;
        b_last_i:      in  std_logic;
        result_i:      in  std_logic_vector(nbit-1 downto 0);
        cout_i  :      in  std_logic;
        alu_op_i:      in  alu_op_t;
        result_o:      out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture beh of comparator is
    signal comparison_result: std_logic;
    signal N, Z, V, C: std_logic;
begin

    N <= result_i(nbit-1);
    Z <= '1' when result_i = (result_i'range => '0') else
         '0';
    -- V = A'BR + AB'R'
    V <= (a_last_i and (not b_last_i) and (not result_i(nbit-1))) or
         ((not a_last_i) and b_last_i and result_i(nbit-1));
    C <= cout_i;

    process(alu_op_i, N, Z, V, C)
    begin
        case alu_op_i is
            when alu_seq =>
                comparison_result <= Z;
            when alu_sne =>
                comparison_result <= not Z;
            when alu_sle =>
                comparison_result <= Z or (N xor V);
            when alu_sge =>
                comparison_result <= N xnor V;
            when alu_slt =>
                comparison_result <= N xor V;
            when alu_sgt =>
                comparison_result <= (not Z) and (N xnor V);
            when alu_sltu =>
                comparison_result <= not C;
            when alu_sgeu =>
                comparison_result <= C;
            when alu_sleu =>
                comparison_result <= Z or (not C);
            when alu_sgtu =>
                comparison_result <= C and (not Z);
            when others =>
                comparison_result <= '0';
        end case;
    end process;

    extend_result_proc: process(comparison_result)
    begin
        result_o <= (others => '0');
        result_o(0) <= comparison_result;
    end process extend_result_proc;
end beh;
