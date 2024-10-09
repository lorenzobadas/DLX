library ieee;
use ieee.std_logic_1164.all;
use work.o3_pkg.all;

----------------------------
-- ALU bitwise operations --
-- c = a AND/OR/XOR b ------
----------------------------
entity alu_logic_ops is
    generic (
        nbit: integer := 32;
    );
    port (
        a       : in std_logic_vector(nbit-1 downto 0);
        b       : in std_logic_vector(nbit-1 downto 0);
        alu_op  : in alu_op_t(5 downto 0);
        c       : out std_logic_vector(nbit-1 downto 0);       
    );
end entity;

architecture behav of alu_logic_ops is
    begin
        process(a, b, alu_op)
        begin
            case alu_op is
                when alu_and => -- AND operation
                    c <= a and b;
                when alu_or => -- OR operation
                    c <= a or b;
                when alu_xor => -- XOR operation
                    c <= a xor b;
                when others =>
                    c <= (others => '0'); -- Default case
            end case;
        end process;
    end architecture;

