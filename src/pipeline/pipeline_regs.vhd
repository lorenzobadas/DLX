library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_regs is
    generic(
        nbit: integer := 32
    );
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        pc_i:       in  std_logic_vector(nbit-1 downto 0);
        npc_i:      in  std_logic_vector(nbit-1 downto 0);
        ir_i:       in  std_logic_vector(nbit-1 downto 0);
        a_i:        in  std_logic_vector(nbit-1 downto 0);
        b_i:        in  std_logic_vector(nbit-1 downto 0);
        imm_i:      in  std_logic_vector(nbit-1 downto 0);
        cond_i:     in  std_logic;
        aluout_i:   in  std_logic_vector(nbit-1 downto 0);
        lmd_i:      in  std_logic_vector(nbit-1 downto 0);
        wb_i:       in  std_logic_vector(nbit-1 downto 0);
        pc_o:       out std_logic_vector(nbit-1 downto 0);
        npc_o:      out std_logic_vector(nbit-1 downto 0);
        ir_o:       out std_logic_vector(nbit-1 downto 0);
        a_o:        out std_logic_vector(nbit-1 downto 0);
        b_o:        out std_logic_vector(nbit-1 downto 0);
        imm_o:      out std_logic_vector(nbit-1 downto 0);
        cond_o:     out std_logic;
        aluout_o:   out std_logic_vector(nbit-1 downto 0);
        lmd_o:      out std_logic_vector(nbit-1 downto 0);
        wb_o:       out std_logic_vector(nbit-1 downto 0)
    );
end pipeline_regs;

architecture behav of pipeline_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            pc_o <= (others => '0');
            npc_o <= (others => '0');
            ir_o <= (others => '0');
            a_o <= (others => '0');
            b_o <= (others => '0');
            imm_o <= (others => '0');
            cond_o <= '0';
            aluout_o <= (others => '0');
            lmd_o <= (others => '0');
            wb_o <= (others => '0');
        elsif rising_edge(clk_i) then
            pc_o <= pc_i;
            npc_o <= npc_i;
            ir_o <= ir_i;
            a_o <= a_i;
            b_o <= b_i;
            imm_o <= imm_i;
            cond_o <= cond_i;
            aluout_o <= aluout_i;
            lmd_o <= lmd_i;
            wb_o <= wb_i;
        end if;
    end process;
end behav;
