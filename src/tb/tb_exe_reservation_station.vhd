library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;
use work.tb_exe_reservation_station_pkg.all;

entity tb_exe_reservation_station is
end tb_exe_reservation_station;

architecture test of tb_exe_reservation_station is
    component exe_reservation_station is
        generic (
            nbit: integer := 32
        );
        port (
            clk_i:   in  std_logic;
            reset_i: in  std_logic;
            flush_i: in  std_logic;
            full_o:  out std_logic;
            insert_i:   in std_logic;
            rs_entry_i: in exe_rs_instruction_data_t;
            exe_stall_i:     in  std_logic;
            exe_enable_o:    out std_logic; -- insert instruction in the execution unit
            exe_rob_id_o:    out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
            exe_source1_o:   out std_logic_vector(nbit-1 downto 0);
            exe_source2_o:   out std_logic_vector(nbit-1 downto 0);
            exe_operation_o: out std_logic_vector(clog2(max_operations)-1 downto 0);
            insert_result_i: in std_logic;
            cdb_i:           in cdb_t
        );
    end component;
    signal clk:   std_logic;
    signal reset: std_logic;
    signal flush: std_logic;
    signal full:  std_logic;
    signal insert:   std_logic;
    signal rs_entry: exe_rs_instruction_data_t;
    signal exe_stall:     std_logic;
    signal exe_enable:    std_logic;
    signal exe_rob_id:    std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal exe_source1:   std_logic_vector(nbit-1 downto 0);
    signal exe_source2:   std_logic_vector(nbit-1 downto 0);
    signal exe_operation: std_logic_vector(clog2(max_operations)-1 downto 0);
    signal insert_result: std_logic;
    signal cdb:           cdb_t;

    signal simulation_done: boolean := false;
begin
    dut: exe_reservation_station
        generic map (
            nbit => 32
        )
        port map (
            clk_i           => clk,
            reset_i         => reset,
            flush_i         => flush,
            full_o          => full,
            insert_i        => insert,
            rs_entry_i      => rs_entry,
            exe_stall_i     => exe_stall,
            exe_enable_o    => exe_enable,
            exe_rob_id_o    => exe_rob_id,
            exe_source1_o   => exe_source1,
            exe_source2_o   => exe_source2,
            exe_operation_o => exe_operation,
            insert_result_i => insert_result,
            cdb_i           => cdb
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
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        wait for 10 ns; -- time 10 ns
        reset <= '0';
        wait for 10 ns; -- time 20 ns
        insert_instruction_proc(
            rob_id    => 0,
            source1   => 1,
            valid1    => '1',
            source2   => 2,
            valid2    => '0',
            operation => 0,
            reg1      => 0,
            reg2      => 0,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        wait for 10 ns; -- time 30 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        cdb_result_proc(
            rob_id => 0,
            result => 3,
            insert_result_s => insert_result,
            cdb_s => cdb
        );
        wait for 10 ns; -- time 40 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        exe_stall <= '1';

        wait for 10 ns; -- time 50 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );

        wait for 10 ns; -- time 60 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );

        wait for 10 ns; -- time 70 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        insert_instruction_proc(
            rob_id    => 0,
            source1   => 1,
            valid1    => '1',
            source2   => 0,
            valid2    => '0',
            operation => 0,
            reg1      => 0,
            reg2      => 1,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );

        wait for 10 ns; -- time 80 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        insert_instruction_proc(
            rob_id    => 1,
            source1   => 0,
            valid1    => '0',
            source2   => 2,
            valid2    => '1',
            operation => 1,
            reg1      => 2,
            reg2      => 0,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );

        wait for 10 ns; -- time 90 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        insert_instruction_proc(
            rob_id    => 2,
            source1   => 3,
            valid1    => '1',
            source2   => 0,
            valid2    => '0',
            operation => 2,
            reg1      => 0,
            reg2      => 3,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );

        wait for 10 ns; -- time 100 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        insert_instruction_proc(
            rob_id    => 3,
            source1   => 4,
            valid1    => '1',
            source2   => 0,
            valid2    => '0',
            operation => 3,
            reg1      => 0,
            reg2      => 4,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );
        
        wait for 10 ns; -- time 110 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        insert_instruction_proc(
            rob_id    => 4,
            source1   => 5,
            valid1    => '1',
            source2   => 0,
            valid2    => '0',
            operation => 4,
            reg1      => 0,
            reg2      => 5,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );

        wait for 10 ns; -- time 120 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        cdb_result_proc(
            rob_id => 4,
            result => 4,
            insert_result_s => insert_result,
            cdb_s => cdb
        );

        wait for 10 ns; -- time 130 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        cdb_result_proc(
            rob_id => 3,
            result => 3,
            insert_result_s => insert_result,
            cdb_s => cdb
        );

        wait for 10 ns; -- time 140 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        cdb_result_proc(
            rob_id => 2,
            result => 2,
            insert_result_s => insert_result,
            cdb_s => cdb
        );
        insert_instruction_proc(
            rob_id    => 4,
            source1   => 5,
            valid1    => '1',
            source2   => 0,
            valid2    => '0',
            operation => 4,
            reg1      => 0,
            reg2      => 5,
            insert_instruction_s => insert,
            rs_entry_s           => rs_entry
        );

        wait for 10 ns; -- time 150 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );
        cdb_result_proc(
            rob_id => 1,
            result => 1,
            insert_result_s => insert_result,
            cdb_s => cdb
        );

        wait for 10 ns; -- time 160 ns
        clean_inputs_proc(
            flush_s         => flush,
            insert_s        => insert,
            exe_stall_s     => exe_stall,
            insert_result_s => insert_result
        );

        wait for 10 ns; -- time 170 ns

        wait for 10 ns; -- time 180 ns

        wait for 10 ns; -- time 190 ns

        wait for 10 ns;
        simulation_done <= true;
        wait;
        
    end process test_proc;
end test;