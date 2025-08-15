library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_regs is
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        pc_i:       in  std_logic_vector(31 downto 0);
        next_npc_i:  in  std_logic_vector(31 downto 0);
        next_ir_i:       in  std_logic_vector(31 downto 0);
        pc_o:       out std_logic_vector(31 downto 0);
        next_npc_o:      out std_logic_vector(31 downto 0);
        next_ir_o:       out std_logic_vector(31 downto 0)
    );
end pipeline_regs;

architecture behav of pipeline_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            pc_o <= (others => '0');
            next_npc_o <= (others => '0');
            next_ir_o <= (others => '0');
        elsif rising_edge(clk_i) then
            pc_o <= pc_i;
            next_npc_o <= next_npc_i;
            next_ir_o <= next_ir_i;
        end if;
    end process;
end behav;
