library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_ex_regs is
    generic(
        nbit: integer := 32
    );
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        pc_i:       in  std_logic_vector(nbit-1 downto 0);
        npc_i:      in  std_logic_vector(nbit-1 downto 0);
        rdata1_i:   in  std_logic_vector(nbit-1 downto 0);
        rdata2_i:   in  std_logic_vector(nbit-1 downto 0);
        imm_i:      in  std_logic_vector(nbit-1 downto 0);
        wbdata_i:    in  std_logic_vector(nbit-1 downto 0);
        rdest_i_type_i: in std_logic_vector(4 downto 0);
        rdest_r_type_i: in std_logic_vector(4 downto 0);
        pc_o:       out std_logic_vector(nbit-1 downto 0);
        npc_o:      out std_logic_vector(nbit-1 downto 0);
        rdata1_o:   out std_logic_vector(nbit-1 downto 0);
        rdata2_o:   out std_logic_vector(nbit-1 downto 0);
        imm_o:      out std_logic_vector(nbit-1 downto 0);
        wbdata_o:    out std_logic_vector(nbit-1 downto 0);
        rdest_i_type_o: out std_logic_vector(4 downto 0);
        rdest_r_type_o: out std_logic_vector(4 downto 0)
    );
end id_ex_regs;

architecture behav of id_ex_regs is
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            pc_o <= (others => '0');
            npc_o <= (others => '0');
            rdata1_o <= (others => '0');
            rdata2_o <= (others => '0');
            imm_o <= (others => '0');
            wbdata_o <= (others => '0');
            rdest_i_type_o <= (others => '0');
            rdest_r_type_o <= (others => '0');
        elsif rising_edge(clk_i) then
            pc_o <= pc_i;
            npc_o <= npc_i;
            rdata1_o <= rdata1_i;
            rdata2_o <= rdata2_i;
            imm_o <= imm_i;
            wbdata_o <= wbdata_i;
            rdest_i_type_o <= rdest_i_type_i;
            rdest_r_type_o <= rdest_r_type_i;
        end if;
    end process;
end behav;
