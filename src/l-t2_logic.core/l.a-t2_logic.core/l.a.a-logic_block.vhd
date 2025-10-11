library ieee;
use ieee.std_logic_1164.all;
use work.alu_instr_pkg.all;

entity logic_block is
    port(
        s_i: in  std_logic_vector(3 downto 0);
        a_i: in  std_logic;
        b_i: in  std_logic;
        out_o: out std_logic
    );
end entity;

architecture struct of logic_block is
    component nand3 is
        port (
            a_i: in  std_logic;
            b_i: in  std_logic;
            c_i: in  std_logic;
            y_o: out std_logic
        );
    end component;
    
    component nand4 is
        port (
            a_i: in  std_logic;
            b_i: in  std_logic;
            c_i: in  std_logic;
            d_i: in  std_logic;
            y_o: out std_logic
        );
    end component;
    
    signal not_a: std_logic;
    signal not_b: std_logic;
    signal l0 : std_logic;
    signal l1 : std_logic;
    signal l2 : std_logic;
    signal l3 : std_logic;
begin
    not_a <= not a_i;
    not_b <= not b_i;
    nand3_inst0: nand3
        port map (
            a_i => s_i(0),
            b_i => not_a,
            c_i => not_b,
            y_o => l0
        );
    nand3_inst1: nand3
        port map (
            a_i => s_i(1),
            b_i => not_a,
            c_i => b_i,
            y_o => l1
        );
    nand3_inst2: nand3
        port map (
            a_i => s_i(2),
            b_i => a_i,
            c_i => not_b,
            y_o => l2
        );
    nand3_inst3: nand3
        port map (
            a_i => s_i(3),
            b_i => a_i,
            c_i => b_i,
            y_o => l3
        );

    nand4_inst: nand4
        port map (
            a_i => l0,
            b_i => l1,
            c_i => l2,
            d_i => l3,
            y_o => out_o
        );
end architecture struct;
