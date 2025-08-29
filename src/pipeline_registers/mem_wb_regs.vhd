library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_wb_regs is
    generic(
        nbit : integer := 32
    );
    port (
        clk_i       : in  std_logic;
        reset_i     : in  std_logic;
        pc_i        : in  std_logic_vector(nbit-1 downto 0);
        npc_i       : in  std_logic_vector(nbit-1 downto 0);
        aluout_i    : in  std_logic_vector(nbit-1 downto 0);
        lmd_i       : in  std_logic_vector(nbit-1 downto 0);
        rdest_i     : in  std_logic_vector(4 downto 0);
        pc_o        : out std_logic_vector(nbit-1 downto 0);
        npc_o       : out std_logic_vector(nbit-1 downto 0);
        aluout_o    : out std_logic_vector(nbit-1 downto 0);
        lmd_o       : out std_logic_vector(nbit-1 downto 0);
        rdest_o     : out std_logic_vector(4 downto 0);
        -- Control signals
        memToReg_i  : in std_logic;
        regWrite_i  : in std_logic;
        jalEn_i     : in std_logic;
        memToReg_o  : out std_logic;
        regWrite_o  : out std_logic;
        jalEn_o     : out std_logic
    );
end mem_wb_regs;

architecture behav of mem_wb_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            pc_o <= (others => '0');
            npc_o <= (others => '0');
            aluout_o <= (others => '0');
            lmd_o <= (others => '0');
            rdest_o <= (others => '0');
            PCSrc_o <= '0';
            memRead_o <= '0';
            memWrite_o <= '0';
            memToReg_o <= '0';
            regWrite_o <= '0';
            jalEn_o <= '0';
        elsif rising_edge(clk_i) then
            pc_o <= pc_i;
            npc_o <= npc_i;
            aluout_o <= aluout_i;
            lmd_o <= lmd_i;
            rdest_o <= rdest_i;
            PCSrc_o <= PCSrc_i;
            memRead_o <= memRead_i;
            memWrite_o <= memWrite_i;
            memToReg_o <= memToReg_i;
            regWrite_o <= regWrite_i;
            jalEn_o <= jalEn_i;
        end if;
    end process;
end behav;
