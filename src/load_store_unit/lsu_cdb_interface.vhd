library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity lsu_cdb_interface is
    generic (
        nbit: integer := 32
    );
    port (
        clk_i:   in  std_logic;
        reset_i: in  std_logic;
        flush_i: in  std_logic;
        
        -- LSU Reservation Station Interface
        lsu_insert_i:  in  std_logic;
        lsu_rob_id_i:  in  std_logic_vector(clog2(n_entries_rob)-1 downto 0);
        lsu_valid_o:   out std_logic; -- indicates if the slot is taken
        sent_to_cdb_o: out std_logic; -- when valid, the load has been performed and result sent to ROB

        -- Memory Interface for Loads
        load_data_i:       in std_logic_vector(nbit-1 downto 0);
        load_data_valid_i: in std_logic;

        -- CDB Interface
        cdb_ack_i:     in  std_logic;
        cdb_o:         out cdb_t;
        cdb_request_o: out std_logic
    );
end entity;

architecture beh of lsu_cdb_interface is
    signal lsu_rob_id:      std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal lsu_rob_id_next: std_logic_vector(clog2(n_entries_rob)-1 downto 0);
    signal lsu_valid:       std_logic;
    signal lsu_valid_next:  std_logic;
    signal data_valid:      std_logic;
    signal data_valid_next: std_logic;
begin
    sent_to_cdb_o <= cdb_ack_i;
    lsu_valid_o   <= lsu_valid;

    cdb_request_o <= (load_data_valid_i or data_valid) and lsu_valid;
    
    comb_proc: process(lsu_insert_i, lsu_rob_id_i, load_data_i, load_data_valid_i, cdb_ack_i, lsu_rob_id, lsu_valid)
    begin
        lsu_rob_id_next <= lsu_rob_id;
        lsu_valid_next  <= lsu_valid;
        data_valid_next <= load_data_valid_i or data_valid;

        cdb_o.rob_index <= lsu_rob_id;
        cdb_o.result    <= load_data_i;

        -- If a new load is inserted, entry is valid
        -- If no load is inserted, and previous load is sent to CDB, entry is invalid
        if lsu_insert_i = '1' then
            lsu_rob_id_next <= lsu_rob_id_i;
            lsu_valid_next  <= '1';
        elsif load_data_valid_i = '1' and lsu_valid = '1' then
            lsu_valid_next <= '0';
        end if;

        if cdb_ack_i = '1' then
            data_valid_next <= '0';
        end if;
    end process comb_proc;

    seq_proc: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            lsu_rob_id <= (others => '0');
            lsu_valid  <= '0';
            data_valid <= '0';
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                lsu_rob_id <= (others => '0');
                lsu_valid  <= '0';
                data_valid <= '0';
            else
                lsu_rob_id <= lsu_rob_id_next;
                lsu_valid  <= lsu_valid_next;
                data_valid <= data_valid_next;
            end if;
        end if;
    end process seq_proc;
end beh;