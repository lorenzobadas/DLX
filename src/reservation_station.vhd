library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reservation_station is
    generic (
        nbit: integer := 32;
        in_order: boolean := false
    );
    port (
        clk_i:   in  std_logic;
        reset_i: in  std_logic;
        flush_i: in  std_logic;
        full_o:  out std_logic;

        -- Issue Interface
        insert_i:   in std_logic;
        rs_entry_i: in rs_entry_t;
        
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

architecture beh of reservation_station is
    type state_t is (empty, idle, full);
    type rs_array_t is array(0 to n_entries_rs-1) of rs_entry_t;
    signal state, state_next: state_t;
    signal rs_array, rs_array_next: rs_array_t;
    signal head_ptr, head_ptr_next: unsigned(clog2(n_entries_rs)-1 downto 0);
begin
    comb_proc: process(state, rs_array, head_ptr, flush_i, insert_i, rs_entry_i, exe_stall_i, insert_result_i, cdb_i)
        variable execution_index: integer;
        variable execution_found: boolean := false;
    begin
        case state is
            when empty =>
                state_next <= empty;
                full_o <= '0';
                head_ptr_next <= head_ptr;
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
                rs_array_next <= rs_array;
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');
                -- check if there is an instruction to be executed
                if exe_stall_i = '0' then
                    for i in n_entries_rs-1 downto 0 loop
                        if rs_array(i).valid1 = '1' and rs_array(i).valid2 = '1' then
                            exe_enable_o <= '1';
                            exe_rob_id_o <= rs_array(i).rob_id;
                            exe_source1_o <= rs_array(i).source1;
                            exe_source2_o <= rs_array(i).source2;
                            exe_operation_o <= rs_array(i).operation;
                            execution_index := i;
                            execution_found := true;
                        end if;
                    end loop;
                end if;
                -- shift entries that come after the executed instruction
                if execution_found then
                    for i in 1 to n_entries_rs-1 loop
                        if i > execution_index then
                            rs_array_next(i-1) <= rs_array(i);
                        end if;
                    end loop;
                end if;
                -- insert new instruction in the reservation station
                -- different in case of instruction ready for execution
                if insert_i = '1' then
                    if execution_found then
                        rs_array_next(to_integer(head_ptr-1)) <= rs_entry_i;
                    else
                        rs_array_next(to_integer(head_ptr)) <= rs_entry_i;
                        head_ptr_next <= head_ptr + 1;
                        if head_ptr = n_entries_rs-1 then
                            state_next <= full;
                        end if;
                    end if; 
                end if;
                -- check if cdb result can be used to update the reservation station
                if insert_result_i = '1' then
                    for i in 0 to n_entries_rs-1 loop
                        if rs_array(i).valid1 = '0' and rs_array(i).reg1 = cdb_i.rob_index then
                            if execution_found and i > execution_index then
                                rs_array_next(i-1).source1 <= cdb_i.result;
                                rs_array_next(i-1).valid1 <= '1';
                            else
                                rs_array_next(i).source1 <= cdb_i.result;
                                rs_array_next(i).valid1 <= '1';
                            end if;
                        end if;
                        if rs_array(i).valid2 = '0' and rs_array(i).reg2 = cdb_i.rob_index then
                            if execution_found and i > execution_index then
                                rs_array_next(i-1).source2 <= cdb_i.result;
                                rs_array_next(i-1).valid2 <= '1';
                            else
                                rs_array_next(i).source2 <= cdb_i.result;
                                rs_array_next(i).valid2 <= '1';
                            end if;
                        end if;
                    end loop;
                end if;
            when full =>
                state_next <= full;
                full_o <= '1';
                head_ptr_next <= head_ptr;
                rs_array_next <= rs_array;
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');
                -- check if there is an instruction to be executed
                if exe_stall_i = '0' then
                    for i in n_entries_rs-1 downto 0 loop
                        if rs_array(i).valid1 = '1' and rs_array(i).valid2 = '1' then
                            exe_enable_o <= '1';
                            exe_rob_id_o <= rs_array(i).rob_id;
                            exe_source1_o <= rs_array(i).source1;
                            exe_source2_o <= rs_array(i).source2;
                            exe_operation_o <= rs_array(i).operation;
                            execution_index := i;
                            execution_found := true;
                        end if;
                    end loop;
                end if;
                -- shift entries that come after the executed instruction
                if execution_found then
                    state_next <= idle;
                    for i in 1 to n_entries_rs-1 loop
                        if i > execution_index then
                            rs_array_next(i-1) <= rs_array(i);
                        end if;
                    end loop;
                end if;
                -- check if cdb result can be used to update the reservation station
                if insert_result_i = '1' then
                    for i in 0 to n_entries_rs-1 loop
                        if rs_array(i).valid1 = '0' and rs_array(i).reg1 = cdb_i.rob_index then
                            if execution_found and i > execution_index then
                                rs_array_next(i-1).source1 <= cdb_i.result;
                                rs_array_next(i-1).valid1 <= '1';
                            else
                                rs_array_next(i).source1 <= cdb_i.result;
                                rs_array_next(i).valid1 <= '1';
                            end if;
                        end if;
                        if rs_array(i).valid2 = '0' and rs_array(i).reg2 = cdb_i.rob_index then
                            if execution_found and i > execution_index then
                                rs_array_next(i-1).source2 <= cdb_i.result;
                                rs_array_next(i-1).valid2 <= '1';
                            else
                                rs_array_next(i).source2 <= cdb_i.result;
                                rs_array_next(i).valid2 <= '1';
                            end if;
                        end if;
                    end loop;
                end if;
            when others =>
                state <= empty;
                full_o <= '0';
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
                exe_enable_o <= '0';
                exe_rob_id_o <= (others => '-');
                exe_source1_o <= (others => '-');
                exe_source2_o <= (others => '-');
                exe_operation_o <= (others => '-');
        end case;
    end process comb_proc;

    seq_proc: process(clk_i, reset_i)
    begin
        if reset = '1' then
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