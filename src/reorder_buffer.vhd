library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity reorder_buffer is
    generic (
        nbit: integer := 32
    );
    port (
        clk_i:          in  std_logic;
        rst_i:          in  std_logic;
        hazard_i:       in  std_logic; -- stall if high
        insert_i:       in  std_logic;
        flush_branch_i: in  std_logic;
        cdb_i:          in  cdb_t;
        instruction_i:  in  rob_decoded_instruction;
        full_o:         out std_logic;
        destination_o:  out std_logic_vector(nbit-1 downto 0);
        result_o:       out std_logic_vector(nbit-1 downto 0);
        mem_write_en_o: out std_logic;
        reg_write_en_o: out std_logic
    );
end reorder_buffer;

architecture behav of reorder_buffer is
    type state_t is (idle, full);
    signal state, state_next: state_t;
    type rob_array is array(0 to n_entries_rob-1) of rob_entry;
    signal rob_fifo, rob_fifo_next: rob_array;
    signal head_ptr, head_ptr_next: unsigned(clog2(n_entries_rob)-1 downto 0);
    signal tail_ptr, tail_ptr_next: unsigned(clog2(n_entries_rob)-1 downto 0);
begin
    comb_proc: process (state, head_ptr, tail_ptr, rob_fifo, branch_fifo, hazard_i, insert_i, flush_branch_i, cdb_i, instruction_i)
        variable rob_address: integer;
        variable commit_this_cycle: boolean := false;
    begin
        state_next <= state;
        head_ptr_next <= head_ptr;
        tail_ptr_next <= tail_ptr;
        rob_fifo_next <= rob_fifo;
        destination_o <= (others => '0');
        result_o <= (others => '0');
        mem_write_en_o <= '0';
        reg_write_en_o <= '0';
        if state = idle then
            full_o <= '0';
        else
            full_o <= '1';
        end if;
        if flush_branch_i = '0' then
            -- get result from CDB
            for i in 0 to n_entries_rob-1 loop
                if cdb_i.reservation_station = rob_fifo(i).reservation_station and
                   cdb_i.rs_index = rob_fifo(i).rs_index and               --> checks if ID is the same
                   ((i < tail_ptr and i >= head_ptr) or state = full) then --> checks if the entry is valid
                    rob_address := i;
                end if;
            end loop;
            rob_fifo_next(rob_address).ready <= '1';
            rob_fifo_next(rob_address).result <= cdb_i.result;
            -- check if it is a branch or jump instruction
            if rob_fifo(head_ptr).instruction_type = branch then
                -- still to be implemented FIXME
            elsif rob_fifo(head_ptr).instruction_type = jump then
                -- still to be implemented FIXME
            end if;
            -- check if first entry in ROB is ready
            if rob_fifo(head_ptr).ready = '1' then
                if hazard_i = '0' then
                    -- commit result
                    commit_this_cycle := true;
                    destination_o <= rob_fifo(head_ptr).destination;
                    result_o <= rob_fifo(head_ptr).result;
                    case rob_fifo(head_ptr).instruction_type is
                        when load =>
                            reg_write_en_o <= '1';
                        when store =>
                            mem_write_en_o <= '1';
                        when others =>
                            null; -- FIXME
                    end case;
                    mem_write_en_o <= 0; -- FIXME
                    reg_write_en_o <= 0; -- FIXME
                    head_ptr_next <= head_ptr + 1;
                end if;
            end if;
            if insert_i = '1' then
                rob_fifo_next(tail_ptr).instruction_type <= instruction_i.instruction_type;
                rob_fifo_next(tail_ptr).destination <= instruction_i.destination;
                rob_fifo_next(tail_ptr).ready <= '0';
                rob_fifo_next(tail_ptr).reservation_station <= instruction_i.reservation_station;
                rob_fifo_next(tail_ptr).rs_index <= instruction_i.rs_index;
                tail_ptr_next <= tail_ptr + 1;
                if tail_ptr = head_ptr-1 and not(commit_this_cycle) then
                    state_next <= full;
                end if;
            end if;
        else
            tail_ptr_next <= branch_fifo(0).rob_ptr + 1; -- branch instruction + 1 FIXME
            -- jump/branch maybe result contains new PC???????
        end if;
    end process comb_proc;

    seq_proc: process (clk_i, rst_i)
    begin
        if rst_i = '1' then
            head_ptr <= (others => '0');
            tail_ptr <= (others => '0');
            state <= idle;
        elsif rising_edge(clk_i) then
            state <= state_next;
            head_ptr <= head_ptr_next;
            tail_ptr <= tail_ptr_next;
            rob_fifo <= rob_fifo_next;
            -- still to be implemented
        end if;
    end process seq_proc;
end behav;

-- Probably there will be a smaller FIFO for the
-- branch instructions.
-- Every entry in the FIFO will contain the ID of
-- the reservation station and the ID of the RS
-- entry, PC of the next instruction, and PC of
-- the branch if it is taken.
