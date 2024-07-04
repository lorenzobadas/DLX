library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity tb_reorder_buffer is
end tb_reorder_buffer;

architecture test of tb_reorder_buffer is
    -- procedure declarations
    procedure insert_instruction(signal insert:           in std_logic;
                                 signal instruction:      in rob_decoded_instruction;
                                 signal instruction_type: in instruction_t;
                                 signal branch_taken:     in std_logic;
                                 signal destination:      in std_logic_vector(nbit-1 downto 0)) is
    begin
        instruction.instruction_type <= instruction_type;
        instruction.branch_taken     <= branch_taken;
        instruction.destination      <= destination;
        insert <= '1';
    end procedure insert_instruction;
    procedure cdb_result(signal cdb:       in cdb_t;
                         signal result:    in std_logic_vector(nbit-1 downto 0);
                         signal rob_index: in std_logic) is
    begin
        cdb.result    <= result;
        cdb.rob_index <= rob_index;
    end procedure cdb_result;
    -- component declarations
    component reorder_buffer is
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
    end component;
    -- signal declaration
    signal clk:           std_logic;
    signal rst:           std_logic;
    signal hazard:        std_logic;
    signal insert:        std_logic;
    signal cdb:           cdb_t;
    signal instruction:   rob_decoded_instruction;
    signal full:          std_logic;
    signal destination:   std_logic_vector(31 downto 0);
    signal result:        std_logic_vector(31 downto 0);
    signal mem_write_en:  std_logic;
    signal reg_write_en:  std_logic;
    signal misprediction: std_logic;
    signal issue_ptr:     std_logic_vector(2 downto 0);
begin
    
    dut: reorder_buffer
        generic map (
            nbit => nbit
        )
        port map (
            clk_i           => clk,
            rst_i           => rst,
            hazard_i        => hazard,
            insert_i        => insert,
            cdb_i           => cdb,
            instruction_i   => instruction,
            full_o          => full,
            destination_o   => destination,
            result_o        => result,
            mem_write_en_o  => mem_write_en,
            reg_write_en_o  => reg_write_en,
            misprediction_o => misprediction,
            issue_ptr_o     => issue_ptr
        );

    test_proc: process
    begin
        rst <= '1';
        wait for 7 ns;
        rst <= '0';
        insert_instruction(
            insert           => insert,
            instruction      => instruction,
            instruction_type => to_reg,
            branch_taken     => '0',
            destination      => (others => '0')
        );
        cdb_result(
            cdb       => cdb,
            result    => (others => '0'),
            rob_index => (others => '0')
        );
        wait for 10 ns;
    end process test_proc;

    clk_proc: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process clk_proc;
end test;