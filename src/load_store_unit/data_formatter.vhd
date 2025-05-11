library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_formatter is
    generic (
        nbit: integer := 32
    );
    port (
        data_in:  in  std_logic_vector(nbit-1 downto 0);
        offset_i: in  std_logic_vector(1 downto 0);
        format_i: in  std_logic_vector(2 downto 0);
        data_out: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

-- it does not detect misaligned accesses
architecture beh of data_formatter is
begin
    process(data_in, offset_i, format_i)
        variable offset_2bits: integer;
        variable offset_1bit:  integer;
    begin
        offset_2bits := to_integer(unsigned(offset_i));
        offset_1bit  := to_integer(unsigned(offset_i(1 downto 1)));
        case format_i is
            when "000" => -- signed byte
                data_out <= std_logic_vector(resize(signed(data_in(offset_2bits*8+7 downto offset_2bits*8)), nbit));
            when "001" => -- unsigned byte
                data_out <= std_logic_vector(resize(unsigned(data_in(offset_2bits*8+7 downto offset_2bits*8)), nbit));
            when "010" => -- signed halfword
                data_out <= std_logic_vector(resize(signed(data_in(offset_1bit*16+15 downto offset_1bit*16)), nbit));
            when "011" => -- unsigned halfword
                data_out <= std_logic_vector(resize(unsigned(data_in(offset_1bit*16+15 downto offset_1bit*16)), nbit));
            when "100" => -- word
                data_out <= data_in;
            when others =>
                -- default case, should not happen -> write undefined value
                data_out <= (others => 'u');
        end case;
    end process;
end beh;