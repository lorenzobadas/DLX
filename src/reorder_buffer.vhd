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
        clk_i:           in  std_logic;
        rst_i:           in  std_logic;
        hazard_i:        in  std_logic; -- stall if high
        insert_i:        in  std_logic;
        cdb_i:           in  cdb_t;
        instruction_i:   in  rob_decoded_instruction;
        full_o:          out std_logic;
        destination_o:   out std_logic_vector(nbit-1 downto 0);
        result_o:        out std_logic_vector(nbit-1 downto 0);
        mem_write_en_o:  out std_logic;
        reg_write_en_o:  out std_logic;
        misprediction_o: out std_logic;
        issue_ptr_o:     out std_logic_vector(clog2(n_entries_rob)-1 downto 0)
    );
end entity;

architecture behav of reorder_buffer is
    type state_t is (idle, full);
    type rob_array is array(0 to n_entries_rob-1) of rob_entry;
    signal state, state_next:           state_t;
    signal rob_fifo, rob_fifo_next:     rob_array;
    signal commit_ptr, commit_ptr_next: unsigned(clog2(n_entries_rob)-1 downto 0);
    signal issue_ptr, issue_ptr_next:   unsigned(clog2(n_entries_rob)-1 downto 0);
begin
    comb_proc: process (state, commit_ptr, issue_ptr, rob_fifo, branch_fifo, hazard_i, insert_i, flush_branch_i, cdb_i, instruction_i)
        variable rob_address: integer;
        variable commit_this_cycle: boolean := false;
        variable misprediction_this_cycle: boolean := false;
    begin
        state_next <= state;
        commit_ptr_next <= commit_ptr;
        issue_ptr_next <= issue_ptr;
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
        -- get result from CDB
        rob_fifo_next(to_integer(unsigned(cdb_i.rob_index))).result <= cdb_i.result;
        rob_fifo_next(to_integer(unsigned(cdb_i.rob_index))).ready <= '1';
        -- check if first entry in ROB is ready
        if rob_fifo(commit_ptr).ready = '1' then
            if hazard_i = '0' then
                -- commit result
                commit_this_cycle := true;
                destination_o <= rob_fifo(commit_ptr).destination;
                result_o <= rob_fifo(commit_ptr).result;
                case rob_fifo(commit_ptr).instruction_type is
                    when load =>
                        reg_write_en_o <= '1';
                    when store =>
                        mem_write_en_o <= '1';
                    when others =>
                        null; -- FIXME
                end case;
                mem_write_en_o <= 0; -- FIXME
                reg_write_en_o <= 0; -- FIXME
                -- check if branch misprediction
                if rob_fifo(commit_ptr).instruction_type = branch
                   and rob_fifo(commit_ptr).branch_taken /= rob_fifo(commit_ptr).result then
                    -- misprediction
                    misprediction_this_cycle := true;
                    -- flush ROB
                    issue_ptr_next <= commit_ptr + 1;
                end if;
                commit_ptr_next <= commit_ptr + 1;
            end if;
        end if;
        if not(misprediction_this_cycle) then
            if insert_i = '1' then
                rob_fifo_next(issue_ptr).instruction_type <= instruction_i.instruction_type;
                rob_fifo_next(issue_ptr).destination      <= instruction_i.destination;
                rob_fifo_next(issue_ptr).branch_taken     <= instruction_i.branch_taken;
                rob_fifo_next(issue_ptr).ready            <= '0';
                issue_ptr_next <= issue_ptr + 1;
                if issue_ptr = commit_ptr-1 and not(commit_this_cycle) then
                    state_next <= full;
                end if;
            end if;
        end if;
    end process comb_proc;

    seq_proc: process (clk_i, rst_i)
    begin
        if rst_i = '1' then
            commit_ptr <= (others => '0');
            issue_ptr <= (others => '0');
            state <= idle;
        elsif rising_edge(clk_i) then
            state <= state_next;
            commit_ptr <= commit_ptr_next;
            issue_ptr <= issue_ptr_next;
            rob_fifo <= rob_fifo_next;
            -- still to be implemented
        end if;
    end process seq_proc;

    issue_ptr_o <= issue_ptr;
    misprediction_o <= '1' when rob_fifo(commit_ptr).instruction_type = branch and 
                                rob_fifo(commit_ptr).branch_taken /= rob_fifo(commit_ptr).result else
                       '0';
end behav;

-- ISSUE OPERATION:
-- issue pointer is used to rename the register
-- issue pointer is incremented
-- if issue pointer is equal to commit pointer, then the ROB is full

-- COMMIT OPERATION:
-- every cycle the instruction pointed by the commit pointer is checked
-- if the instruction is ready, then the result is committed
-- if the instruction is a branch and branch_taken flag is different from result, then ROB is emptied (issue_ptr = commit_ptr)

-- CDB OPERATION:
-- every cycle the CDB is checked
-- if the CDB has a result for an instruction in the ROB, then the result is written in the ROB and the instruction is marked as ready

-- branch_taken flag is set by the branch prediction unit (BPU) (or simply hardcoded if we are not implementing branch prediction)
-- result to which branch_taken is compared is the result of the branch instruction, so it comes from the ALU

-- just to be clear, jump instructions do not pose any problem, since they are not speculative

-- in case of misprediction the PC has to be updated and the pipeline has to be flushed
-- the BPU retrieves the result of the branch from the CDB (no direct connection with the ROB is needed)
