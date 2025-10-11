library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_pkg.all;

entity instr_fetch is
    generic (
        nbit : integer := 32
    ); 
    port (
        clk_i   : in  std_logic;
        reset_i : in  std_logic;
        pc_enable_i : in  std_logic;
        PCSrc_i : in  std_logic;
        branch_pc_i: in  std_logic_vector(nbit-1 downto 0);
        instr_addr_o : out std_logic_vector(imem_addr_size-1 downto 0);
        npc_o   : out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture struct of instr_fetch is
    component mux2to1 is
        generic(
            nbit: integer := 32
        );
        port(
            in0_i:  in  std_logic_vector(nbit-1 downto 0);
            in1_i:  in  std_logic_vector(nbit-1 downto 0);
            sel_i:  in  std_logic;
            out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component pc is 
        generic (
            nbit: integer := 32
        ); 
        port (
            clk_i   :   in  std_logic;
            reset_i :   in  std_logic;
            enable_i:   in  std_logic;
            in_i    :   in  std_logic_vector(nbit-1 downto 0);
            out_o   :   out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component p4_adder is
        generic (
            nbit: integer := 32;
            subtractor: integer := 0
        );
        port (
            a   : in  std_logic_vector(nbit-1 downto 0);
            b   : in  std_logic_vector(nbit-1 downto 0);
            cin : in  std_logic;
            sub : in  std_logic;
            s   : out std_logic_vector(nbit-1 downto 0);
            cout: out std_logic
        );
    end component;

    signal next_pc_s, pc_s: std_logic_vector(nbit-1 downto 0);
    signal npc_s: std_logic_vector(nbit-1 downto 0);
begin
    mux: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => npc_s,
            in1_i => branch_pc_i,
            sel_i => PCSrc_i,
            out_o => next_pc_s
        );

    pc_reg: pc
        generic map (
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            enable_i => pc_enable_i,
            in_i => next_pc_s,
            out_o => pc_s
        );

    adder: p4_adder
        generic map (
            nbit => nbit,
            subtractor => 0
        )
        port map (
            a => pc_s,
            b => (std_logic_vector(to_unsigned(4, nbit))),
            cin => '0',
            sub => '0',
            s => npc_s,
            cout => open
        );

    instr_addr_o <= pc_s(imem_addr_size-1 downto 0);
    npc_o <= npc_s;

end architecture;
