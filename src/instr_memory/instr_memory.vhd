library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use work.mem_pkg.all;

entity instr_memory is
    generic(
        ram_width : integer := imem_width,
        ram_depth : integer := imem_depth,
        ram_add   : integer := imem_addr,
        init_file : string := "instr_memory.mem"
    );
    port(
        clk_i  : in std_logic;
        reset_i: in std_logic;
        en_i   : in std_logic;
        addr_i : in std_logic_vector(imem_addr-1 downto 0);  
        dout_o : out std_logic_vector(imem_width-1 downto 0)
    );
end instr_memory;

architecture behav of instr_memory is

    type ram_type is array (0 to ram_depth-1) of std_logic_vector(ram_width-1 downto 0);

    impure function initramfromfile (ramfilename : in string) return ram_type is
    file ramfile	: text open read_mode is ramfilename;
    variable ramfileline : line;
    variable ram_name	: ram_type;
    variable bitvec : bit_vector(ram_width-1 downto 0);
    begin
        for i in ram_type'range loop
            readline (ramfile, ramfileline);
            read (ramfileline, bitvec);
            ram_name(i) := to_stdlogicvector(bitvec);
        end loop;
        return ram_name;
    end function;

    impure function init_from_file_or_zeroes(ramfile : string) return ram_type is
    begin
        if ramfile = "instr_memory.mem" then
            return InitRamFromFile("instr_memory.mem") ;
        else
            return (others => (others => '0'));
        end if;
    end;

    signal qr : std_logic_vector(ram_width-1 downto 0) ;
    signal ram_s : ram_type := init_from_file_or_zeroes(init_file);

begin
    process(clk_i, reset_i)
    begin
        if (reset_i = '1') then
            qr <= (others => '0');
        elsif (rising_edge(clk_i)) then
            if(en_i = '1') then
                qr <= ram_s(to_integer(unsigned(addr_i)));
            end if;
        end if;
    end process;
    dout_o <= qr; 
end architecture;
