library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity tb_reservation_station is
end tb_reservation_station;

architecture test of tb_reservation_station is
    component reservation_station is
        generic (
            nbit: integer := 32;
            in_order: boolean := false
        );
        port (
            clk_i:   in  std_logic;
            reset_i: in  std_logic;
            flush_i: in  std_logic;
            full_o:  out std_logic;
            insert_i:   in std_logic;
            rs_entry_i: in rs_entry_t;
            exe_stall_i:     in  std_logic;
            exe_enable_o:    out std_logic; -- insert instruction in the execution unit
            exe_rob_id_o:    out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
            exe_source1_o:   out std_logic_vector(nbit-1 downto 0);
            exe_source2_o:   out std_logic_vector(nbit-1 downto 0);
            exe_operation_o: out std_logic_vector(clog2(max_operations)-1 downto 0);
            insert_result_i: in std_logic;
            cdb_i: in cdb_t
        );
    end component;
    signal clk: std_logic;
    signal reset: std_logic;
    signal flush: std_logic;
    signal full: std_logic;
    signal insert: std_logic;
    signal rs_entry: rs_entry_t;
    signal exe_stall: std_logic;
    signal exe_enable: std_logic;
    signal exe_rob_id: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal exe_source1: std_logic_vector(nbit-1 downto 0);
    signal exe_source2: std_logic_vector(nbit-1 downto 0);
    signal exe_operation: std_logic_vector(clog2(max_operations)-1 downto 0);
    signal insert_result: std_logic;
    signal cdb: cdb_t;
begin
    dut: reservation_station
        generic map (
            nbit => 32,
            in_order => false
        )
        port map (
            clk_i => clk,
            reset_i => reset,
            flush_i => flush,
            full_o => full,
            insert_i => insert,
            rs_entry_i => rs_entry,
            exe_stall_i => exe_stall,
            exe_enable_o => exe_enable,
            exe_rob_id_o => exe_rob_id,
            exe_source1_o => exe_source1,
            exe_source2_o => exe_source2,
            exe_operation_o => exe_operation,
            insert_result_i => insert_result,
            cdb_i => cdb
        );
    
    clk_proc: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- test process
    test_proc: process
    begin
        reset <= '1';
        -- initialize all dut inputs
        flush <= '0';
        insert <= '0';
        rs_entry.rob_id <= (others => '0');
        rs_entry.source1 <= (others => '0');
        rs_entry.valid1 <= '0';
        rs_entry.source2 <= (others => '0');
        rs_entry.valid2 <= '0';
        rs_entry.operation <= (others => '0');
        rs_entry.reg1 <= (others => '0');
        rs_entry.reg2 <= (others => '0');
        exe_stall <= '0';
        insert_result <= '0';
        cdb.result <= (others => '0');
        cdb.rob_index <= (others => '0');
        wait for 10 ns; -- time 10 ns
        reset <= '0';
        wait for 10 ns; -- time 20 ns
        
        wait;
        
    end process test_proc;
end test;