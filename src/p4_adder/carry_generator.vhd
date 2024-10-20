library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.utils_pkg.all;

entity carry_generator is
    generic (
        nbit: integer := 32;
        nbit_per_block: integer := 4
        );
    port (
        a  : in  std_logic_vector(nbit-1 downto 0);
        b  : in  std_logic_vector(nbit-1 downto 0);
        cin: in  std_logic;
        co : out std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0) -- cin is not passed in co
    );
end entity;

architecture behav of carry_generator is
    component g_pg is
        port (
            p_i0: in  std_logic;
            p_i1: in  std_logic;
            g_i : in  std_logic;
            c_i : in  std_logic;
            p_o : out std_logic;
            g_o : out std_logic
        );
    end component g_pg;
    type array2d is array(0 to clog2(nbit), nbit-1 downto 0) of std_logic;
    signal p_array, g_array: array2d;
    -- This function is used to assign he right connection for a PG block
    -- Arguments are: the current block i'm looking at and the previous layer number
    function mask_and_decrement(a, b: integer) return integer is
        variable result: unsigned(clog2(nbit)-1 downto 0);
    begin
        result := (to_unsigned(1, result'length) sll B) - 1;
        result := to_unsigned(A, result'length) and (not result);
        result := result - 1;
        return to_integer(result);
    end mask_and_decrement;
begin
    generate_carry_ext: for i in 0 to clog2(nbit) generate
    begin
        generate_carry_int: for j in 0 to nbit-1 generate
            constant sparsity_blocks: integer := clog2(nbit_per_block);
        begin
            sparsity_case: if (i <= sparsity_blocks) generate
                first_layer: if (i = 0) generate -- first block contains first layer that generates G and P from A and B
                    sub_case: if j = 0 generate
                        p_array(i, j) <= a(j) xor b(j);
                        --               (      g      ) or ((      p      ) and cin);
                        g_array(i, j) <= (a(0) and b(0)) or ((a(0) xor b(0)) and cin);
                    end generate sub_case;
                    else_sub_case: if j /= 0 generate
                        p_array(i, j) <= a(j) xor b(j);
                        g_array(i, j) <= a(j) and b(j);
                    end generate else_sub_case;
                end generate first_layer;
                else_first_layer: if (i > 0) generate
                    carry_bit_column_sparsity: if (((j+1) mod (2**i)) = 0) generate
                        pg_inst0: g_pg
                            port map (
                                p_i0 => p_array(i-1, j-(2**(i-1))),
                                p_i1 => p_array(i-1, j),
                                g_i  => g_array(i-1, j),
                                c_i  => g_array(i-1, j-(2**(i-1))),
                                p_o  => p_array(i, j),
                                g_o  => g_array(i, j)
                            );
                    end generate carry_bit_column_sparsity;
                    else_carry_bit_column_sparsity: if (((j+1) mod (2**i)) /= 0) generate
                        p_array(i, j) <= p_array(i-1, j);
                        g_array(i, j) <= g_array(i-1, j);
                    end generate else_carry_bit_column_sparsity;
                end generate else_first_layer;
            end generate sparsity_case;
            else_sparsity_case: if (i > sparsity_blocks) generate
                carry_column: if (((j+1) mod (2**sparsity_blocks)) = 0) generate
                    pg_block: if (to_integer((to_unsigned(j, clog2(nbit)) srl (i-1)) and to_unsigned(1, clog2(nbit))) = 1) generate -- check bit in order to place or not a PG block
                        pg_inst1: g_pg
                            port map (
                                p_i0 => p_array(i-1, mask_and_decrement(j, i-1)),
                                p_i1 => p_array(i-1, j),
                                g_i  => g_array(i-1, j),
                                c_i  => g_array(i-1, mask_and_decrement(j, i-1)),
                                p_o  => p_array(i, j),
                                g_o  => g_array(i, j)
                            );
                    end generate pg_block;
                    else_pg_block: if (to_integer((to_unsigned(j, clog2(nbit)) srl (i-1)) and to_unsigned(1, clog2(nbit))) /= 1) generate -- assign previous signal to current layer
                        p_array(i, j) <= p_array(i-1, j);
                        g_array(i, j) <= g_array(i-1, j);
                    end generate else_pg_block;
                end generate carry_column;
                else_carry_column: if (((j+1) mod (2**sparsity_blocks)) /= 0) generate
                    p_array(i, j) <= p_array(i-1, j);
                    g_array(i, j) <= g_array(i-1, j);
                end generate else_carry_column;
            end generate else_sparsity_case;
        end generate generate_carry_int;
    end generate generate_carry_ext;

    assign_cout: process (g_array)
    begin
        for i in 0 to (nbit/nbit_per_block)-1 loop
            co(i) <= g_array(clog2(nbit), ((i+1)*nbit_per_block)-1);
        end loop;
    end process assign_cout;
end behav;