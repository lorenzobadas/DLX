library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_control_boothmul is
end entity;

architecture test of tb_control_boothmul is
    
    -- Constants
    constant nbit : integer := 32;
    constant num_stages : integer := (nbit/2) - 2;  -- 14 stages
    constant clk_period : time := 10 ns;
    constant pipeline_depth : integer := num_stages;  -- 14 stages
    
    -- DUT
    component booth_pipeline_controller is
        generic (
            nbit : integer := 32
        );
        port (
            clk_i   : in std_logic;
            reset_i : in std_logic;
            flush_i : in std_logic;
            enable_i : in std_logic;
            stall_o  : out std_logic;
            bus_grant_i       : in std_logic;
            arbiter_request_o : out std_logic;
            load_o : out std_logic_vector((nbit/2)-3 downto 0);
            mult_reset_o : out std_logic
        );
    end component;
    
    -- Test signals
    signal clk_i   : std_logic := '0';
    signal reset_i : std_logic := '0';
    signal flush_i : std_logic := '0';
    signal enable_i : std_logic := '0';
    signal stall_o  : std_logic;
    signal bus_grant_i       : std_logic := '1';
    signal arbiter_request_o : std_logic;
    signal load_o : std_logic_vector(num_stages-1 downto 0);
    signal mult_reset_o : std_logic;
    
    -- Test control
    signal test_running : boolean := true;
    
    -- Data tracking for bubble management verification
    type data_tracker_t is array(0 to num_stages-1) of integer;
    signal data_in_stage : data_tracker_t := (others => -1);  -- -1 == bubble
    signal data_id_counter : integer := 0;
    
    -- Stats
    signal total_cycles : integer := 0;
    signal items_inserted : integer := 0;
    signal items_completed : integer := 0;  -- driven by pipeline_model
    signal stall_cycles : integer := 0;     -- driven by cycle_counter
    signal items_completed_clear : std_logic := '0';  -- signal to reset counter
    signal stall_cycles_clear : std_logic := '0';     -- signal to reset stall counter
    
    -- helper std_logic -> string (non so perché ma non mi va la report normale)
    function slv_to_string(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
        variable j : integer := 1;
    begin
        for i in slv'range loop
            if slv(i) = '1' then
                result(j) := '1';
            elsif slv(i) = '0' then
                result(j) := '0';
            else
                result(j) := 'X';
            end if;
            j := j + 1;
        end loop;
        return result;
    end function;
    
    -- Helper procedures
    procedure wait_clk is
    begin
        wait until rising_edge(clk_i);
    end procedure;
    
    procedure wait_clks(n : integer) is
    begin
        for i in 1 to n loop
            wait_clk;
        end loop;
    end procedure;
    
    procedure print_msg(msg : string) is
        variable line_out : line;
    begin
        write(line_out, string'("[") & integer'image(total_cycles) & string'("] "));
        write(line_out, msg);
        writeline(output, line_out);
    end procedure;
    
    procedure print_pipeline_state is
        variable line_out : line;
    begin
        write(line_out, string'("Pipeline: "));
        for i in 0 to num_stages-1 loop
            if data_in_stage(i) = -1 then
                write(line_out, string'(" . "));
            else
                write(line_out, string'(" ") & integer'image(data_in_stage(i) mod 10) & string'(" "));
            end if;
        end loop;
        write(line_out, string'(" | stall=") & std_logic'image(stall_o));
        write(line_out, string'(" req=") & std_logic'image(arbiter_request_o));
        write(line_out, string'(" grant=") & std_logic'image(bus_grant_i));
        writeline(output, line_out);
    end procedure;
    
    procedure verify_throughput(
        test_name : string; 
        expected_min : integer; 
        expected_max : integer;
        start_count : integer;
        current_count : integer
    ) is
        variable actual : integer;
    begin
        actual := current_count - start_count;
        if actual >= expected_min and actual <= expected_max then
            print_msg("PASS: " & test_name & " - completed " & integer'image(actual) & " items");
        else
            print_msg("FAIL: " & test_name & " - expected " & integer'image(expected_min) & 
                     "-" & integer'image(expected_max) & ", got " & integer'image(actual));
        end if;
    end procedure;
    
    procedure verify_latency(
        test_name : string;
        start_cycle : integer;
        current_cycle : integer;
        expected_latency : integer
    ) is
        variable actual_latency : integer;
    begin
        actual_latency := current_cycle - start_cycle;
        if actual_latency = expected_latency then
            print_msg("PASS: " & test_name & " - latency = " & integer'image(actual_latency));
        else
            print_msg("FAIL: " & test_name & " - expected latency " & integer'image(expected_latency) & 
                     ", got " & integer'image(actual_latency));
        end if;
    end procedure;

begin
    ------------------------------------
    -- CLOCK
    ------------------------------------
    clk_process: process
    begin
        while test_running loop
            clk_i <= '0';
            wait for clk_period/2;
            clk_i <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    ------------------------------------
    -- COUNTER FOR CYCLES AND STALLS
    ------------------------------------
    cycle_counter: process(clk_i)
    begin
        if rising_edge(clk_i) then
            total_cycles <= total_cycles + 1;
            
            if stall_cycles_clear = '1' then
                stall_cycles <= 0;
            elsif stall_o = '1' and enable_i = '1' then
                stall_cycles <= stall_cycles + 1;
            end if;
        end if;
    end process;
    
    dut: booth_pipeline_controller
        generic map (
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            flush_i => flush_i,
            enable_i => enable_i,
            stall_o => stall_o,
            bus_grant_i => bus_grant_i,
            arbiter_request_o => arbiter_request_o,
            load_o => load_o,
            mult_reset_o => mult_reset_o
        );
    
    ------------------------------------
    -- GOLDEN MODEL OF THE PIPELINE
    ------------------------------------
    pipeline_model: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if items_completed_clear = '1' then
                items_completed <= 0;
            end if;
            
            if reset_i = '1' or flush_i = '1' then
                -- clear of all the stages
                data_in_stage <= (others => -1);
            else
                for i in num_stages-1 downto 0 loop
                    if load_o(i) = '1' then
                        if i = num_stages-1 then
                            -- last stage exits if thereś the grant
                            if data_in_stage(i) /= -1 and bus_grant_i = '1' then
                                items_completed <= items_completed + 1;
                            end if;
                            -- load from previous stage
                            if i > 0 then
                                data_in_stage(i) <= data_in_stage(i-1);
                            end if;
                        elsif i = 0 then
                            -- first stage loads new data if enabled
                            if enable_i = '1' then
                                data_in_stage(0) <= data_id_counter;
                            else
                                data_in_stage(0) <= -1;  -- bubble insertion
                            end if;
                        else
                            -- middle stages load from previous
                            data_in_stage(i) <= data_in_stage(i-1);
                        end if;
                    end if;
                end loop;
            end if;
        end if;
    end process;
    
    ---------------------------- MAIN TEST PROCESS ----------------------------
    test_process: process
        variable start_cycle : integer;
        variable test_pass : boolean;
        variable test_items_start : integer := 0;
        variable test_stalls_start : integer := 0;
    begin
        
        print_msg("=== Controller testbench ===");
        print_msg("Pipeline depth: " & integer'image(pipeline_depth) & " stages");
        wait_clks(5);
        
        -- ========== TEST 1: reset ==========
        print_msg(">>> TEST 1: Clearing all pipeline stages");
        -- Fill the pipeline partially
        for i in 0 to 4 loop
            enable_i <= '1';
            wait_clk;
            enable_i <= '0';
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
        end loop;
        wait_clks(3);
        
        -- Reset
        reset_i <= '1';
        wait_clk;
        reset_i <= '0';
        wait_clk;
        wait_clk;
        
        -- did we empty the pipeline?
        test_pass := true;
        for i in 0 to num_stages-1 loop
            if data_in_stage(i) /= -1 then
                test_pass := false;
                print_msg("Stage " & integer'image(i) & " not empty: " & integer'image(data_in_stage(i)));
            end if;
        end loop;
        if test_pass and arbiter_request_o = '0' then
            print_msg("PASS: Reset clears pipeline");
        else
            print_msg("FAIL: Reset did not clear everything");
            print_msg("arbiter_request_o = " & std_logic'image(arbiter_request_o));
            print_msg("mult_reset_o = " & std_logic'image(mult_reset_o));
        end if;
        
        -- Clear items_completed counter
        items_completed_clear <= '1';
        wait_clk;
        items_completed_clear <= '0';
        
        -- ========== TEST 2: Latency of a single insertion ==========
        print_msg(">>> TEST 2: Single item exact latency");
        start_cycle := total_cycles;
        
        enable_i <= '1';
        wait_clk;
        enable_i <= '0';
        items_inserted <= items_inserted + 1;
        print_msg("Inserted item " & integer'image(data_id_counter));
        data_id_counter <= data_id_counter + 1;
        
        -- wait for output
        while arbiter_request_o = '0' and (total_cycles - start_cycle) < 20 loop
            wait_clk;
        end loop;
        
        verify_latency("Single item latency", start_cycle, total_cycles, pipeline_depth + 1);
        wait_clk;  -- Let it complete
        
        -- ========== TEST 3: Back2back without bubbles ==========
        print_msg(">>> TEST 3: Back-to-back items - without bubbles");
        test_items_start := items_completed;
        start_cycle := total_cycles;
        
        -- let's insert items continuously
        enable_i <= '1';
        for i in 0 to 9 loop
            wait_clk;
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
        end loop;
        enable_i <= '0';
        
        -- wait for all to complete
        wait_clks(pipeline_depth + 5);
        
        verify_throughput("Continuous items", 10, 10, test_items_start, items_completed);
        
        -- ========== TEST 4: single bubbles insertions ==========
        print_msg(">>> TEST 4: bubble alternating pattern");
        test_items_start := items_completed;
        
        -- alternating pattern: item, bubble, item, bubble...
        for i in 0 to 9 loop
            enable_i <= '1';
            wait_clk;
            enable_i <= '0';
            items_inserted <= items_inserted + 1;
            print_msg("Inserted item " & integer'image(data_id_counter));
            data_id_counter <= data_id_counter + 1;
            wait_clk;  -- create bubble
        end loop;
        
        wait_clks(pipeline_depth + 10);
        verify_throughput("Alternating pattern", 10, 10, test_items_start, items_completed);
        
        -- ========== TEST 5:  ==========
        print_msg(">>> TEST 5: Multiple bubbles between items");
        test_items_start := items_completed;
        
        -- pattern: item, 3 bubbles, item, 3 bubbles...
        for i in 0 to 4 loop
            enable_i <= '1';
            wait_clk;
            enable_i <= '0';
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
            wait_clks(3);  -- 3 bubbles
        end loop;
        
        wait_clks(pipeline_depth + 15);
        verify_throughput("Items with 3-bubble gaps", 5, 5, test_items_start, items_completed);
        
        -- ========== TEST 6 : stall conditions ==========
        print_msg(">>> TEST 6: stall conditions");
        
        -- Clear pipeline
        wait_clks(30);
        
        -- insert exactly num_stages items to fill every stage
        bus_grant_i <= '0';  -- block output from the start
        for i in 0 to num_stages-1 loop
            enable_i <= '1';
            wait_clk;
            enable_i <= '0';
            data_id_counter <= data_id_counter + 1;
        end loop;
        
        -- Wait for pipeline to settle
        wait_clks(2);
        print_msg("Pipeline after inserting " & integer'image(num_stages) & " items with grant=0:");
        print_pipeline_state;
        
        -- Now try to insert one more
        enable_i <= '1';
        wait_clk;
        print_msg("After trying to insert with full pipeline:");
        print_msg("stall_o = " & std_logic'image(stall_o));
        print_msg("load_o = " & slv_to_string(load_o));
        print_pipeline_state;
        
        -- Check if we inserted the item despite full pipeline
        if stall_o = '0' then
            print_msg("INFO: Controller accepts inserts even with grant=0");
        end if;
        
        enable_i <= '0';
        bus_grant_i <= '1';
        wait_clks(30);
        
        -- ========== TEST 7: Stall when pipeline is truly full ==========
        print_msg(">>> TEST 7: stall when pipeline is truly full");
        test_items_start := items_completed;
        test_stalls_start := stall_cycles;

        -- fill every stage with grant = '1'
        bus_grant_i <= '1';
        for i in 1 to num_stages loop
            enable_i <= '1';
            wait until rising_edge(clk_i);
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
        end loop;
        enable_i <= '0';

        -- immediately cut grant so nothing can shift out
        bus_grant_i <= '0';
        wait until rising_edge(clk_i);

        -- try one more insert—should be blocked
        enable_i <= '1';
        wait until rising_edge(clk_i);

        -- stall?
        print_msg("Current stall_o = " & std_logic'image(stall_o));
        print_pipeline_state;
        if stall_o = '1' then
            print_msg("PASS: Stall activated when pipeline completely full");
        else
            print_msg("FAIL: stall_o should be '1' when pipeline is full and grant='0'");
        end if;

        -- how many stall cycles we saw?
        print_msg("Stall cycles during full pipeline: " & integer'image(stall_cycles - test_stalls_start));

        -- restore and drain
        enable_i    <= '0';
        bus_grant_i <= '1';
        wait_clks(num_stages);  -- let everything shift out

        -- ========== TEST 8: Backpressure propagation ==========
        print_msg(">>> TEST 8: Backpressure propagation through stages");
        test_items_start := items_completed;
        
        -- fill pipeline completely first
        bus_grant_i <= '1';
        for i in 0 to num_stages-1 loop
            enable_i <= '1';
            wait_clk;
            enable_i <= '0';
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
        end loop;
        
        wait_clks(num_stages - 1);  -- let all data reach their positions
        
        -- block output and try to insert one more
        bus_grant_i <= '0';
        wait_clk;
        print_pipeline_state;
        
        -- Verify if the last stage load is 0
        if load_o(num_stages-1) = '0' then
            print_msg("PASS: Last stage blocked when grant denied");
        else
            print_msg("FAIL: Last stage should be blocked");
        end if;
        
        -- insert one more item -> this should cause stall
        enable_i <= '1';
        wait_clk;
        
        -- Check stall with truly full pipeline
        if stall_o = '1' then
            print_msg("PASS: Stall activated with full pipeline and no grant");
        else
            print_msg("INFO: No stall - checking ready propagation");
            print_msg("load_o = " & slv_to_string(load_o));
        end if;
        
        enable_i <= '0';
        bus_grant_i <= '1';
        wait_clks(20);
        
        -- ========== TEST 9: Flush during operation ==========
        print_msg(">>> TEST 8: Flush clears pipeline during operation");
        test_items_start := items_completed;
        
        -- Fill pipeline halfway
        for i in 0 to 6 loop
            enable_i <= '1';
            wait_clk;
            enable_i <= '0';
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
        end loop;
        wait_clks(3);
        print_pipeline_state;
        
        -- Flush
        flush_i <= '1';
        wait_clk;
        flush_i <= '0';
        wait_clk;
        
        -- Verify empty
        test_pass := true;
        for i in 0 to num_stages-1 loop
            if data_in_stage(i) /= -1 then
                test_pass := false;
            end if;
        end loop;
        
        if test_pass then
            print_msg("PASS: Flush cleared all stages");
        else
            print_msg("FAIL: Pipeline not empty after flush");
        end if;
        
        -- ========== TEST 10 ==========
        print_msg(">>> TEST 10: more complex insertions");
        test_items_start := items_completed;
        
        -- burst, gap, burst, gap pattern
        for burst in 0 to 2 loop
            -- Burst of 5 items
            for i in 0 to 4 loop
                enable_i <= '1';
                wait_clk;
                enable_i <= '0';
                items_inserted <= items_inserted + 1;
                data_id_counter <= data_id_counter + 1;
            end loop;
            -- Gap of 7 cycles
            wait_clks(7);
        end loop;
        
        wait_clks(pipeline_depth + 10);
        verify_throughput("Burst pattern", 15, 15, test_items_start, items_completed);
        
        -- ========== TEST 11: toggling grant during operation ==========
        -- this is just a sanity check, i should compute the number of insertions but the purpose
        -- of the test is just to see if the number has a meaning or something strage is going on
        print_msg(">>> TEST 11: grant toggling effects");
        test_items_start := items_completed;
        
        -- insert continuous stream
        enable_i <= '1';
        
        for i in 0 to 30 loop
            wait_clk;
            -- toggle grant every 3 cycles
            if (i mod 3) = 0 then
                bus_grant_i <= not bus_grant_i;
            end if;
            
            -- stop inserting after pipeline is full
            if i = pipeline_depth then
                enable_i <= '0';
            else
                items_inserted <= items_inserted + 1;
                data_id_counter <= data_id_counter + 1;
            end if;
        end loop;
        
        bus_grant_i <= '1';
        wait_clks(20);
        
        print_msg("Items completed with grant toggling: " & integer'image(items_completed - test_items_start));
        
        -- ========== TEST 12: maximum throughput test ==========
        print_msg(">>> TEST 12: maximum sustainable throughput");
        test_items_start := items_completed;
        start_cycle := total_cycles;
        
        -- run continuously for 100 cycles
        enable_i <= '1';
        for i in 0 to 99 loop
            wait_clk;
            items_inserted <= items_inserted + 1;
            data_id_counter <= data_id_counter + 1;
        end loop;
        enable_i <= '0';
        
        -- drain pipeline
        wait_clks(pipeline_depth + 5);
        
        print_msg("Completed " & integer'image(items_completed - test_items_start) & " items in " & 
                 integer'image(total_cycles - start_cycle) & " cycles");
        
        if (items_completed - test_items_start) >= 95 then
            print_msg("PASS: Near 100% throughput achieved");
        else
            print_msg("WARN: Lower than expected throughput");
        end if;
        
        -- ========== TEST 13: stall release timing ==========
        print_msg(">>> TEST 12: stall release timing");
        
        -- First, let's understand when stall actually occurs
        -- Stall = enable_i and busy(0) and not ready(0)
        -- This means stage 0 must be busy AND unable to advance
        
        -- fill entire pipeline, then try to insert while blocked
        bus_grant_i <= '1';  -- Allow initial filling
        enable_i <= '1';
        wait_clks(pipeline_depth);  -- Fill all stages
        enable_i <= '0';
        
        -- now block output and try to insert more
        wait_clks(pipeline_depth - 1);  -- let data reach last stage
        bus_grant_i <= '0';  -- block output
        wait_clk;
        
        -- now try to insert --> this should cause stall
        enable_i <= '1';
        wait_clk;
        
        if stall_o = '1' then
            print_msg("PASS: Stall activated when stage 0 blocked");
        else
            print_msg("INFO: No stall - stage 0 may still have room");
        end if;
        
        -- release and verify
        bus_grant_i <= '1';
        wait_clk;
        
        if stall_o = '0' then
            print_msg("PASS: Stall released (or prevented) by grant");
        else
            print_msg("WARN: Stall persists after grant");
        end if;
        
        enable_i <= '0';
        wait_clks(20);
        
        -- ========== TEST 14: pipeline state consistency (per-cycle) ==========
        print_msg(">>> TEST 14: pipeline state consistency check");
        test_items_start := items_completed;

        -- run 200 cycles of random enable/grant and dump the pipeline each cycle
        for i in 0 to 199 loop
            -- random enable pattern
            if (i mod 3) = 0 or (i mod 5) = 0 then
                enable_i <= '1';
                items_inserted <= items_inserted + 1;
                data_id_counter <= data_id_counter + 1;
            else
                enable_i <= '0';
            end if;

            -- random grant pattern
            if (i mod 7) < 5 then
                bus_grant_i <= '1';
            else
                bus_grant_i <= '0';
            end if;

            -- one clock tick
            wait until rising_edge(clk_i);

            -- print cycle count and exact pipeline contents
            print_msg("Cycle " & integer'image(total_cycles) &
                      "  enable=" & std_logic'image(enable_i) &
                      "  grant="  & std_logic'image(bus_grant_i) &
                      "  req="    & std_logic'image(arbiter_request_o) &
                      "  stall="  & std_logic'image(stall_o));
            print_pipeline_state;
        end loop;

        print_msg("Completed per-cycle dump for TEST 13; items processed: " &
                  integer'image(items_completed - test_items_start));
        
        -- ========== SUMMARY ==========
        print_msg("=== TEST SUMMARY ===");
        print_msg("Total cycles: " & integer'image(total_cycles));
        print_msg("Total items inserted: " & integer'image(items_inserted));
        print_msg("Total items completed: " & integer'image(items_completed));
        print_msg("Total stall cycles: " & integer'image(stall_cycles));
        
        test_running <= false;
        wait;
        
    end process;

end test;