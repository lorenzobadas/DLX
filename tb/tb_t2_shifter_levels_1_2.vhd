library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity tb_t2_shifter_levels_1_2 is
end tb_t2_shifter_levels_1_2;

architecture test of tb_t2_shifter_levels_1_2 is
    component t2_shifter_levels_1_2 is
        generic(
            nbit: integer := 64
        );
        port(
            data_i:        in  std_logic_vector(nbit-1 downto 0);
            selection_i:     in  std_logic_vector(clog2(nbit/8)-1 downto 0);
            logic_arith_i: in  std_logic;
            left_right_i:  in  std_logic;
            data_o:        out std_logic_vector((nbit+8)-2 downto 0)
        );
    end component;
    constant nbit: integer := 64;
    signal data: std_logic_vector(nbit-1 downto 0);
    signal selection: std_logic_vector(clog2(nbit/8)-1 downto 0);
    signal logic_arith: std_logic;
    signal left_right: std_logic;
    signal data_out: std_logic_vector((nbit+8)-2 downto 0);
    signal data_out_bitvector: bit_vector((nbit+8)-2 downto 0);
begin
    dut: t2_shifter_levels_1_2
        generic map(
            nbit => nbit
        )
        port map (
            data_i => data,
            selection_i => selection,
            logic_arith_i => logic_arith,
            left_right_i => left_right,
            data_o => data_out
        );
    data <= "1010110011010011110100010111000101100101010100011000110010010110";
    data_out_bitvector <= to_bitvector(data_out);
    process
        variable tmp: bit_vector((nbit+8)-2 downto 0) := (others => '0');
    begin
        for i in 0 to (nbit/8)-1 loop
            selection <= std_logic_vector(to_unsigned(i, clog2(nbit/8)));
            logic_arith <= '0';
            left_right <= '0';
            wait for 10 ns;
            tmp := to_bitvector(data) sll (i*8);
            assert data_out_bitvector = tmp report "Error in shift left logical" severity error;
        end loop;
        for i in 0 to (nbit/8)-1 loop
            selection <= std_logic_vector(to_unsigned(i, clog2(nbit/8)));
            logic_arith <= '1';
            left_right <= '0';
            wait for 10 ns;
            tmp := to_bitvector(data) sla (i*8);
            assert data_out_bitvector = tmp report "Error in shift left arithmetic" severity error;
        end loop;
        for i in 0 to (nbit/8)-1 loop
            selection <= std_logic_vector(to_unsigned(i, clog2(nbit/8)));
            logic_arith <= '0';
            left_right <= '1';
            wait for 10 ns;
            tmp := to_bitvector(data) srl (i*8);
            assert data_out_bitvector = tmp report "Error in shift right logical" severity error;
        end loop;
        for i in 0 to (nbit/8)-1 loop
            selection <= std_logic_vector(to_unsigned(i, clog2(nbit/8)));
            logic_arith <= '1';
            left_right <= '1';
            wait for 10 ns;
            tmp := to_bitvector(data) sra (i*8);
            assert data_out_bitvector = tmp report "Error in shift right arithmetic" severity error;
        end loop;
    end process;
end test;