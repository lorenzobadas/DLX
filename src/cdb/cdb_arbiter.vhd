library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

-- Hardwired CDB arbiter giving the following priorities:
-- 1. LSU
-- 2. MULT
-- 3. ALU
entity cdb_arbiter is
    generic (
        nbit: integer := 32
    );
    port (
        lsu_result_i:  in  cdb_t;
        lsu_valid_i:   in  std_logic;
        lsu_ack_o:     out std_logic;
        mult_result_i: in  cdb_t;
        mult_valid_i:  in  std_logic;
        mult_ack_o:    out std_logic;
        alu_result_i:  in  cdb_t;
        alu_valid_i:   in  std_logic;
        alu_ack_o:     out std_logic;
        cdb_result_o:  out cdb_t;
        cdb_valid_o:   out std_logic
    );
end entity;

architecture beh of cdb_arbiter is
begin
    process(lsu_result_i, lsu_valid_i, alu_result_i, alu_valid_i, mult_result_i, mult_valid_i)
    begin
        if lsu_valid_i = '1' then
            cdb_result_o <= lsu_result_i;
            lsu_ack_o <= '1';
            mult_ack_o <= '0';
            alu_ack_o <= '0';
            cdb_valid_o <= '1';
        elsif mult_valid_i = '1' then
            cdb_result_o <= mult_result_i;
            lsu_ack_o <= '0';
            mult_ack_o <= '1';
            alu_ack_o <= '0';
            cdb_valid_o <= '1';
        elsif alu_valid_i = '1' then
            cdb_result_o <= alu_result_i;
            lsu_ack_o <= '0';
            mult_ack_o <= '0';
            alu_ack_o <= '1';
            cdb_valid_o <= '1';
        else
            cdb_result_o <= (others => '0');
            lsu_ack_o <= '0';
            mult_ack_o <= '0';
            alu_ack_o <= '0';
            cdb_valid_o <= '0';
        end if;
    end process;
end beh;
