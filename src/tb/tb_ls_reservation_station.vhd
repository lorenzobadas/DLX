library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;
use work.tb_ls_reservation_station_pkg.all;

entity tb_ls_reservation_station is
end tb_ls_reservation_station;

architecture test of tb_ls_reservation_station is
    component ls_reservation_station is
        generic (
            nbit: integer := 32
        );
        port (
            clk_i:   in  std_logic;
            reset_i: in  std_logic;
            flush_i: in  std_logic;
            full_o:  out std_logic;
            insert_i:   in std_logic;
            rs_entry_i: in ls_rs_instruction_data_t;
            mem_read_enable_o: out std_logic;
            mem_rob_id_o:      out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
            mem_format_o:      out std_logic_vector(2 downto 0);
            mem_address_o:     out std_logic_vector(nbit-1 downto 0);
            mem_write_enable_o:  out std_logic;
            mem_write_data_o:    out std_logic_vector(nbit-1 downto 0);
            mem_write_address_o: out std_logic_vector(nbit-1 downto 0);
            mem_write_width_o:   out std_logic_vector(1 downto 0);
            lsu_arbiter_load_slot_taken_i: in std_logic;
            lsu_arbiter_load_valid_i:      in std_logic;
            rob_commit_store_i:       in  std_logic;
            rob_commit_store_stall_o: out std_logic;
            insert_result_i: in std_logic;
            cdb_i:           in cdb_t
        );
    end component;
    -- create signals for every input and output of the component
    signal clk:   std_logic;
    signal reset: std_logic;
    signal flush: std_logic;
    signal full:  std_logic;
    signal insert:   std_logic;
    signal rs_entry: ls_rs_instruction_data_t;
    signal mem_read_enable: std_logic;
    signal mem_rob_id:      std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal mem_format:      std_logic_vector(2 downto 0);
    signal mem_address:     std_logic_vector(nbit-1 downto 0);
    signal mem_write_enable:  std_logic;
    signal mem_write_data:    std_logic_vector(nbit-1 downto 0);
    signal mem_write_address: std_logic_vector(nbit-1 downto 0);
    signal mem_write_width:   std_logic_vector(1 downto 0);
    signal lsu_arbiter_load_slot_taken: std_logic;
    signal lsu_arbiter_load_valid:      std_logic;
    signal rob_commit_store:       std_logic;
    signal rob_commit_store_stall: std_logic;
    signal insert_result: std_logic;
    signal cdb:           cdb_t;

    signal simulation_done: boolean := false;
