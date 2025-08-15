library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_fetch is
    generic (
        nbit: integer := 32
    ); 
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        pc_i:       in  std_logic_vector(nbit-1 downto 0);
        npc_o:      out std_logic_vector(nbit-1 downto 0);
        ir_o:       out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture struct of instr_fetch is
    component reg is 
        generic (
            nbit: integer := 32
        ); 
        port (
            clk_i:      in  std_logic;
            reset_i:    in  std_logic;
            in_i:       in  std_logic_vector(nbit-1 downto 0);
            out_o:      out std_logic_vector(nbit-1 downto 0)
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

    component imem is
        generic(
            ram_width : integer := 32;
            ram_depth : integer := 32;
            ram_add   : integer := 5;
            init_file : string := "imem.mem"
        );
        port(
            clk_i  : in std_logic;
            reset_i: in std_logic;
            en_i   : in std_logic;
            addr_i : in std_logic_vector(ram_add-1 downto 0);  
            rd_o   : out std_logic;
            dout_o : out std_logic_vector(ram_width-1 downto 0)
        ); 
    end component;

    signal next_pc, npc, next_npc, ir, next_ir: std_logic_vector(nbit-1 downto 0);
begin
    npc_o <= next_npc;
    ir_o <= next_ir;
    pc_reg: reg
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
            b => (3 => '1', others => '0'), -- add 4
            cin => '0',
            sub => '0',
            s => npc,
            cout => open
        );

    npc_reg: reg
        generic map (
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            in_i => npc,
            out_o => next_npc
        );

    instr_mem: imem
        generic map (
            ram_width => nbit,
            ram_depth => 1024,
            ram_add => 10,
            init_file => "imem.mem"
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            en_i => '1',
            addr_i => next_pc(9 downto 0),
            rd_o => open, -- TODO
            dout_o => ir
        );

    ir_reg: reg
        generic map (
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            in_i => ir,
            out_o => next_ir
        );

end architecture;
