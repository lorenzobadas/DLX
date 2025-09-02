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
        pc_i    : in  std_logic_vector(nbit-1 downto 0);
        instr_i : out std_logic_vector(imem_width-1 downto 0);
        instr_addr_o : out std_logic_vector(imem_addr-1 downto 0);
        npc_o   : out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture struct of instr_fetch is
    component pc is 
        generic (
            nbit: integer := 32
        ); 
        port (
            clk_i   :   in  std_logic;
            reset_i :   in  std_logic;
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

    signal next_pc: std_logic_vector(nbit-1 downto 0);
begin
    pc_reg: pc
        generic map (
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            in_i => pc_i,
            out_o => next_pc
        );

    adder: p4_adder
        generic map (
            nbit => nbit,
            subtractor => 0
        )
        port map (
            a => next_pc,
            b => (std_logic_vector(to_unsigned(4, nbit))),
            cin => '0',
            sub => '0',
            s => npc_o,
            cout => '0'
        );

    instr_addr_o <= next_pc;

end architecture;
