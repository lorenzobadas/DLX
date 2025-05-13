library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity f_d_pipeline_registers is
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        flush_i:    in  std_logic;
        pc_i:       in  std_logic_vector(31 downto 0);
        instr_i:    in  std_logic_vector(31 downto 0);
        bp_i:       in  std_logic; 
        pc_o:       out std_logic_vector(31 downto 0);
        instr_o:    out std_logic_vector(31 downto 0);
        bp_o:       out std_logic
    );
end f_d_pipeline_registers;

architecture bahav of f_d_pipeline_registers is
    signal pc_reg:  std_logic_vector(31 downto 0);
    signal instr_reg: std_logic_vector(31 downto 0);
    signal bp_reg:  std_logic;
begin
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then 
            pc_reg    <= (others => '0');
            instr_reg <= (others => '0');
            bp_reg    <= '0';
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                pc_reg    <= (others => '0');
                instr_reg <= (others => '0');
                bp_reg    <= '0';
            else
                pc_reg    <= pc_i;
                instr_reg <= instr_i;
                bp_reg    <= bp_i;
            end if;
        end if;
    end process;

    pc_o    <= pc_reg;
    instr_o <= instr_reg;
    bp_o    <= bp_reg;
end bahav;
