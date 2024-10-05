library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity exe_reservation_station is
    generic (
        nbit: integer := 32
    );
    port (
        clk_i:   in  std_logic;
        reset_i: in  std_logic;
        flush_i: in  std_logic;
        full_o:  out std_logic;

        -- Issue Interface
        insert_i:   in std_logic;
        rs_entry_i: in exe_rs_entry_t;
        
        -- Execution unit interface
        exe_stall_i:     in  std_logic;
        exe_enable_o:    out std_logic; -- insert instruction in the execution unit
        exe_rob_id_o:    out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        exe_source1_o:   out std_logic_vector(nbit-1 downto 0);
        exe_source2_o:   out std_logic_vector(nbit-1 downto 0);
        exe_operation_o: out std_logic_vector(clog2(max_operations)-1 downto 0);
        
        -- CDB interface
        insert_result_i: in std_logic;
        cdb_i: in cdb_t
    );
end entity;

architecture beh of exe_reservation_station is
    type state_t is (empty, idle, full);
    type rs_array_t is array(0 to n_entries_rs-1) of exe_rs_entry_t;
    signal state, state_next: state_t;
    signal rs_array, rs_array_next: rs_array_t;
    signal head_ptr, head_ptr_next: unsigned(clog2(n_entries_rs)-1 downto 0);
    signal tail_ptr, tail_ptr_next: unsigned(clog2(n_entries_rs)-1 downto 0);

    procedure insert_instruction (
        signal rs_entry: in exe_rs_entry_t;
        signal head_ptr: in unsigned(clog2(n_entries_rs)-1 downto 0);
        signal rs_array_next: out rs_array_t;
        signal head_ptr_next: out unsigned(clog2(n_entries_rs)-1 downto 0)
    ) is
    begin
        rs_array_next(to_integer(head_ptr)) <= rs_entry;
        head_ptr_next <= head_ptr + 1;
    end procedure insert_instruction;

    procedure send_instruction_to_exe (
        signal rs_array: in rs_array_t;
        signal tail_ptr: in unsigned(clog2(n_entries_rs)-1 downto 0);
        signal exe_enable: out std_logic;
        signal exe_rob_id: out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        signal exe_source1: out std_logic_vector(nbit-1 downto 0);
        signal exe_source2: out std_logic_vector(nbit-1 downto 0);
        signal exe_operation: out std_logic_vector(clog2(max_operations)-1 downto 0);
        signal rs_array_next: out rs_array_t
    ) is
        variable found: boolean := false;
    begin
        for i in 0 to n_entries_rs-1 loop
            if (not found) and
               (rs_array(to_integer(tail_ptr + i)).valid1 = '1') and
               (rs_array(to_integer(tail_ptr + i)).valid2 = '1') and 
               (rs_array(to_integer(tail_ptr + i)).busy = '1')
            then
                found := true;
                exe_enable_o <= '1';
                exe_rob_id_o <= rs_array(to_integer(tail_ptr + i)).rob_id;
                exe_source1_o <= rs_array(to_integer(tail_ptr + i)).source1;
                exe_source2_o <= rs_array(to_integer(tail_ptr + i)).source2;
                exe_operation_o <= rs_array(to_integer(tail_ptr + i)).operation;
                rs_array_next(to_integer(tail_ptr + i)).busy <= '0';
            end if;
        end loop;
    end procedure send_instruction_to_exe;

    procedure insert_result (
        signal rs_array: in rs_array_t;
        signal cdb: in cdb_t;
        signal rs_array_next: out rs_array_t
    ) is
    begin
        for i in 0 to n_entries_rs-1 loop
            if rs_array(i).valid1 = '0' and
               rs_array(i).reg1 = cdb_i.rob_index
            then
                rs_array_next(i).source1 <= cdb_i.result;
                rs_array_next(i).valid1 <= '1';
            end if;
            if rs_array(i).valid2 = '0' and
               rs_array(i).reg2 = cdb_i.rob_index
            then
                rs_array_next(i).source2 <= cdb_i.result;
                rs_array_next(i).valid2 <= '1';
            end if;
        end loop;
    end procedure insert_result;
