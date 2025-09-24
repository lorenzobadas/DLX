library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zero_detector is
    generic (
        nbit : integer := 32
    );
    port (
        a_i    : in  std_logic_vector(nbit-1 downto 0);
        zero_o : out std_logic
    );
end entity;

architecture behav of zero_detector is
begin
    process(a_i)
        variable zero_var : std_logic_vector(nbit-1 downto 0) := (others => '0');
    begin
        if a_i = zero_var then
            zero_o <= '1';
        else
            zero_o <= '0';
        end if;
    end process;

end architecture;
