library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity ls_reservation_station is
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
        rs_entry_i: in ls_rs_instruction_data_t;

        -- Memory Interface for Loads
        mem_read_enable_o: out std_logic;
        mem_rob_id_o:      out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        mem_format_o:      out std_logic_vector(2 downto 0);
        mem_address_o:     out std_logic_vector(nbit-1 downto 0);

        -- Memory Interface for Stores
        mem_write_enable_o:  out std_logic;
        mem_write_data_o:    out std_logic_vector(nbit-1 downto 0);
        mem_write_address_o: out std_logic_vector(nbit-1 downto 0);
        mem_write_width_o:   out std_logic_vector(1 downto 0);

        -- LSU Arbiter Interface
        lsu_arbiter_load_slot_taken_i: in std_logic; -- when valid, there is a load instruction in the pipeline
        lsu_arbiter_load_valid_i:      in std_logic; -- when valid, the load has been performed and result sent to ROB

        -- ROB Interface
        rob_commit_store_i:       in  std_logic; -- when valid, the store is requested by the ROB to commit
        rob_commit_store_stall_o: out std_logic; -- when asserted, the store that was requested to commit is not ready

        -- CDB Interface
        insert_result_i: in std_logic;
        cdb_i:           in cdb_t
    );
end entity;

architecture beh of ls_reservation_station is
    type state_t is (empty, idle, full);
    type rs_array_t is array(0 to n_entries_rs-1) of ls_rs_entry_t;
    signal state, state_next: state_t;
    signal rs_array, rs_array_next: rs_array_t;
    signal head_ptr, head_ptr_next: unsigned(clog2(n_entries_rs)-1 downto 0);
    signal tail_ptr, tail_ptr_next: unsigned(clog2(n_entries_rs)-1 downto 0);

    function overlap (
        address1: in std_logic_vector(31 downto 0);
        width1:   in std_logic_vector(1 downto 0);
        address2: in std_logic_vector(31 downto 0);
        width2:   in std_logic_vector(1 downto 0)
    ) return boolean is
        variable width1_v:  integer;
        variable width2_v:  integer;
        variable max_width: integer;
    begin
        -- assumes:
        -- 0: byte
        -- 1: halfword
        -- 2: word
        -- also assumes that the addresses are aligned
        width1_v := to_integer(unsigned(width1));
        width2_v := to_integer(unsigned(width2));
        max_width := max(width1_v, width2_v);
        case max_width is
            when 0 => -- byte
                if address1 = address2 then
                    return true;
                else
                    return false;
                end if;
            when 1 => -- halfword
                if address1(31 downto 1) = address2(31 downto 1) then
                    return true;
                else
                    return false;
                end if;
            when 2 => -- word
                if address1(31 downto 2) = address2(31 downto 2) then
                    return true;
                else
                    return false;
                end if;
            when others =>
                return false;
        end case;
    end function overlap;

    procedure insert_instruction (
        signal rs_entry:      in  ls_rs_instruction_data_t;
        signal head_ptr:      in  unsigned(clog2(n_entries_rs)-1 downto 0);
        signal head_ptr_next: out unsigned(clog2(n_entries_rs)-1 downto 0);
        signal rs_array_next: out rs_array_t
    ) is
    begin
        head_ptr_next <= head_ptr + 1;
        rs_array_next(to_integer(head_ptr)).rob_id      <= rs_entry.rob_id;
        rs_array_next(to_integer(head_ptr)).source1     <= rs_entry.source1;
        rs_array_next(to_integer(head_ptr)).valid1      <= rs_entry.valid1;
        rs_array_next(to_integer(head_ptr)).source2     <= rs_entry.source2;
        rs_array_next(to_integer(head_ptr)).valid2      <= rs_entry.valid2;
        rs_array_next(to_integer(head_ptr)).immediate   <= rs_entry.immediate;
        rs_array_next(to_integer(head_ptr)).operation   <= rs_entry.operation;
        rs_array_next(to_integer(head_ptr)).width_field <= rs_entry.width_field;
        rs_array_next(to_integer(head_ptr)).sign_field  <= rs_entry.sign_field;
        rs_array_next(to_integer(head_ptr)).reg1        <= rs_entry.reg1;
        rs_array_next(to_integer(head_ptr)).reg2        <= rs_entry.reg2;
        rs_array_next(to_integer(head_ptr)).wait_store  <= '0';
        rs_array_next(to_integer(head_ptr)).busy        <= '1';
    end procedure insert_instruction;
    procedure send_load_to_mem (
        signal rs_array:              in  rs_array_t;
        signal tail_ptr:              in  unsigned(clog2(n_entries_rs)-1 downto 0);
        signal rs_array_next:         out rs_array_t;
        signal mem_read_enable:       out std_logic;
        signal mem_rob_id:            out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        signal mem_format:            out std_logic_vector(2 downto 0);
        signal mem_address:           out std_logic_vector(nbit-1 downto 0)
    ) is
        variable found:      boolean;
        variable condition1: boolean;
        variable condition2: boolean;
        variable condition3: boolean;
    begin
        -- look for load instruction ready to execute
        -- if found send to memory
        -- free RS entry
        found := false;
        for i in 0 to n_entries_rs-1 loop
            -- condition1: valid1, valid2 and busy are set
            condition1 := rs_array(to_integer(tail_ptr + i)).valid1 = '1' and
                          rs_array(to_integer(tail_ptr + i)).valid2 = '1' and
                          rs_array(to_integer(tail_ptr + i)).busy = '1';
            if (not found) and
                (rs_array(to_integer(tail_ptr + i)).operation = '0')  and
                (condition1)
            then
                -- condition2: all previous store instructions have valid2 set
                condition2 := true;
                -- condition3: no address overlap with previous store instructions
                condition3 := true;
                for j in 0 to n_entries_rs-1 loop
                    if j < i and 
                       rs_array(to_integer(tail_ptr + j)).operation = '1'
                    then
                        condition2 := condition2 and (rs_array(to_integer(tail_ptr + j)).valid2 = '1');
                        condition3 := condition3 and 
                                        not overlap(
                                        rs_array(to_integer(tail_ptr + i)).source2, 
                                        rs_array(to_integer(tail_ptr + i)).width_field, 
                                        rs_array(to_integer(tail_ptr + j)).source2, 
                                        rs_array(to_integer(tail_ptr + j)).width_field
                                        );
                    end if;
                end loop;
                if condition2 and condition3 then
                    found := true;
                    mem_read_enable       <= '1';
                    mem_rob_id            <= rs_array(to_integer(tail_ptr + i)).rob_id;
                    mem_format            <= rs_array(to_integer(tail_ptr + i)).width_field & rs_array(to_integer(tail_ptr + i)).sign_field;
                    mem_address           <= rs_array(to_integer(tail_ptr + i)).source2;
                    -- Remove load instruction from RS
                    rs_array_next(to_integer(tail_ptr + i)).busy <= '0';
                end if;
            end if;
        end loop;
    end procedure send_load_to_mem;
    procedure commit_store (
        signal rs_array:               in  rs_array_t;
        signal tail_ptr:               in  unsigned(clog2(n_entries_rs)-1 downto 0);
        signal rob_commit_store:       in  std_logic;
        signal rob_commit_store_stall: out std_logic;
        signal mem_write_data:         out std_logic_vector(nbit-1 downto 0);
        signal mem_write_address:      out std_logic_vector(nbit-1 downto 0);
        signal mem_write_width:        out std_logic_vector(1 downto 0);
        signal mem_write_enable:       out std_logic;
        signal rs_array_next:          out rs_array_t
    ) is
        variable found: boolean := false;
        variable found_index: integer := 0;
    begin
        -- look for the first store instruction in the RS
        -- if ready, mark RS entry as not busy
        for i in 0 to n_entries_rs-1 loop
            if not found and
               rs_array(to_integer(tail_ptr+i)).operation = '1' and 
               rs_array(to_integer(tail_ptr+i)).busy = '1'
            then
                found := true;
                found_index := to_integer(tail_ptr+i);
            end if;
        end loop;

        rs_array_next(found_index).wait_store <= '1';

        if rs_array(found_index).valid1 = '1' and
           rs_array(found_index).valid2 = '1' 
        then
            rs_array_next(found_index).busy <= '0';
        end if;
        rob_commit_store_stall <= rs_array(found_index).wait_store and
                                  rs_array(found_index).busy;
        mem_write_data         <= rs_array(found_index).source1;
        mem_write_address      <= rs_array(found_index).source2;
        mem_write_width        <= rs_array(found_index).width_field;
        mem_write_enable       <= (rob_commit_store or (rs_array(found_index).wait_store and rs_array(found_index).busy)) and
                                   rs_array(found_index).operation and
                                   rs_array(found_index).valid1 and
                                   rs_array(found_index).valid2;
    end procedure commit_store;
    procedure insert_result (
        signal rs_array:      in  rs_array_t;
        signal cdb:           in  cdb_t;
        signal rs_array_next: out rs_array_t
    ) is
    begin
        for i in 0 to n_entries_rs-1 loop
            if rs_array(i).valid1 = '0' and 
               rs_array(i).reg1 = cdb.rob_index
            then
                rs_array_next(i).source1 <= cdb.result;
                rs_array_next(i).valid1  <= '1';
            end if;
            if rs_array(i).valid2 = '0' and
               rs_array(i).reg2 = cdb.rob_index
            then
                rs_array_next(i).source2 <= std_logic_vector(unsigned(cdb.result) + unsigned(rs_array(i).immediate));
                rs_array_next(i).valid2  <= '1';
            end if;
        end loop;
    end procedure insert_result;