begin
    comb_proc: process(state, rs_array, head_ptr, tail_ptr, insert_i, rs_entry_i, exe_stall_i, insert_result_i, cdb_i)
        variable execution_index: integer;
        variable execution_found: boolean := false;
    begin
        case state is
            when empty =>
                state_next <= empty;
                full_o <= '0';
                head_ptr_next <= head_ptr;
                tail_ptr_next <= tail_ptr;
                rs_array_next <= rs_array;
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');
                if insert_i = '1' then
                    state_next <= idle;
                    head_ptr_next <= head_ptr + 1;
                    rs_array_next(to_integer(head_ptr)) <= rs_entry_i;
                end if;
            when idle =>
                state_next <= idle;
                full_o <= '0';
                head_ptr_next <= head_ptr;
                tail_ptr_next <= tail_ptr;
                rs_array_next <= rs_array;
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');

                if insert_i = '1' then
                    insert_instruction(
                        rs_entry => rs_entry_i,
                        head_ptr => head_ptr,
                        rs_array_next => rs_array_next,
                        head_ptr_next => head_ptr_next
                    );
                end if;

                if exe_stall_i = '0' then
                    send_instruction_to_exe(
                        rs_array => rs_array,
                        tail_ptr => tail_ptr,
                        exe_enable => exe_enable_o,
                        exe_rob_id => exe_rob_id_o,
                        exe_source1 => exe_source1_o,
                        exe_source2 => exe_source2_o,
                        exe_operation => exe_operation_o,
                        rs_array_next => rs_array_next
                    );
                end if;

                if insert_result_i = '1' then
                    insert_result(
                        rs_array => rs_array,
                        cdb => cdb_i,
                        rs_array_next => rs_array_next
                    );
                end if;
                
                -- update tail_ptr
                if rs_array(to_integer(tail_ptr)).busy = '0' then
                    tail_ptr_next <= tail_ptr + 1;
                end if;

                -- check if the reservation station is full
                if head_ptr = tail_ptr-1 and
                   insert_i = '1' and
                   not(rs_array(to_integer(tail_ptr)).busy = '0')
                then
                    state_next <= full;
                end if;

                -- check if the reservation station is empty
                if head_ptr = tail_ptr+1 and
                   insert_i = '0' and
                   rs_array(to_integer(tail_ptr)).busy = '0'
                then
                    state_next <= empty;
                end if;

            when full =>
                state_next <= full;
                full_o <= '1';
                head_ptr_next <= head_ptr;
                tail_ptr_next <= tail_ptr;
                rs_array_next <= rs_array;
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');

                if exe_stall_i = '0' then
                    send_instruction_to_exe(
                        rs_array => rs_array,
                        tail_ptr => tail_ptr,
                        exe_enable => exe_enable_o,
                        exe_rob_id => exe_rob_id_o,
                        exe_source1 => exe_source1_o,
                        exe_source2 => exe_source2_o,
                        exe_operation => exe_operation_o,
                        rs_array_next => rs_array_next
                    );
                end if;

                if insert_result_i = '1' then
                    insert_result(
                        rs_array => rs_array,
                        cdb => cdb_i,
                        rs_array_next => rs_array_next
                    );
                end if;
                
                -- update tail_ptr
                if rs_array(to_integer(tail_ptr)).busy = '0' then
                    tail_ptr_next <= tail_ptr + 1;
                    state_next <= idle;
                end if;

            when others =>
                state_next <= empty;
                full_o <= '0';
                head_ptr_next <= (others => '0');
                tail_ptr_next <= (others => '0');
                rs_array_next <= rs_array;
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');
        end case;
    end process comb_proc;

    seq_proc: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            state <= empty;
            head_ptr <= (others => '0');
            for i in 0 to n_entries_rs-1 loop
                rs_array(i).rob_id <= (others => '-');
                rs_array(i).source1 <= (others => '-');
                rs_array(i).valid1 <= '0';
                rs_array(i).source2 <= (others => '-');
                rs_array(i).valid2 <= '0';
                rs_array(i).operation <= (others => '-');
                rs_array(i).reg1 <= (others => '-');
                rs_array(i).reg2 <= (others => '-');
            end loop;
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                state <= empty;
                head_ptr <= (others => '0');
                for i in 0 to n_entries_rs-1 loop
                    rs_array(i).rob_id <= (others => '-');
                    rs_array(i).source1 <= (others => '-');
                    rs_array(i).valid1 <= '0';
                    rs_array(i).source2 <= (others => '-');
                    rs_array(i).valid2 <= '0';
                    rs_array(i).operation <= (others => '-');
                    rs_array(i).reg1 <= (others => '-');
                    rs_array(i).reg2 <= (others => '-');
                end loop;
            else
                state <= state_next;
                head_ptr <= head_ptr_next;
                rs_array <= rs_array_next;
            end if;
        end if;
    end process seq_proc;
end beh;