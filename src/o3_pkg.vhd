library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

package o3_pkg is
    constant n_reservation_station: integer := 4;
    constant n_entries_rs:          integer := 4;
    constant n_entries_rob:         integer := 4;
    constant n_entries_bpu:         integer := 64;

    type instruction_t is (jump, branch, load, store, to_reg);

    type rob_decoded_instruction is record
        instruction_type:     instruction_t;
        instruction_address:  std_logic_vector(nbit-1 downto 0);
        branch_taken:         std_logic;
        destination:          std_logic_vector(nbit-1 downto 0); -- either register or memory address
        branch_taken_address: std_logic_vector(nbit-1 downto 0);
        bpu_history:          std_logic_vector(1 downto 0);
    end record rob_decoded_instruction;

    type cdb_t is record
        result:       std_logic_vector(nbit-1 downto 0);
        rob_index:    std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    end record cdb_t;
    
    type rat_entry is record
        physical: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        valid:    std_logic;
    end record rat_entry;
    
    type rob_branch_result is record
    branch_taken:  std_logic;
    address:       std_logic_vector(nbit-1 downto 0);
    taken_address: std_logic_vector(nbit-1 downto 0);
    history:       std_logic_vector(1 downto 0);
    valid:         std_logic;
    end record rob_branch_result;

    type branch_data_t is record
        branch_taken:   std_logic;
        branch_address: std_logic_vector(nbit-1 downto 0); -- used to update BPU and PC
        taken_address:  std_logic_vector(nbit-1 downto 0); -- used to update PC
        history:        std_logic_vector(1 downto 0);
    end record branch_data_t;
    
    type rob_entry is record
        instruction_type: instruction_t;
        result:           std_logic_vector(nbit-1 downto 0);
        destination:      std_logic_vector(nbit-1 downto 0); -- either register or memory address
        branch_data:      branch_data_t;
        ready:            std_logic; -- ready if result is available
    end record rob_entry;
end o3_pkg;