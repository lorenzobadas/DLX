library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_mem_regs is
    generic(
        nbit : integer := 32
    );
    port (
        clk_i   : in  std_logic;
        reset_i : in  std_logic;
        aluout_i: in  std_logic_vector(nbit-1 downto 0);
        rdata2_i: in  std_logic_vector(nbit-1 downto 0);
        rdest_i : in  std_logic_vector(4 downto 0);
        zero_i  : in  std_logic;
        aluout_o: out std_logic_vector(nbit-1 downto 0);
        rdata2_o: out std_logic_vector(nbit-1 downto 0);
        rdest_o : out std_logic_vector(4 downto 0);
        zero_o  : out std_logic;
        -- Control signals
        memWrite_i    : in std_logic;
        memDataFormat_i : in std_logic_vector(1 downto 0);
        memDataSign_i : in std_logic;
        memToReg_i    : in std_logic;
        regWrite_i    : in std_logic;
        memWrite_o    : out std_logic;
        memDataFormat_o : out std_logic_vector(1 downto 0);
        memDataSign_o : out std_logic;
        memToReg_o    : out std_logic;
        regWrite_o    : out std_logic
    );
end ex_mem_regs;

architecture behav of ex_mem_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            aluout_o <= (others => '0');
            rdata2_o <= (others => '0');
            rdest_o <= (others => '0');
            zero_o <= '0';
            memWrite_o <= '0';
            memDataFormat_o <= (others => '0');
            memDataSign_o <= '0';
            memToReg_o <= '0';
            regWrite_o <= '0';
        elsif rising_edge(clk_i) then
            aluout_o <= aluout_i;
            rdata2_o <= rdata2_i;
            rdest_o <= rdest_i;
            zero_o <= zero_i;
            memWrite_o <= memWrite_i;
            memDataFormat_o <= memDataFormat_i;
            memDataSign_o <= memDataSign_i;
            memToReg_o <= memToReg_i;
            regWrite_o <= regWrite_i;
        end if;
    end process;
end behav;
