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
        clk_i:        in  std_logic;
        reset_i:      in  std_logic;
        mem_hazard_i: in  std_logic;
        full_o:       out std_logic;
        issue_ptr_o:  out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        commit_ptr_o: out std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        
        -- CDB Arbiter Interface
        insert_result_i: in std_logic; -- acknowledge not needed (if rob data is consistent)
        cdb_i:           in  cdb_t;
        
        -- Issue Interface
        insert_instruction_i: in  std_logic; -- acknowledge not needed because insertion prevented if full
        instruction_i:        in  rob_decoded_instruction;

        -- RF/MEM Interface
        destination_o:     out std_logic_vector(nbit-1 downto 0);
        result_o:          out std_logic_vector(nbit-1 downto 0);
        memory_we_o:       out std_logic;
        registerfile_we_o: out std_logic;

        -- Branch Unit Interface
        branch_result_o:    out rob_branch_result;
        misprediction_o:    out std_logic
    );
end entity;

architecture beh of reorder_buffer is
    type state_t is (empty, idle, full);
    type rob_array is array(0 to n_entries_rob-1) of rob_entry;
    signal state, state_next:           state_t;
    signal rob_fifo, rob_fifo_next:     rob_array;
    signal commit_ptr, commit_ptr_next: unsigned(clog2(n_entries_rob)-1 downto 0);
    signal issue_ptr, issue_ptr_next:   unsigned(clog2(n_entries_rob)-1 downto 0);

    procedure insert_instruction (
        signal instruction:        in  rob_decoded_instruction;
        signal issue_ptr:          in  unsigned;
        signal rob_fifo:           out rob_array;
        signal issue_ptr_next:     out unsigned
    ) is
    begin
        issue_ptr_next <= issue_ptr + 1;
        rob_fifo(to_integer(issue_ptr)).instruction_type <= instruction.instruction_type;
        rob_fifo(to_integer(issue_ptr)).destination      <= instruction.destination;
        rob_fifo(to_integer(issue_ptr)).result           <= (others => '-');
        rob_fifo(to_integer(issue_ptr)).ready            <= '0';
        -- branch info
        rob_fifo(to_integer(issue_ptr)).branch_data.branch_taken   <= instruction.branch_taken;
        rob_fifo(to_integer(issue_ptr)).branch_data.branch_address <= instruction.instruction_address;
        rob_fifo(to_integer(issue_ptr)).branch_data.taken_address  <= instruction.branch_taken_address;
        rob_fifo(to_integer(issue_ptr)).branch_data.history        <= instruction.bpu_history;
    end procedure insert_instruction;

    procedure insert_result (
        signal cdb:      in cdb_t;
        signal rob_fifo: out rob_array
    ) is
    begin
        rob_fifo(to_integer(unsigned(cdb.rob_index))).result <= cdb.result;
        rob_fifo(to_integer(unsigned(cdb.rob_index))).ready  <= '1';
    end procedure insert_result;

    procedure commit_instruction (
        signal rob_fifo:           in  rob_array;
        signal commit_ptr:         in  unsigned(clog2(n_entries_rob)-1 downto 0);
        signal mem_hazard:         in  std_logic;
        signal commit_ptr_next:    out unsigned(clog2(n_entries_rob)-1 downto 0);
        signal issue_ptr_next:     out unsigned(clog2(n_entries_rob)-1 downto 0);
        signal destination_o:      out std_logic_vector(nbit-1 downto 0);
        signal result_o:           out std_logic_vector(nbit-1 downto 0);
        signal memory_we_o:        out std_logic;
        signal registerfile_we_o:  out std_logic;
        signal branch_result_o:    out rob_branch_result;
        signal misprediction_o:    out std_logic
    ) is
    begin
        commit_ptr_next <= commit_ptr + 1;
        destination_o <= rob_fifo(to_integer(commit_ptr)).destination;
        result_o <= rob_fifo(to_integer(commit_ptr)).result;
        case rob_fifo(to_integer(commit_ptr)).instruction_type is
            when to_mem =>
                if mem_hazard = '0' then
                    memory_we_o   <= '1';
                    destination_o <= rob_fifo(to_integer(commit_ptr)).destination;
                    result_o      <= rob_fifo(to_integer(commit_ptr)).result;
                else
                    commit_ptr_next <= commit_ptr;
                end if;
            when to_rf =>
                registerfile_we_o <= '1';
                destination_o     <= rob_fifo(to_integer(commit_ptr)).destination;
                result_o          <= rob_fifo(to_integer(commit_ptr)).result;
            when branch =>
                -- fill branch result info
                branch_result_o.branch_taken  <= rob_fifo(to_integer(commit_ptr)).result(0);
                branch_result_o.address       <= rob_fifo(to_integer(commit_ptr)).branch_data.branch_address;
                branch_result_o.taken_address <= rob_fifo(to_integer(commit_ptr)).branch_data.taken_address;
                branch_result_o.history       <= rob_fifo(to_integer(commit_ptr)).branch_data.history;
                branch_result_o.valid         <= '1';
                if rob_fifo(to_integer(commit_ptr)).branch_data.branch_taken /= rob_fifo(to_integer(commit_ptr)).result(0) then
                    -- flush rob
                    misprediction_o <= '1';
                    issue_ptr_next <= commit_ptr + 1;
                end if;
            when others =>
        end case;
    end procedure commit_instruction;
