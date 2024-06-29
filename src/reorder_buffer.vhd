library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity reorder_buffer is
    generic (
        nbit: integer := 32;
    );
    port (
        clk_i: in std_logic;
        rst_i: in std_logic;
        hazard_i: in std_logic; -- stall if high
        insert_i: in std_logic;
        flush_branch_i: in std_logic;
        cdb_i: in cdb_t;
        instruction_i: in rob_decoded_instruction;
        full_o: out std_logic;
        destination_o: out std_logic_vector(nbit-1 downto 0);
        mem_write_en_o: out std_logic;
        reg_write_en_o: out std_logic
    );
end reorder_buffer;

architecture behav of reorder_buffer is
    type rob_array is array(0 to n_entries_rob-1) of rob_entry;
    signal rob_fifo: rob_array;
    signal head_ptr: integer := 0;
    signal tail_ptr: integer := 0;
begin
end behav;