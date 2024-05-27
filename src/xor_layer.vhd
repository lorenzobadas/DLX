library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xor_layer is
    generic (
        nbit: integer := 32
    );
    port (
        b_i: in  std_logic_vector(nbit-1 downto 0);
        c_i: in  std_logic;
        b_o: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture behav of xor_layer is
begin
    process (b_i, c_i) begin
        for i in 0 to nbit-1 loop
            b_o(i) <= b_i(i) xor c_i;
        end loop;
    end process;
end behav;