begin
    issue_ptr_o  <= std_logic_vector(issue_ptr);
    commit_ptr_o <= std_logic_vector(commit_ptr);

    comb_proc: process (state, mem_hazard_i, rob_fifo, commit_ptr, issue_ptr, insert_result_i, cdb_i, insert_instruction_i, instruction_i)
        variable push, pop, misp, test_full, test_empty: boolean;
    begin
        push       := insert_instruction_i = '1';
        pop        := rob_fifo(to_integer(commit_ptr)).ready = '1' and not(rob_fifo(to_integer(commit_ptr)).instruction_type = to_mem and mem_hazard_i = '1');
        misp       := pop and (rob_fifo(to_integer(commit_ptr)).instruction_type = branch) and (rob_fifo(to_integer(commit_ptr)).branch_data.branch_taken /= rob_fifo(to_integer(commit_ptr)).result(0));
        test_full  := issue_ptr = commit_ptr-1;
        test_empty := issue_ptr = commit_ptr+1;

        case state is
            when empty =>
                rob_fifo_next <= rob_fifo;
                issue_ptr_next <= issue_ptr;
                commit_ptr_next <= commit_ptr;
                state_next <= empty;
                full_o <= '0';
                destination_o     <= (others => '-');
                result_o          <= (others => '-');
                memory_we_o       <= '0';
                registerfile_we_o <= '0';
                branch_result_o.branch_taken  <= '-';
                branch_result_o.address       <= (others => '-');
                branch_result_o.taken_address <= (others => '-');
                branch_result_o.history       <= (others => '-');
                branch_result_o.valid         <= '0';
                misprediction_o <= '0';
                if insert_instruction_i = '1' then
                    insert_instruction(instruction_i, issue_ptr, rob_fifo_next, issue_ptr_next);
                    state_next <= idle;
                end if;
            when idle =>
                rob_fifo_next <= rob_fifo;
                issue_ptr_next <= issue_ptr;
                commit_ptr_next <= commit_ptr;
                state_next <= idle;
                full_o <= '0';
                destination_o     <= (others => '-');
                result_o          <= (others => '-');
                memory_we_o    <= '0';
                registerfile_we_o    <= '0';
                branch_result_o.branch_taken  <= '-';
                branch_result_o.address       <= (others => '-');
                branch_result_o.taken_address <= (others => '-');
                branch_result_o.history       <= (others => '-');
                branch_result_o.valid         <= '0';
                misprediction_o <= '0';
                if insert_result_i = '1' then
                    insert_result(cdb_i, rob_fifo_next);
                end if;
                if insert_instruction_i = '1' then
                    insert_instruction(instruction_i, issue_ptr, rob_fifo_next, issue_ptr_next);
                end if;
                if rob_fifo(to_integer(commit_ptr)).ready = '1' then
                    commit_instruction(
                        rob_fifo => rob_fifo,
                        commit_ptr => commit_ptr,
                        mem_hazard => mem_hazard_i,
                        commit_ptr_next => commit_ptr_next,
                        issue_ptr_next => issue_ptr_next,
                        destination_o => destination_o,
                        result_o => result_o,
                        memory_we_o => memory_we_o,
                        registerfile_we_o => registerfile_we_o,
                        branch_result_o => branch_result_o,
                        misprediction_o => misprediction_o
                    );
                end if;
                if push and not(pop) and test_full then
                    state_next <= full;
                elsif (not(push) and pop and test_empty) or misp then
                    state_next <= empty;
                end if;
            when full =>
                rob_fifo_next   <= rob_fifo;
                issue_ptr_next  <= issue_ptr;
                commit_ptr_next <= commit_ptr;
                state_next      <= full;
                full_o          <= '1';
                destination_o     <= (others => '-');
                result_o          <= (others => '-');
                memory_we_o    <= '0';
                registerfile_we_o    <= '0';
                branch_result_o.branch_taken <= '-';
                branch_result_o.address      <= (others => '-');
                branch_result_o.history      <= (others => '-');
                branch_result_o.valid        <= '0';
                misprediction_o <= '0';
                if insert_result_i = '1' then
                    insert_result(cdb_i, rob_fifo_next);
                end if;
                if rob_fifo(to_integer(commit_ptr)).ready = '1' then
                    commit_instruction(
                        rob_fifo => rob_fifo,
                        commit_ptr => commit_ptr,
                        mem_hazard => mem_hazard_i,
                        commit_ptr_next => commit_ptr_next,
                        issue_ptr_next => issue_ptr_next,
                        destination_o => destination_o,
                        result_o => result_o,
                        memory_we_o => memory_we_o,
                        registerfile_we_o => registerfile_we_o,
                        branch_result_o => branch_result_o,
                        misprediction_o => misprediction_o
                    );
                end if;
                if pop and not(misp) then
                    state_next <= idle;
                elsif pop and misp then
                    state_next <= empty;
                end if;
            when others =>
                rob_fifo_next <= rob_fifo;
                issue_ptr_next <= issue_ptr;
                commit_ptr_next <= commit_ptr;
                state_next <= empty;
                full_o <= '0';
                destination_o     <= (others => '-');
                result_o          <= (others => '-');
                memory_we_o    <= '0';
                registerfile_we_o    <= '0';
                branch_result_o.branch_taken  <= '-';
                branch_result_o.address       <= (others => '-');
                branch_result_o.taken_address <= (others => '-');
                branch_result_o.history       <= (others => '-');
                branch_result_o.valid         <= '0';
        end case;
    end process comb_proc;

    seq_proc: process (clk_i, reset_i)
    begin
        if reset_i = '1' then
            state <= empty;
            commit_ptr <= (others => '0');
            issue_ptr <= (others => '0');
            for i in 0 to n_entries_rob-1 loop
                rob_fifo(i).instruction_type <= to_rf;
                rob_fifo(i).result           <= (others => '-');
                rob_fifo(i).destination      <= (others => '-');
                rob_fifo(i).branch_data.branch_taken   <= '-';
                rob_fifo(i).branch_data.branch_address <= (others => '-');
                rob_fifo(i).branch_data.taken_address  <= (others => '-');
                rob_fifo(i).branch_data.history        <= (others => '-');
                rob_fifo(i).ready <= '0';
            end loop;
        elsif rising_edge(clk_i) then
            state <= state_next;
            commit_ptr <= commit_ptr_next;
            issue_ptr <= issue_ptr_next;
            rob_fifo <= rob_fifo_next;
        end if;
    end process seq_proc;
end beh;

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
