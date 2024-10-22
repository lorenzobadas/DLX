library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity data_memory is
    generic (
        nbit:  integer := 32;
        dsize: integer := 1024
    );
    port (
        clk_i:    in  std_logic;
        reset_i:  in  std_logic;
        we_i:     in  std_logic;
        re_i:     in  std_logic;
        waddr_i:  in  std_logic_vector(clog2(dsize)-1 downto 0);
        raddr_i:  in  std_logic_vector(clog2(dsize)-1 downto 0);
        data_in:  in  std_logic_vector(nbit-1 downto 0);
        valid_o:  out std_logic;
        data_out: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture beh of data_memory is
    type mem_t is array(0 to dsize-1) of std_logic_vector(nbit-1 downto 0);
    signal dmem: mem_t;
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            dmem <= (others => (others => '0'));
        elsif rising_edge(clk_i) then
            valid_o <= '0';
            if we_i = '1' then
                dmem(to_integer(unsigned(waddr_i))) <= data_in;
            end if;
            if re_i = '1' then
                data_out <= dmem(to_integer(unsigned(raddr_i)));
                valid_o  <= '1';
            end if;
        end if;
    end process;
end beh;
