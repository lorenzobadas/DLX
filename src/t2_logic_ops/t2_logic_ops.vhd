library ieee;
use ieee.std_logic_1164.all;

---------------------------------
-- ALU bitwise operations -------
-- result = a AND/OR/XOR b ------
---------------------------------

entity t2_logic_ops is
    generic (
        nbit: integer := 32
    );
    port (
        a_i:      in  std_logic_vector(nbit-1 downto 0);
        b_i:      in  std_logic_vector(nbit-1 downto 0);
        s_i:      in  std_logic_vector(3 downto 0);
        result_o: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture struct of t2_logic_ops is
    component logic_block is
        port(
            s_i: in  std_logic_vector(3 downto 0);
            a_i: in  std_logic;
            b_i: in  std_logic;
            out_o: out std_logic
        );
    end component;

    signal result: std_logic_vector(nbit-1 downto 0);
begin

    gen_logic_blocks: for i in 0 to nbit-1 generate
        logic_block_inst: logic_block
            port map (
                s_i => s_i,
                a_i => a_i(i),
                b_i => b_i(i),
                out_o => result(i)
            );
    end generate;

    result_o <= result;

end struct;
