library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_wb_regs is
    generic(nbit: integer := 32);
    port (
        clk_i:     in  std_logic;
        reset_i:   in  std_logic;
        pc_i:      in  std_logic_vector(nbit-1 downto 0);
        npc_i:     in  std_logic_vector(nbit-1 downto 0);
        aluout_i:  in  std_logic_vector(nbit-1 downto 0);
        lmd_i:     in  std_logic_vector(nbit-1 downto 0);
        wdata_i:   in  std_logic_vector(nbit-1 downto 0);
        rdest_i:   in  std_logic_vector(4 downto 0);
        pc_o:      out std_logic_vector(nbit-1 downto 0);
        npc_o:     out std_logic_vector(nbit-1 downto 0);
        aluout_o:  out std_logic_vector(nbit-1 downto 0);
        lmd_o:     out std_logic_vector(nbit-1 downto 0);
        wdata_o:   out std_logic_vector(nbit-1 downto 0);
        rdest_o:   out std_logic_vector(4 downto 0)
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
            wdata_o <= (others => '0');
            rdest_o <= (others => '0');
        elsif rising_edge(clk_i) then
            pc_o <= pc_i;
            npc_o <= npc_i;
            aluout_o <= aluout_i;
            lmd_o <= lmd_i;
            wdata_o <= wdata_i;
            rdest_o <= rdest_i;
        end if;
    end process;
end behav;
