library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_formatter is
    generic (
        nbit: integer := 32
    );
    port (
        data_in:         in  std_logic_vector(nbit-1 downto 0);
        last_two_bits_i: in  std_logic_vector(1 downto 0);
        format_i:        in  std_logic_vector(2 downto 0);
        data_out:        out std_logic_vector(nbit-1 downto 0)
    );
end entity;

-- it does not detect misaligned accesses
architecture beh of data_formatter is
begin
    process(data_in, last_two_bits_i, format_i)
        variable last_two_bits: integer;
    begin
        last_two_bits := to_integer(unsigned(last_two_bits_i));
        case format_i is
            when "000" => -- signed byte
                data_out <= std_logic_vector(resize(signed(data_in(last_two_bits*8+7 downto last_two_bits*8)), nbit));
            when "001" => -- unsigned byte
                data_out <= std_logic_vector(resize(unsigned(data_in(last_two_bits*8+7 downto last_two_bits*8)), nbit));
            when "010" => -- signed halfword
                data_out <= std_logic_vector(resize(signed(data_in(last_two_bits*16+15 downto last_two_bits*16)), nbit));
            when "011" => -- unsigned halfword
                data_out <= std_logic_vector(resize(unsigned(data_in(last_two_bits*16+15 downto last_two_bits*16)), nbit));
            when "100" => -- word
                data_out <= data_in;
            when others =>
        end case;
    end process;
end beh;