library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity imem is
    generic(
        ram_width : integer := 4;
        ram_depth : integer := 16;
        ram_add   : integer := 4;
        init_file : string := "imem.mem"
    );
    port(
        addr_i : in std_logic_vector(ram_add-1 downto 0);  
        din_i  : in std_logic_vector(ram_width-1 downto 0);
        clk_i  : in std_logic;                             
        we_i   : in std_logic;                             
        en_i   : in std_logic;                             
        dout_i : out std_logic_vector(ram_width-1 downto 0)
    );
end imem;

architecture behav of imem is

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
    if ramfile = "imem.mem" then
        return InitRamFromFile("imem.mem") ;
    else
        return (others => (others => '0'));
    end if;
end;

function clogb2(depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
    return ret_val;
end function;

signal qr : std_logic_vector(ram_width-1 downto 0) ;
signal ram_s : ram_type := init_from_file_or_zeroes(init_file);

begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(en_i = '1') then
            if(we_i = '1') then
                ram_s(to_integer(unsigned(addr))) <= din;
            else
                qr <= ram_s(to_integer(unsigned(addr)));
            end if;
        end if;
    end if;
end process;

dout <= qr; 

end behav;
