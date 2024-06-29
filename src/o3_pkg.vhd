library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

package o3_pkg is
    constant n_reservation_station: integer := 4;
    constant n_entries_rs: integer := 4;
    constant n_entries_rob: integer := 16;
    type instruction_t is (jump, branch, load, store, to_reg);
    type rob_decoded_instruction is record
        instruction_type: instruction_t;
        reservation_station: std_logic_vector(clog2(n_reservation_station) downto 0);
        rs_index: std_logic_vector(clog2(n_entries_rs) downto 0);
        destination: std_logic_vector(nbit-1 downto 0); -- either register or memory address
    end record rob_decoded_instruction;
    type cdb_t is record
        result: std_logic_vector(nbit-1 downto 0);
        reservation_station: std_logic_vector(clog2(n_reservation_station) downto 0);
        rs_index: std_logic_vector(clog2(n_entries_rs) downto 0);
    end record cdb_t;
    type rob_entry is record
        instruction_type:    instruction_t;
        result:              std_logic_vector(nbit-1 downto 0);
        reservation_station: std_logic_vector(clog2(n_reservation_station) downto 0);
        rs_index:            std_logic_vector(clog2(n_entries_rs) downto 0);
        destination:         std_logic_vector(nbit-1 downto 0); -- either register or memory address
        ready:               std_logic;
    end record rob_entry;
end o3_pkg;