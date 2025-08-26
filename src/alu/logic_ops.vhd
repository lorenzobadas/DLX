library ieee;
use ieee.std_logic_1164.all;
use work.alu_instr_pkg.all;

---------------------------------
-- ALU bitwise operations -------
-- result = a AND/OR/XOR b ------
---------------------------------
entity logic_ops is
    generic (
        nbit: integer := 32
    );
    port (
        a_i:      in  std_logic_vector(nbit-1 downto 0);
        b_i:      in  std_logic_vector(nbit-1 downto 0);
        alu_op_i: in  alu_op_t;
        result_o: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture beh of logic_ops is
begin
    process(a_i, b_i, alu_op_i)
    begin
        case alu_op_i is
            when alu_and => -- AND operation
                result_o <= a_i and b_i;
            when alu_or => -- OR operation
                result_o <= a_i or b_i;
            when alu_xor => -- XOR operation
                result_o <= a_i xor b_i;
            when others =>
                result_o <= (others => '0'); -- Default case
        end case;
    end process;
end beh;
