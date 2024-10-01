library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity tb_reorder_buffer is
end tb_reorder_buffer;

-- expects n_entries_rob to be equal to 4
architecture test of tb_reorder_buffer is
    -- component declarations
    component reorder_buffer is
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
            insert_result_i: in std_logic;
            cdb_i:           in  cdb_t;
            insert_instruction_i: in  std_logic;
            instruction_i:        in  rob_decoded_instruction_t;
            destination_o:     out std_logic_vector(nbit-1 downto 0);
            result_o:          out std_logic_vector(nbit-1 downto 0);
            memory_we_o:       out std_logic;
            registerfile_we_o: out std_logic;
            branch_result_o:    out rob_branch_result_t;
            misprediction_o:    out std_logic
        );
    end component;
    -- signal declaration
    signal clk: std_logic;
    signal reset: std_logic;
    signal mem_hazard: std_logic;
    signal full: std_logic;
    signal issue_ptr: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal commit_ptr: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal insert_result: std_logic;
    signal cdb: cdb_t;
    signal insert_instruction: std_logic;
    signal instruction: rob_decoded_instruction_t;
    signal destination: std_logic_vector(nbit-1 downto 0);
    signal result: std_logic_vector(nbit-1 downto 0);
    signal memory_we: std_logic;
    signal registerfile_we: std_logic;
    signal branch_result: rob_branch_result_t;
    signal misprediction: std_logic;

    -- testbench procedures
    procedure insert_instruction_proc (
        insert_instruction: std_logic;
        instruction_type: instruction_t;
        destination:      integer;
        branch_taken:     std_logic;
        branch_addr:      integer;
        taken_addr:       integer;
        bpu_history:      std_logic_vector(1 downto 0);

        signal insert_instruction_s: out std_logic;
        signal instruction:          out rob_decoded_instruction_t
    ) is
    begin
        insert_instruction_s <= insert_instruction;
        instruction.instruction_type <= instruction_type;
        instruction.instruction_address <= std_logic_vector(to_unsigned(branch_addr, nbit));
        instruction.branch_taken <= branch_taken;
        instruction.destination <= std_logic_vector(to_unsigned(destination, nbit));
        instruction.branch_taken_address <= std_logic_vector(to_unsigned(taken_addr, nbit));
        instruction.bpu_history <= bpu_history;
    end procedure insert_instruction_proc;

    procedure insert_result_proc (
        insert_result: std_logic;
        result:        integer;
        rob_index:     integer;

        signal insert_result_s: out std_logic;
        signal cdb:             out cdb_t
    ) is
    begin
        insert_result_s <= insert_result;
        cdb.result <= std_logic_vector(to_unsigned(result, nbit));
        cdb.rob_index <= std_logic_vector(to_unsigned(rob_index, clog2(n_entries_rob)));
    end procedure insert_result_proc;

    procedure assertions (
        issue_ptr_exp: integer;
        commit_ptr_exp: integer;
        full_exp: std_logic;
        misprediction_exp: std_logic;
        memory_we_exp: std_logic;
        registerfile_we_exp: std_logic;
        branch_valid_exp: std_logic;

        signal issue_ptr: in std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        signal commit_ptr: in std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        signal full: in std_logic;
        signal misprediction: in std_logic;
        signal memory_we: in std_logic;
        signal registerfile_we: in std_logic;
        signal branch_valid: in std_logic
    )is
    begin
        assert issue_ptr = std_logic_vector(to_unsigned(issue_ptr_exp, clog2(n_entries_rob)))
            report "issue_ptr error" severity error;
        assert commit_ptr = std_logic_vector(to_unsigned(commit_ptr_exp, clog2(n_entries_rob)))
            report "commit_ptr error" severity error;
        assert full = full_exp
            report "full error" severity error;
        assert misprediction = misprediction_exp
            report "misprediction error" severity error;
        assert memory_we = memory_we_exp
            report "memory_we error" severity error;
        assert registerfile_we = registerfile_we_exp
            report "registerfile_we error" severity error;
        assert branch_valid = branch_valid_exp
            report "branch_valid error" severity error;
    end procedure assertions;

    procedure check_results_proc(
        commit_branch: boolean;
        destination: integer;
        result: integer;
        branch_taken: std_logic;
        branch_addr: integer;
        taken_addr: integer;
        bpu_history: std_logic_vector(1 downto 0);

        signal destination_s: in std_logic_vector(nbit-1 downto 0);
        signal result_s: in std_logic_vector(nbit-1 downto 0);
        signal branch_result: in rob_branch_result_t
    ) is
    begin
        if not commit_branch then
            assert destination_s = std_logic_vector(to_unsigned(destination, nbit))
                report "destination error" severity error;
            assert result_s = std_logic_vector(to_unsigned(result, nbit))
                report "result error" severity error;
        else
            assert branch_result.branch_taken = branch_taken
                report "branch_taken error" severity error;
            assert branch_result.address = std_logic_vector(to_unsigned(branch_addr, nbit))
                report "branch_addr error: got " & integer'image(to_integer(unsigned(branch_result.address))) & " expected " & integer'image(branch_addr)
                severity error;
            assert branch_result.taken_address = std_logic_vector(to_unsigned(taken_addr, nbit))
                report "taken_addr error" severity error;
            assert branch_result.history = bpu_history
                report "bpu_history error" severity error;
        end if;
    end procedure check_results_proc;