begin
    comb_proc: process(state, rs_array, head_ptr, tail_ptr, insert_i, rs_entry_i, lsu_arbiter_load_valid_i, rob_commit_store_i, insert_result_i, cdb_i, lsu_arbiter_load_slot_taken_i)
        variable found:       boolean := false;
        variable found_index: integer;
        variable condition1:  boolean;
        variable condition2:  boolean;
        variable condition3:  boolean;
    begin
        case state is
            when empty =>
                state_next                 <= empty;
                rs_array_next              <= rs_array;
                full_o                     <= '0';
                head_ptr_next              <= head_ptr;
                tail_ptr_next              <= tail_ptr;
                mem_read_enable_o          <= '0';
                mem_rob_id_o               <= (others => '0');
                mem_format_o               <= (others => '0');
                mem_address_o              <= (others => '0');
                rob_commit_store_stall_o   <= '0';
                mem_write_enable_o         <= '0';
                mem_write_data_o           <= (others => '0');
                mem_write_address_o        <= (others => '0');
                mem_write_width_o          <= (others => '0');

                if insert_i = '1' then
                    insert_instruction(
                        rs_entry      => rs_entry_i,
                        head_ptr      => head_ptr,
                        head_ptr_next => head_ptr_next,
                        rs_array_next => rs_array_next
                    );
                    state_next <= idle;
                end if;

            when idle =>
                state_next                 <= idle;
                rs_array_next              <= rs_array;
                full_o                     <= '0';
                head_ptr_next              <= head_ptr;
                tail_ptr_next              <= tail_ptr;
                mem_read_enable_o          <= '0';
                mem_rob_id_o               <= (others => '0');
                mem_format_o               <= (others => '0');
                mem_address_o              <= (others => '0');
                rob_commit_store_stall_o   <= '0';
                mem_write_enable_o         <= '0';
                mem_write_data_o           <= (others => '0');
                mem_write_address_o        <= (others => '0');
                mem_write_width_o          <= (others => '0');

                if insert_i = '1' then
                    insert_instruction(
                        rs_entry      => rs_entry_i,
                        head_ptr      => head_ptr,
                        head_ptr_next => head_ptr_next,
                        rs_array_next => rs_array_next
                    );
                end if;
                
                if lsu_arbiter_load_slot_taken_i = '0' or lsu_arbiter_load_valid_i = '1'  then
                    send_load_to_mem(
                        rs_array        => rs_array,
                        tail_ptr        => tail_ptr,
                        rs_array_next   => rs_array_next,
                        mem_read_enable => mem_read_enable_o,
                        mem_rob_id      => mem_rob_id_o,
                        mem_format      => mem_format_o,
                        mem_address     => mem_address_o
                    );
                end if;

                -- Try to commit store instruction
                if rob_commit_store_i = '1' or
                   (rs_array(to_integer(tail_ptr)).wait_store = '1' and
                    rs_array(to_integer(tail_ptr)).busy = '1')
                then
                    commit_store(
                        rs_array               => rs_array,
                        tail_ptr               => tail_ptr,
                        rob_commit_store       => rob_commit_store_i,
                        rob_commit_store_stall => rob_commit_store_stall_o,
                        mem_write_data         => mem_write_data_o,
                        mem_write_address      => mem_write_address_o,
                        mem_write_width        => mem_write_width_o,
                        mem_write_enable       => mem_write_enable_o,
                        rs_array_next          => rs_array_next
                    );
                end if;

                if insert_result_i = '1' then
                    insert_result(
                        rs_array      => rs_array,
                        cdb           => cdb_i,
                        rs_array_next => rs_array_next
                    );
                end if;

                -- update tail_ptr
                if rs_array(to_integer(tail_ptr)).busy = '0' then
                    tail_ptr_next <= tail_ptr + 1;
                end if;

                -- check if full
                if head_ptr = tail_ptr-1 and
                   insert_i = '1' and 
                   not(rs_array(to_integer(tail_ptr)).busy = '0')
                then
                    state_next <= full;
                end if;

                -- check if empty
                if head_ptr = tail_ptr+1 and
                   insert_i = '0'        and
                   rs_array(to_integer(tail_ptr)).busy = '0'
                then
                    state_next <= empty;
                end if;

            when full =>
                state_next                 <= full;
                rs_array_next              <= rs_array;
                full_o                     <= '1';
                head_ptr_next              <= head_ptr;
                tail_ptr_next              <= tail_ptr;
                mem_read_enable_o          <= '0';
                mem_rob_id_o               <= (others => '0');
                mem_format_o               <= (others => '0');
                mem_address_o              <= (others => '0');
                rob_commit_store_stall_o   <= '0';
                mem_write_enable_o         <= '0';
                mem_write_data_o           <= (others => '0');
                mem_write_address_o        <= (others => '0');
                mem_write_width_o          <= (others => '0');
                
                if lsu_arbiter_load_slot_taken_i = '0' or lsu_arbiter_load_valid_i = '1'  then
                    send_load_to_mem(
                        rs_array        => rs_array,
                        tail_ptr        => tail_ptr,
                        rs_array_next   => rs_array_next,
                        mem_read_enable => mem_read_enable_o,
                        mem_rob_id      => mem_rob_id_o,
                        mem_format      => mem_format_o,
                        mem_address     => mem_address_o
                    );
                end if;

                -- Try to commit store instruction
                if rob_commit_store_i = '1' or
                   (rs_array(to_integer(tail_ptr)).wait_store = '1' and
                    rs_array(to_integer(tail_ptr)).busy = '1')
                then
                    commit_store(
                        rs_array               => rs_array,
                        tail_ptr               => tail_ptr,
                        rob_commit_store       => rob_commit_store_i,
                        rob_commit_store_stall => rob_commit_store_stall_o,
                        mem_write_data         => mem_write_data_o,
                        mem_write_address      => mem_write_address_o,
                        mem_write_width        => mem_write_width_o,
                        mem_write_enable       => mem_write_enable_o,
                        rs_array_next          => rs_array_next
                    );
                end if;

                if insert_result_i = '1' then
                    insert_result(
                        rs_array      => rs_array,
                        cdb           => cdb_i,
                        rs_array_next => rs_array_next
                    );
                end if;

                -- update tail_ptr
                if rs_array(to_integer(tail_ptr)).busy = '0' then
                    tail_ptr_next <= tail_ptr + 1;
                    state_next    <= idle;
                end if;

            when others =>
                state_next                 <= empty;
                full_o                     <= '1';
                head_ptr_next              <= (others => '0');
                tail_ptr_next              <= (others => '0');
                mem_read_enable_o          <= '0';
        end case;
    end process comb_proc;
    
    seq_proc: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            state    <= empty;
            head_ptr <= (others => '0');
            tail_ptr <= (others => '0');
            for i in 0 to n_entries_rs-1 loop
                rs_array(i).rob_id      <= (others => '-');
                rs_array(i).source1     <= (others => '-');
                rs_array(i).valid1      <= '0';
                rs_array(i).source2     <= (others => '-');
                rs_array(i).valid2      <= '0';
                rs_array(i).immediate   <= (others => '-');
                rs_array(i).operation   <= '-';
                rs_array(i).width_field <= (others => '-');
                rs_array(i).sign_field  <= '-';
                rs_array(i).reg1        <= (others => '-');
                rs_array(i).reg2        <= (others => '-');
                rs_array(i).wait_store  <= '0';
                rs_array(i).busy        <= '0';
            end loop;
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                state    <= empty;
                head_ptr <= (others => '0');
                tail_ptr <= (others => '0');
                for i in 0 to n_entries_rs-1 loop
                    rs_array(i).rob_id      <= (others => '-');
                    rs_array(i).source1     <= (others => '-');
                    rs_array(i).valid1      <= '0';
                    rs_array(i).source2     <= (others => '-');
                    rs_array(i).valid2      <= '0';
                    rs_array(i).immediate   <= (others => '-');
                    rs_array(i).operation   <= '-';
                    rs_array(i).width_field <= (others => '-');
                    rs_array(i).sign_field  <= '-';
                    rs_array(i).reg1        <= (others => '-');
                    rs_array(i).reg2        <= (others => '-');
                    rs_array(i).wait_store  <= '0';
                    rs_array(i).busy        <= '0';
                end loop;
            else
                state             <= state_next;
                head_ptr          <= head_ptr_next;
                tail_ptr          <= tail_ptr_next;
                rs_array          <= rs_array_next;
            end if;
        end if;
    end process seq_proc;
end beh;