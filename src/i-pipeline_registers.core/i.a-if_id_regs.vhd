library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_instr_pkg.all;

entity if_id_regs is
    generic(
        nbit : integer := 32
    );
    port (
        clk_i    : in  std_logic;
        reset_i  : in  std_logic;
        enable_i : in  std_logic;
        flush_i  : in  std_logic;
        npc_i    : in  std_logic_vector(nbit-1 downto 0);
        instr_i  : in  std_logic_vector(nbit-1 downto 0);
        npc_o    : out std_logic_vector(nbit-1 downto 0);
        instr_o  : out std_logic_vector(nbit-1 downto 0)
    );
end if_id_regs;

architecture behav of if_id_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            npc_o <= (others => '0');
            instr_o <= (others => '0');
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                npc_o <= (others => '0');
                instr_o <= (others => '0');
            elsif enable_i = '1' then
                npc_o <= npc_i;
                instr_o <= instr_i;
            end if;
        end if;
    end process;
end behav;
