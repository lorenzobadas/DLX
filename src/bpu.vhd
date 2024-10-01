library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity bpu is
    generic (
        n_entries_bpu: integer := 64
    );
    port (
        clk_i: in  std_logic;
        reset_i: in  std_logic;
        pc_cut_i: in  std_logic_vector(clog2(n_entries_bpu)-1 downto 0);
        prediction_o: out std_logic;

        -- Reorder Buffer Interface
        rob_result_i: in rob_branch_result_t
    );
end entity;

architecture beh of bpu is
    type bpu_entry is array(0 to 3) of std_logic_vector(1 downto 0);
    type bpu_table_t is array(0 to n_entries_bpu-1) of bpu_entry;
    signal bpu_table: bpu_table_t;
    signal history: unsigned(1 downto 0);
begin
    read_proc: process(pc_cut_i, bpu_table, history)
    begin
        prediction_o <= bpu_table(to_integer(unsigned(pc_cut_i)))(to_integer(history))(1); -- MSB is the prediction
    end process read_proc;

    write_proc: process(clk_i, reset_i, rob_result_i)
    begin
        if reset_i = '1' then
            bpu_table <= (others => (others => (1 => '0', 0 => '1'))); -- Resets to weakly not taken
            history   <= (others => '0');
        elsif rising_edge(clk_i) then
            if rob_result_i.valid = '1' then
                history <= history(0) & rob_result_i.branch_taken;
                case bpu_table(to_integer(unsigned(rob_result_i.address)))(to_integer(unsigned(rob_result_i.history))) is
                    when "00" => -- strong not taken
                        bpu_table(to_integer(unsigned(rob_result_i.address)))(to_integer(unsigned(rob_result_i.history)))(0) <= rob_result_i.branch_taken;
                    when "01" => -- weakly not taken
                        bpu_table(to_integer(unsigned(rob_result_i.address)))(to_integer(unsigned(rob_result_i.history))) <= (others => rob_result_i.branch_taken);
                    when "10" => -- weakly taken
                        bpu_table(to_integer(unsigned(rob_result_i.address)))(to_integer(unsigned(rob_result_i.history))) <= (others => rob_result_i.branch_taken);
                    when "11" => -- strong taken
                        bpu_table(to_integer(unsigned(rob_result_i.address)))(to_integer(unsigned(rob_result_i.history)))(0) <= rob_result_i.branch_taken;
                    when others =>
                        bpu_table <= bpu_table;
                end case;
            end if;
        end if;
    end process write_proc;
end beh;