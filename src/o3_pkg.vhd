library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

package o3_pkg is
    constant n_entries_rs:          integer := 4;
    constant n_operations_alu:      integer := 1;
    constant n_operations_mult:     integer := 1;
    constant n_operations_lsu:      integer := 2;
    constant max_operations:        integer := max(n_operations_alu, n_operations_mult);
    constant n_entries_rob:         integer := 4;
    constant n_entries_bpu:         integer := 64;

    type commit_option_t is (none, branch, to_mem, to_rf);

    type rob_decoded_instruction_t is record
        instruction_type:     commit_option_t;
        instruction_address:  std_logic_vector(nbit-1 downto 0);
        branch_taken:         std_logic;
        destination:          std_logic_vector(nbit-1 downto 0); -- either register or memory address
        width_field:          std_logic_vector(1 downto 0); -- 0: byte, 1: half, 2: word
        branch_taken_address: std_logic_vector(nbit-1 downto 0);
        bpu_history:          std_logic_vector(1 downto 0);
    end record rob_decoded_instruction_t;

    type cdb_t is record
        result:       std_logic_vector(nbit-1 downto 0);
        destination:  std_logic_vector(nbit-1 downto 0);
        rob_index:    std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    end record cdb_t;
    
    type rat_entry_t is record
        physical: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        valid:    std_logic;
    end record rat_entry_t;
    
    type rob_branch_result_t is record
    branch_taken:  std_logic;
    address:       std_logic_vector(nbit-1 downto 0);
    taken_address: std_logic_vector(nbit-1 downto 0);
    history:       std_logic_vector(1 downto 0);
    valid:         std_logic;
    end record rob_branch_result_t;

    type branch_data_t is record
        branch_taken:   std_logic;
        branch_address: std_logic_vector(nbit-1 downto 0); -- used to update BPU and PC
        taken_address:  std_logic_vector(nbit-1 downto 0); -- used to update PC
        history:        std_logic_vector(1 downto 0);
    end record branch_data_t;
    
    type rob_entry_t is record
        instruction_type: commit_option_t;
        result:           std_logic_vector(nbit-1 downto 0);
        destination:      std_logic_vector(nbit-1 downto 0); -- either register or memory address
        width_field:      std_logic_vector(1 downto 0); -- 0: byte, 1: half, 2: word
        branch_data:      branch_data_t;
        ready:            std_logic; -- ready if result is available
    end record rob_entry_t;

    type exe_rs_entry_t is record
        rob_id: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        source1: std_logic_vector(nbit-1 downto 0);
        valid1: std_logic;
        source2: std_logic_vector(nbit-1 downto 0);
        valid2: std_logic;
        operation: std_logic_vector(clog2(max_operations)-1 downto 0);
        reg1: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        reg2: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        busy: std_logic;
    end record exe_rs_entry_t;

    type ls_rs_entry_t is record
        rob_id: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        source1: std_logic_vector(nbit-1 downto 0);
        valid1: std_logic;
        source2: std_logic_vector(nbit-1 downto 0);
        valid2: std_logic;
        immediate: std_logic_vector(nbit-1 downto 0);
        operation: std_logic; -- load & store
        width_field: std_logic_vector(1 downto 0); -- 0: byte, 1: half, 2: word
        sign_field: std_logic; -- 0: signed, 1: unsigned
        reg1: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        reg2: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        wait_instr: std_logic;
        wait_store: std_logic;
        busy: std_logic;
    end record ls_rs_entry_t;
    
    type ls_rs_instruction_data_t is record
        rob_id: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        source1: std_logic_vector(nbit-1 downto 0);
        valid1: std_logic;
        source2: std_logic_vector(nbit-1 downto 0);
        valid2: std_logic;
        immediate: std_logic_vector(nbit-1 downto 0);
        operation: std_logic; -- load & store
        width_field: std_logic_vector(1 downto 0); -- 0: byte, 1: half, 2: word
        sign_field: std_logic; -- 0: signed, 1: unsigned
        reg1: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        reg2: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    end record ls_rs_instruction_data_t;

    type reservation_station_t is (lsu, alu, mult, none);
end o3_pkg;