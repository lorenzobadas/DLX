library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
use work.mem_pkg.all;

entity data_memory is
    generic(
        ram_width : integer := dmem_width;
        ram_depth : integer := dmem_depth;
        ram_add   : integer := dmem_addr_size;
        init_file : string
    );
    port(
        clk_i         : in std_logic;
        reset_i       : in std_logic;
        en_i          : in std_logic;
        we_i          : in std_logic;
        addr_i        : in std_logic_vector(dmem_addr_size-1 downto 0);  
        din_i         : in std_logic_vector(dmem_width-1 downto 0);
        data_format_i : in std_logic_vector(1 downto 0); -- 00: byte, 01: halfword, 10: word
        data_sign_i   : in std_logic; -- 0: unsigned, 1: signed
        dout_o        : out std_logic_vector(dmem_width-1 downto 0)
    );
end data_memory;

architecture behav of data_memory is
    type ram_type is array (0 to ram_depth-1) of std_logic_vector(ram_width-1 downto 0);
    signal ram_s : ram_type;
    signal word  : std_logic_vector(ram_width-1 downto 0);
begin

    process(clk_i, reset_i)
        file dataFP : text;
        variable dataLine : line;
        variable tmpData : std_logic_vector(ram_width-1 downto 0);
        variable wordIdx : integer := 0;
    begin
        if (reset_i = '1') then
            -- Reset memory
            for i in 0 to ram_depth-1 loop
                ram_s(i) <= (others => '0');
            end loop;
            -- Load memory from init file
            -- Open file
            file_open(dataFP, init_file, READ_MODE);
            wordIdx := 0;
            -- -- Load data into RAM
            while (not endfile(dataFP)) loop
                -- Get data
                readline(dataFP, dataLine);
                -- Convert to hex value
                hread(dataLine, tmpData);
                -- Write word to RAM
                ram_s(wordIdx) <= tmpData;
                -- Point to next RAM entry
                wordIdx := wordIdx + 1;
            end loop;
            -- Close file
            file_close(dataFP);
        elsif (rising_edge(clk_i)) then
            if(en_i = '1') then
                if(we_i = '1') then
                    -- ram_s(to_integer(unsigned(addr_i))) <= din_i;
                    case data_format_i is
                        when "00" => -- byte
                            case addr_i(1 downto 0) is
                                when "00" =>
                                    ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))))(7 downto 0) <= din_i(7 downto 0);
                                when "01" =>
                                    ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))))(15 downto 8) <= din_i(7 downto 0);
                                when "10" =>
                                    ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))))(23 downto 16) <= din_i(7 downto 0);
                                when others =>
                                    ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))))(31 downto 24) <= din_i(7 downto 0);
                            end case;
                        when "01" => -- halfword
                            case addr_i(1) is
                                when '0' =>
                                    ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))))(15 downto 0) <= din_i(15 downto 0);
                                when others =>
                                    ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))))(31 downto 16) <= din_i(15 downto 0);
                            end case;
                        when others => -- word
                            ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2)))) <= din_i;
                    end case;
                end if;
            end if;
        end if;
    end process;

    word <= ram_s(to_integer(unsigned(addr_i(dmem_addr_size-1 downto 2))));

    process (word, data_format_i, data_sign_i)    
        variable byte     : std_logic_vector(7 downto 0);
        variable halfword : std_logic_vector(15 downto 0);
    begin
        case data_format_i is
            when "00" => -- byte
                case addr_i(1 downto 0) is
                    when "00" =>
                        byte := word(7 downto 0);
                    when "01" =>
                        byte := word(15 downto 8);
                    when "10" =>
                        byte := word(23 downto 16);
                    when others =>
                        byte := word(31 downto 24);
                end case;
                if(data_sign_i = '1') then
                    dout_o <= (31 downto 8 => byte(7)) & byte; -- sign-extend
                else
                    dout_o <= (31 downto 8 => '0') & byte; -- zero-extend
                end if;
            when "01" => -- halfword
                case addr_i(1) is
                    when '0' =>
                        halfword := word(15 downto 0);
                    when others =>
                        halfword := word(31 downto 16);
                end case;
                if(data_sign_i = '1') then
                    dout_o <= (31 downto 16 => halfword(15)) & halfword; -- sign-extend
                else
                    dout_o <= (31 downto 16 => '0') & halfword; -- zero-extend
                end if;
            when others => -- word
                dout_o <= word;
        end case;
    end process;

end behav;
