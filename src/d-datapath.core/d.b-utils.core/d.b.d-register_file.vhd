library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity register_file is
    generic (
        nreg : integer := 32;
        nbit : integer := 32
    );
    port (
        clk_i   : in  std_logic;
        we_i    : in  std_logic;
        waddr_i : in  std_logic_vector(clog2(nreg)-1 downto 0);
        wbdata_i : in  std_logic_vector(nbit-1 downto 0);
        raddr1_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
        raddr2_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
        rdata1_o: out std_logic_vector(nbit-1 downto 0);
        rdata2_o: out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture behav of register_file is
    type reg_array_t is array (0 to nreg-1) of std_logic_vector(nbit-1 downto 0);
    signal regs : reg_array_t := (others => (others => '0'));
begin
    rdata1_o <= regs(to_integer(unsigned(raddr1_i)));
    rdata2_o <= regs(to_integer(unsigned(raddr2_i)));

    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if (we_i = '1' and waddr_i /= "00000") then
                regs(to_integer(unsigned(waddr_i))) <= wbdata_i;
            end if;
        end if;
    end process;
end architecture;