begin
    dut: reorder_buffer
        generic map (
            nbit => nbit
        )
        port map (
            clk_i                => clk,
            reset_i              => reset,
            mem_hazard_i         => mem_hazard,
            full_o               => full,
            issue_ptr_o          => issue_ptr,
            commit_ptr_o         => commit_ptr,
            insert_result_i      => insert_result,
            cdb_i                => cdb,
            insert_instruction_i => insert_instruction,
            instruction_i        => instruction,
            destination_o        => destination,
            result_o             => result,
            memory_we_o          => memory_we,
            registerfile_we_o    => registerfile_we,
            branch_result_o      => branch_result,
            misprediction_o      => misprediction
        );
    -- clock generation
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
        mem_hazard <= '0';
        insert_result <= '0';
        cdb.result <= (others => '0');
        cdb.rob_index <= (others => '0');
        insert_instruction <= '0';
        instruction.instruction_type <= instruction_t'low;
        instruction.branch_taken <= '0';
        instruction.destination <= (others => '0');
        wait for 10 ns; -- time 10 ns
        reset <= '0';
        wait for 10 ns; -- time 20 ns
        -- insert jump
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => jump,
            destination => 0,
            branch_taken => '0',
            branch_addr => 0,
            taken_addr => 0,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        wait for 10 ns; -- time 30 ns
        assertions(
            issue_ptr_exp       => 1,
            commit_ptr_exp      => 0,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert store
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => store,
            destination => 1,
            branch_taken => '0',
            branch_addr => 1,
            taken_addr => 1,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        wait for 10 ns; -- time 40 ns
        assertions(
            issue_ptr_exp       => 2,
            commit_ptr_exp      => 0,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert to_reg
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => to_reg,
            destination => 2,
            branch_taken => '0',
            branch_addr => 2,
            taken_addr => 2,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        wait for 10 ns; -- time 50 ns
        assertions(
            issue_ptr_exp       => 3,
            commit_ptr_exp      => 0,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert branch
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => branch,
            destination => 3,
            branch_taken => '0',
            branch_addr => 3,
            taken_addr => 3,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        -- result branch (the result should not be written because rob index is over the issue pointer)
        insert_result_proc(
            insert_result   => '1',
            result          => 1,
            rob_index       => 3,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 60 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        insert_instruction <= '0';
        insert_result <= '0';
        wait for 10 ns; -- time 70 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- result branch
        insert_result_proc(
            insert_result   => '1',
            result          => 0,
            rob_index       => 3,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 80 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- result to_reg
        insert_result_proc(
            insert_result   => '1',
            result          => 2,
            rob_index       => 2,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 90 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- result store
        insert_result_proc(
            insert_result   => '1',
            result          => 1,
            rob_index       => 1,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 100 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- result jump
        insert_result_proc(
            insert_result   => '1',
            result          => 0,
            rob_index       => 0,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 110 ns
        -- commit jump
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        wait for 10 ns; -- time 120 ns
        -- not commit store
        mem_hazard <= '1'; -- this should prevent the store from being committed
        wait for 1 ns; -- needed to let the mem_hazard signal propagate
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 1,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        wait for 9 ns; -- time 130 ns
        -- commit store
        mem_hazard <= '0'; -- this should allow the store to be committed
        wait for 1 ns; -- needed to let the mem_hazard signal propagate
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 1,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '1',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- assert result
        check_results_proc(
            commit_branch => false,
            destination => 1,
            result => 1,
            branch_taken => '-',
            branch_addr => 0,
            taken_addr => 0,
            bpu_history => "00",
            destination_s => destination,
            result_s => result,
            branch_result => branch_result
        );   
        wait for 9 ns; -- time 140 ns
        -- commit to_reg
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 2,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '1',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- assert result
        check_results_proc(
            commit_branch => false,
            destination => 2,
            result => 2,
            branch_taken => '-',
            branch_addr => 0,
            taken_addr => 0,
            bpu_history => "00",
            destination_s => destination,
            result_s => result,
            branch_result => branch_result
        );
        wait for 10 ns; -- time 150 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 3,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '1',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- assert result
        check_results_proc(
            commit_branch => true,
            destination => 0,
            result => 0,
            branch_taken => '0',
            branch_addr => 3,
            taken_addr => 3,
            bpu_history => "00",
            destination_s => destination,
            result_s => result,
            branch_result => branch_result
        );
        wait for 10 ns; -- time 160 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 0,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert load
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => load,
            destination => 4,
            branch_taken => '0',
            branch_addr => 4,
            taken_addr => 4,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        -- result load (it should be ignored because the rob is empty)
        insert_result_proc(
            insert_result   => '1',
            result          => 100,
            rob_index       => 0,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 170 ns
        assertions(
            issue_ptr_exp       => 1,
            commit_ptr_exp      => 0,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert branch
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => branch,
            destination => 5,
            branch_taken => '0',
            branch_addr => 5,
            taken_addr => 5,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        -- result load
        insert_result_proc(
            insert_result   => '1',
            result          => 4,
            rob_index       => 0,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 180 ns
        assertions(
            issue_ptr_exp       => 2,
            commit_ptr_exp      => 0,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '1',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- assert result
        check_results_proc(
            commit_branch => false,
            destination => 4,
            result => 4,
            branch_taken => '-',
            branch_addr => 0,
            taken_addr => 0,
            bpu_history => "00",
            destination_s => destination,
            result_s => result,
            branch_result => branch_result
        );
        -- insert branch
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => branch,
            destination => 6,
            branch_taken => '0',
            branch_addr => 6,
            taken_addr => 6,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        insert_result <= '0';
        wait for 10 ns; -- time 190 ns
        assertions(
            issue_ptr_exp       => 3,
            commit_ptr_exp      => 1,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert branch
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => branch,
            destination => 7,
            branch_taken => '0',
            branch_addr => 7,
            taken_addr => 7,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        wait for 10 ns; -- time 200 ns
        insert_instruction <= '0';
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 1,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        wait for 10 ns; -- time 210 ns
        assertions(
            issue_ptr_exp       => 0,
            commit_ptr_exp      => 1,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert branch
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => branch,
            destination => 8,
            branch_taken => '0',
            branch_addr => 8,
            taken_addr => 8,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        wait for 10 ns; -- time 220 ns
        assertions(
            issue_ptr_exp       => 1,
            commit_ptr_exp      => 1,
            full_exp            => '1',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- insert to_reg (this should not be inserted because the rob is full)
        insert_instruction_proc(
            insert_instruction => '1',
            instruction_type => to_reg,
            destination => 9,
            branch_taken => '0',
            branch_addr => 9,
            taken_addr => 9,
            bpu_history => "00",
            insert_instruction_s => insert_instruction,
            instruction => instruction
        );
        -- result branch (will cause a misprediction)
        insert_result_proc(
            insert_result   => '1',
            result          => 1,
            rob_index       => 1,
            insert_result_s => insert_result,
            cdb => cdb
        );
        wait for 10 ns; -- time 230 ns
        assertions(
            issue_ptr_exp       => 1,
            commit_ptr_exp      => 1,
            full_exp            => '1',
            misprediction_exp   => '1',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '1',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );
        -- assert result
        check_results_proc(
            commit_branch => true,
            destination => 0,
            result => 0,
            branch_taken => '1',
            branch_addr => 5,
            taken_addr => 5,
            bpu_history => "00",
            destination_s => destination,
            result_s => result,
            branch_result => branch_result
        );
        insert_result <= '0';
        wait for 10 ns; -- time 240 ns
        assertions(
            issue_ptr_exp       => 2,
            commit_ptr_exp      => 2,
            full_exp            => '0',
            misprediction_exp   => '0',
            memory_we_exp       => '0',
            registerfile_we_exp => '0',
            branch_valid_exp    => '0',
            issue_ptr       => issue_ptr,
            commit_ptr      => commit_ptr,
            full            => full,
            misprediction   => misprediction,
            memory_we       => memory_we,
            registerfile_we => registerfile_we,
            branch_valid    => branch_result.valid
        );

        wait;
    end process test_proc;
end test;