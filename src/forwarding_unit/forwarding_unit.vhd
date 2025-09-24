library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity forwarding_unit is
    port (
        ex_mem_regwrite_i : in  std_logic;
        mem_wb_regwrite_i : in  std_logic;
        ex_mem_rd_i       : in  std_logic_vector(4 downto 0);
        mem_wb_rd_i       : in  std_logic_vector(4 downto 0);
        id_ex_rs1_i       : in  std_logic_vector(4 downto 0);
        id_ex_rs2_i       : in  std_logic_vector(4 downto 0);
        forwardA_o        : out std_logic_vector(1 downto 0);
        forwardB_o        : out std_logic_vector(1 downto 0)
    );
end entity;

architecture struct of forwarding_unit is
begin
    process(ex_mem_rd_i, mem_wb_rd_i, id_ex_rs1_i, id_ex_rs2_i)
    begin
        forwardA_o <= "00";
        forwardB_o <= "00";

        -- RS1 forwarding logic
        if (ex_mem_regwrite_i = '1') and (ex_mem_rd_i /= "00000") and (ex_mem_rd_i = id_ex_rs1_i) then
            forwardA_o <= "10";  -- Forward from EX/MEM
        elsif (mem_wb_regwrite_i = '1') and (mem_wb_rd_i /= "00000") and (mem_wb_rd_i = id_ex_rs1_i) then
            forwardA_o <= "01";  -- Forward from MEM/WB
        end if;

        -- RS2 forwarding logic
        if (ex_mem_regwrite_i = '1') and (ex_mem_rd_i /= "00000") and (ex_mem_rd_i = id_ex_rs2_i) then
            forwardB_o <= "10";  -- Forward from EX/MEM
        elsif (mem_wb_regwrite_i = '1') and (mem_wb_rd_i /= "00000") and (mem_wb_rd_i = id_ex_rs2_i) then
            forwardB_o <= "01";  -- Forward from MEM/WB
        end if;
    end process;
end architecture;