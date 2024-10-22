library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

package tb_ls_reservation_station_pkg is

    procedure insert_instruction_proc (
        rob_id:      integer;
        value1:      integer;
        valid1:      std_logic;
        value2:      integer;
        valid2:      std_logic;
        immediate:   integer;
        operation:   std_logic; -- 0 is load, 1 is store
        width_field: integer; -- 0 is byte, 1 is half, 2 is word
        sign_field:  std_logic; -- 0 is signed, 1 is unsigned
        reg1:        integer;
        reg2:        integer;

        signal insert_instruction_s: out std_logic;
        signal rs_entry_s:           out ls_rs_instruction_data_t
    );
    procedure clean_inputs_proc (
        signal flush_s:                   out std_logic;
        signal insert_s:                  out std_logic;
        signal lsu_arbiter_load_valid_s:  out std_logic;
        signal lsu_arbiter_store_valid_s: out std_logic;
        signal rob_commit_store_s:        out std_logic;
        signal insert_result_s:           out std_logic
    );
    procedure cdb_result_proc (
        rob_id: integer;
        result: integer;
        signal insert_result_s: out std_logic;
        signal cdb_s:           out cdb_t
    );
    
end tb_ls_reservation_station_pkg;

package body tb_ls_reservation_station_pkg is

    procedure insert_instruction_proc (
        rob_id:      integer;
        value1:      integer;
        valid1:      std_logic;
        value2:      integer;
        valid2:      std_logic;
        immediate:   integer;
        operation:   std_logic; -- 0 is load, 1 is store
        width_field: integer; -- 0 is byte, 1 is half, 2 is word
        sign_field:  std_logic; -- 0 is signed, 1 is unsigned
        reg1:        integer;
        reg2:        integer;

        signal insert_instruction_s: out std_logic;
        signal rs_entry_s:           out ls_rs_instruction_data_t
    ) is
    begin
        insert_instruction_s   <= '1';
        rs_entry_s.rob_id      <= std_logic_vector(to_unsigned(rob_id, clog2(n_entries_rob)));
        rs_entry_s.source1     <= std_logic_vector(to_unsigned(value1, nbit));
        rs_entry_s.valid1      <= valid1;
        rs_entry_s.source2     <= std_logic_vector(to_unsigned(value2, nbit));
        rs_entry_s.valid2      <= valid2;
        rs_entry_s.immediate   <= std_logic_vector(to_unsigned(immediate, nbit));
        rs_entry_s.operation   <= operation;
        rs_entry_s.width_field <= std_logic_vector(to_unsigned(width_field, 2));
        rs_entry_s.sign_field  <= sign_field;
        rs_entry_s.reg1        <= std_logic_vector(to_unsigned(reg1, clog2(n_entries_rob)));
        rs_entry_s.reg2        <= std_logic_vector(to_unsigned(reg2, clog2(n_entries_rob)));
    end insert_instruction_proc;

    procedure clean_inputs_proc (
        signal flush_s:                   out std_logic;
        signal insert_s:                  out std_logic;
        signal lsu_arbiter_load_valid_s:  out std_logic;
        signal lsu_arbiter_store_valid_s: out std_logic;
        signal rob_commit_store_s:        out std_logic;
        signal insert_result_s:           out std_logic
    ) is
    begin
        flush_s                   <= '0';
        insert_s                  <= '0';
        lsu_arbiter_load_valid_s  <= '0';
        lsu_arbiter_store_valid_s <= '0';
        rob_commit_store_s        <= '0';
        insert_result_s           <= '0';
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

end tb_ls_reservation_station_pkg;