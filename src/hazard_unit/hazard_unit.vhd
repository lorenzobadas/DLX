library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity hazard_unit is
    port (
        -- Inputs
        ex_memToReg_i : in  std_logic; -- Instruction is a load
        ex_rdest_i    : in  std_logic_vector(4 downto 0);
        id_rs1_i      : in  std_logic_vector(4 downto 0);
        id_rs2_i      : in  std_logic_vector(4 downto 0);
        id_regDest_i  : in  std_logic; -- Instruction is R-type (uses rs2 as source)
        id_PCSrc_i   : in  std_logic; -- Branch taken
        -- Outputs
        pc_write_o    : out std_logic;
        if_id_write_o : out std_logic;
        if_id_flush_o : out std_logic;
        id_ex_nop_o   : out std_logic
    );
end entity hazard_unit;

architecture beh of hazard_unit is
begin
    process(ex_memToReg_i, ex_rdest_i, id_rs1_i, id_rs2_i, id_regDest_i, id_PCSrc_i)
    begin
        -- Default values: no stall
        pc_write_o <= '1';
        if_id_write_o <= '1';
        if_id_flush_o <= '0';
        id_ex_nop_o <= '0';

        if (ex_memToReg_i = '1' and
            ((ex_rdest_i = id_rs1_i) or
            ((id_regDest_i = '1') and
            (ex_rdest_i = id_rs2_i)))) then
            -- Load-use hazard detected
            -- Disable PC
            -- Disable IF/ID register bank
            -- Insert NOP in ID/EX register bank
            pc_write_o <= '0';
            if_id_write_o <= '0';
            id_ex_nop_o <= '1';
        elsif (id_PCSrc_i = '1') then
            -- Branch taken
            -- Flush IF/ID register bank
            if_id_flush_o <= '1';
        end if;
    end process;
end architecture beh;