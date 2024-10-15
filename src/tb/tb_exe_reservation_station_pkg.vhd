library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

package tb_exe_reservation_station_pkg is

    procedure insert_instruction_proc (
        rob_id:    integer;
        source1:   integer;
        valid1:    std_logic;
        source2:   integer;
        valid2:    std_logic;
        operation: integer;
        reg1:      integer;
        reg2:      integer;

        signal insert_instruction_s: out std_logic;
        signal rs_entry_s:           out exe_rs_instruction_data_t
    );
    procedure clean_inputs_proc (
        signal flush_s:         out std_logic;
        signal insert_s:        out std_logic;
        signal exe_stall_s:       out std_logic;
        signal insert_result_s: out std_logic
    );
    procedure cdb_result_proc (
        rob_id: integer;
        result: integer;
        signal insert_result_s: out std_logic;
        signal cdb_s:           out cdb_t
    );
    
end tb_exe_reservation_station_pkg;

package body tb_exe_reservation_station_pkg is

    procedure insert_instruction_proc (
        rob_id:    integer;
        source1:   integer;
        valid1:    std_logic;
        source2:   integer;
        valid2:    std_logic;
        operation: integer;
        reg1:      integer;
        reg2:      integer;

        signal insert_instruction_s: out std_logic;
        signal rs_entry_s:           out exe_rs_instruction_data_t
    ) is
    begin
        insert_instruction_s   <= '1';
        rs_entry_s.rob_id      <= std_logic_vector(to_unsigned(rob_id, clog2(n_entries_rob)));
        rs_entry_s.source1     <= std_logic_vector(to_unsigned(source1, nbit));
        rs_entry_s.valid1      <= valid1;
        rs_entry_s.source2     <= std_logic_vector(to_unsigned(source2, nbit));
        rs_entry_s.valid2      <= valid2;
        rs_entry_s.operation   <= std_logic_vector(to_unsigned(operation, clog2(max_operations)));
        rs_entry_s.reg1        <= std_logic_vector(to_unsigned(reg1, clog2(n_entries_rob)));
        rs_entry_s.reg2        <= std_logic_vector(to_unsigned(reg2, clog2(n_entries_rob)));
    end insert_instruction_proc;

    procedure clean_inputs_proc (
        signal flush_s:         out std_logic;
        signal insert_s:        out std_logic;
        signal exe_stall_s:       out std_logic;
        signal insert_result_s: out std_logic
    ) is
    begin
        flush_s         <= '0';
        insert_s        <= '0';
        exe_stall_s     <= '0';
        insert_result_s <= '0';
    end clean_inputs_proc;

    procedure cdb_result_proc (
        rob_id: integer;
        result: integer;
        signal insert_result_s: out std_logic;
        signal cdb_s:           out cdb_t
    ) is
    begin
        insert_result_s <= '1';
        cdb_s.result    <= std_logic_vector(to_unsigned(result, nbit));
        cdb_s.rob_index <= std_logic_vector(to_unsigned(rob_id, clog2(n_entries_rob)));
    end cdb_result_proc;

end tb_exe_reservation_station_pkg;