begin

    dut: ls_reservation_station
        generic map (
            nbit => 32
        )
        port map (
            clk_i   => clk,
            reset_i => reset,
            flush_i => flush,
            full_o  => full,
            insert_i   => insert,
            rs_entry_i => rs_entry,
            mem_read_enable_o => mem_read_enable,
            mem_rob_id_o      => mem_rob_id,
            mem_format_o      => mem_format,
            mem_address_o     => mem_address,
            mem_write_enable_o => mem_write_enable,
            mem_write_data_o   => mem_write_data,
            mem_write_address_o => mem_write_address,
            mem_write_width_o   => mem_write_width,
            lsu_arbiter_load_slot_taken_i => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_i => lsu_arbiter_load_valid,
            rob_commit_store_i => rob_commit_store,
            rob_commit_store_stall_o => rob_commit_store_stall,
            insert_result_i => insert_result,
            cdb_i => cdb
        );


    clk_proc: process
    begin
        if not simulation_done then
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        else
            wait;
        end if;
    end process;

    -- test process
    test_proc: process
    begin
        reset <= '1';
        -- initialize all dut inputs
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );
        wait for 10 ns; -- time 10 ns
        reset <= '0';
        wait for 10 ns; -- time 20 ns
        -- insert load instruction
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   0    |   0    |   1    |   0    |   0    |     5     |     0     |      2      |     0      |  3   |  3   |     0      |  1   |
        --------------------------------------------------------------------------------------------------------------------------------------
        insert_instruction_proc(
            rob_id               => 0,
            value1               => 0,
            valid1               => '1',
            value2               => 0,
            valid2               => '0',
            immediate            => 5,
            operation            => '0',
            width_field          => 2,
            sign_field           => '0',
            reg1                 => 3,
            reg2                 => 3,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        wait for 10 ns; -- time 30 ns
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );
        -- insert result from cdb
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   0    |   0    |   1    |   10   |   1    |     5     |     0     |      2      |     0      |  3   |  3   |     0      |  1   |
        --------------------------------------------------------------------------------------------------------------------------------------
        cdb_result_proc(
            rob_id          => 3,
            result          => 5,
            insert_result_s => insert_result,
            cdb_s           => cdb
        );
        wait for 10 ns; -- time 40 ns
        -- load should be sent to memory
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );

        wait for 10 ns; -- time 50 ns
        lsu_arbiter_load_valid <= '1';
        lsu_arbiter_load_slot_taken <= '1';

        wait for 10 ns; -- time 60 ns
        -- ls reservation station should be empty
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );

        -- insert store instruction
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   1    |   0    |   1    |   0    |   0    |     4     |     1     |      2      |     0      |  2   |  3   |     0      |  1   |
        --------------------------------------------------------------------------------------------------------------------------------------
        insert_instruction_proc(
            rob_id               => 1,
            value1               => 0,
            valid1               => '1',
            value2               => 0,
            valid2               => '0',
            immediate            => 4,
            operation            => '1', -- store
            width_field          => 1,
            sign_field           => '0',
            reg1                 => 2,
            reg2                 => 3,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        wait for 10 ns; -- time 70 ns
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );

        -- insert store instruction
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   1    |   0    |   1    |  144   |   1    |     4     |     1     |      2      |     0      |  2   |  0   |     0      |  1   |
        --------------------------------------------------------------------------------------------------------------------------------------
        insert_instruction_proc(
            rob_id               => 1,
            value1               => 0,
            valid1               => '1',
            value2               => 144,
            valid2               => '1',
            immediate            => 4,
            operation            => '1', -- store
            width_field          => 1,
            sign_field           => '0',
            reg1                 => 2,
            reg2                 => 0,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        wait for 10 ns; -- time 80 ns
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );
        -- insert load instruction
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   2    |   0    |   1    |   0    |   0    |     3     |     0     |      2      |     0      |  3   |  3   |     1      |  1   |
        --------------------------------------------------------------------------------------------------------------------------------------
        insert_instruction_proc(
            rob_id               => 2,
            value1               => 0,
            valid1               => '1',
            value2               => 5,
            valid2               => '1',
            immediate            => 3,
            operation            => '0', -- load
            width_field          => 0,
            sign_field           => '0',
            reg1                 => 3,
            reg2                 => 3,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        rob_commit_store <= '1';
        wait for 10 ns; -- time 90 ns
        -- load should not be sent to memory since the address of the store is not ready
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );
        -- insert load instruction
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   3    |   0    |   1    |   10   |   1    |     5     |     0     |      2      |     0      |  3   |  3   |     0      |  1   |
        --------------------------------------------------------------------------------------------------------------------------------------
        insert_instruction_proc(
            rob_id               => 3,
            value1               => 0,
            valid1               => '1',
            value2               => 10,
            valid2               => '1',
            immediate            => 5,
            operation            => '0', -- load
            width_field          => 0,
            sign_field           => '0',
            reg1                 => 3,
            reg2                 => 3,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        -- insert result from cdb
        --------------------------------------------------------------------------------------------------------------------------------------
        -- | ROB ID | VALUE1 | VALID1 | VALUE2 | VALID2 | IMMEDIATE | OPERATION | WIDTH_FIELD | SIGN_FIELD | REG1 | REG2 | WAIT_STORE | BUSY |
        -- |   1    |   0    |   1    |   4    |   1    |     4     |     1     |      2      |     0      |  2   |  3   |     0      |  1   |
        -- |   2    |   0    |   1    |   3    |   1    |     3     |     0     |      2      |     0      |  3   |  3   |     0      |  1   |
        -- |   3    |   0    |   1    |   10   |   1    |     5     |     0     |      2      |     0      |  3   |  3   |     0      |  1   |
        cdb_result_proc(
            rob_id          => 3,
            result          => 0,
            insert_result_s => insert_result,
            cdb_s           => cdb
        );

        wait for 10 ns; -- time 100 ns
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );

        wait for 10 ns; -- time 110 ns
        lsu_arbiter_load_valid  <= '1';
        rob_commit_store <= '1';

        wait for 10 ns; -- time 120 ns
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );

        wait for 10 ns; -- time 130 ns
        clean_inputs_proc(
            flush_s                       => flush,
            insert_s                      => insert,
            lsu_arbiter_load_slot_taken_s => lsu_arbiter_load_slot_taken,
            lsu_arbiter_load_valid_s      => lsu_arbiter_load_valid,
            rob_commit_store_s            => rob_commit_store,
            insert_result_s               => insert_result
        );
        wait for 10 ns; -- time 140 ns
        wait for 10 ns; -- time 150 ns
        lsu_arbiter_load_valid <= '1';

        wait for 10 ns; -- time 160 ns
        wait for 10 ns; -- time 170 ns
        wait for 10 ns; -- time 180 ns

        simulation_done <= true;
        wait;
        
    end process test_proc;
end test;