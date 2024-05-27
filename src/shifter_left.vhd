library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter_left is
    generic (
        nbit  : integer := 32;
        amount: integer := 2
    );
    port (
        a      : in  std_logic_vector(nbit-1 downto 0);
        a_shift: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture behav of shifter_left is
begin
    process (a) begin
        for i in 0 to nbit-1 loop
            if i < amount then
                a_shift(i) <= '0';
            else
                a_shift(i) <= a(i-amount);
            end if;
        end loop;
    end process;
end behav;