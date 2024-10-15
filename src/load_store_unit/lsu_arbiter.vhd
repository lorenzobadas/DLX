library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity lsu_arbiter is
    generic (
        nbit: integer := 32
    );
    port (
        clk_i:   in  std_logic;
        reset_i: in  std_logic;
        flush_i: in  std_logic;
        
        -- LSU Reservation Station Interface
        store_enable_i: in std_logic;
        store_rob_id_i: in std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        store_address_i: in std_logic_vector(nbit-1 downto 0);
        store_data_i: in std_logic_vector(nbit-1 downto 0);
        load_to_cdb_o:   out std_logic; -- when valid, the load has been performed and result sent to ROB, entry in RS can be freed
        store_to_cdb_o:  out std_logic; -- when valid, the store has been performed and result sent to ROB, entry in RS can be marked as wait_instr

        -- Memory Interface for Loads
        load_enable_i: in std_logic;
        load_rob_id_i: in std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        load_data_i: in std_logic_vector(nbit-1 downto 0);

        -- CDB Interface
        cdb_ack_i: in std_logic;
        cdb_o: out cdb_t;
        cdb_valid_o: out std_logic
    );
end entity;

architecture beh of lsu_arbiter is
    signal load_rob_id:            std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal load_rob_id_next:       std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal load_result:            std_logic_vector(nbit-1 downto 0);
    signal load_result_next:       std_logic_vector(nbit-1 downto 0);
    signal load_valid:             std_logic;
    signal load_valid_next:        std_logic;
    signal store_rob_id:           std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal store_rob_id_next:      std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal store_result:           std_logic_vector(nbit-1 downto 0);
    signal store_result_next:      std_logic_vector(nbit-1 downto 0);
    signal store_destination:      std_logic_vector(nbit-1 downto 0);
    signal store_destination_next: std_logic_vector(nbit-1 downto 0);
    signal store_valid:            std_logic;
    signal store_valid_next:       std_logic;
begin
    cdb_valid_o <= load_valid or store_valid;

    comb_proc: process(store_enable_i, store_rob_id_i, store_address_i, store_data_i, load_enable_i, load_rob_id_i, load_data_i, cdb_ack_i, load_rob_id, load_result, load_valid, store_rob_id, store_result, store_destination, store_valid)
    begin
        load_rob_id_next       <= load_rob_id;
        load_result_next       <= load_result;
        load_valid_next        <= load_valid;
        store_rob_id_next      <= store_rob_id;
        store_result_next      <= store_result;
        store_destination_next <= store_destination;
        store_valid_next       <= store_valid;
        cdb_o.rob_index        <= load_rob_id;
        cdb_o.result           <= load_result;
        cdb_o.destination      <= store_destination;
        load_to_cdb_o          <= '0';
        store_to_cdb_o         <= '0';

        if store_enable_i = '1' then
            store_rob_id_next      <= store_rob_id_i;
            store_result_next      <= store_data_i;
            store_destination_next <= store_address_i;
            store_valid_next       <= '1';
        end if;

        if load_enable_i = '1' then
            load_rob_id_next <= load_rob_id_i;
            load_result_next <= load_data_i;
            load_valid_next  <= '1';
        end if;

        if load_valid = '0' and store_valid = '1' then
            cdb_o.rob_index   <= store_rob_id;
            cdb_o.result      <= store_result;
            cdb_o.destination <= store_destination;
        end if;

        if cdb_ack_i = '1' then
            if load_valid = '1' then
                load_valid_next <= '0';
                load_to_cdb_o <= '1';
            else
                store_valid_next <= '0';
                store_to_cdb_o <= '1';
            end if;
        end if;

    end process comb_proc;

    seq_proc: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            load_rob_id       <= (others => '0');
            load_result       <= (others => '0');
            load_valid        <= '0';
            store_rob_id      <= (others => '0');
            store_result      <= (others => '0');
            store_destination <= (others => '0');
            store_valid       <= '0';
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                load_rob_id       <= (others => '0');
                load_result       <= (others => '0');
                load_valid        <= '0';
                store_rob_id      <= (others => '0');
                store_result      <= (others => '0');
                store_destination <= (others => '0');
                store_valid       <= '0';
            else
                load_rob_id       <= load_rob_id_next;
                load_result       <= load_result_next;
                load_valid        <= load_valid_next;
                store_rob_id      <= store_rob_id_next;
                store_result      <= store_result_next;
                store_destination <= store_destination_next;
                store_valid       <= store_valid_next;
            end if;
        end if;
    end process seq_proc;
end beh;