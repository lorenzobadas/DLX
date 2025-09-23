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
        init_file : string := "data_memory.mem"
    );
    port(
        clk_i   : in std_logic;
        reset_i : in std_logic;
        en_i    : in std_logic;
        we_i    : in std_logic;
        addr_i  : in std_logic_vector(dmem_addr_size-1 downto 0);  
        din_i   : in std_logic_vector(dmem_width-1 downto 0);
        dout_o  : out std_logic_vector(dmem_width-1 downto 0)
    );
end data_memory;

architecture behav of data_memory is

type ram_type is array (0 to ram_depth-1) of std_logic_vector(ram_width-1 downto 0);

    signal ram_s : ram_type;

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
                    ram_s(to_integer(unsigned(addr_i))) <= din_i;
                end if;
            end if;
        end if;
    end process;

    dout_o <= ram_s(to_integer(unsigned(addr_i)));

end behav;
