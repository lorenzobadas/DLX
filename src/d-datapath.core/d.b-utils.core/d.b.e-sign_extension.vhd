library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extension is
    generic (
        width_in  : integer;
        width_out : integer
    );
    port (
        data_i     : in  std_logic_vector(width_in-1  downto 0);
        unsigned_i : in  std_logic;
        data_o     : out std_logic_vector(width_out-1 downto 0)
    );
end entity;

architecture struct of sign_extension is
    signal extension : std_logic_vector(width_out-width_in-1 downto 0);
begin
    process(data_i, unsigned_i)
    begin
        if unsigned_i = '1' then
            extension <= (others => '0');
        else
            extension <= (others => data_i(width_in-1));
        end if;
    end process;

    data_o <= extension & data_i;
end architecture;
