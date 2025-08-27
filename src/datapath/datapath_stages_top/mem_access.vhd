library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_access is
    generic (
        nbit: integer := 32
    );
    port (
        clk_i:      in  std_logic;
        reset_i:    in  std_logic;
        npc_i:      in  std_logic_vector(nbit-1 downto 0);
        mux_sel_i:  in  std_logic;
        aluout_i:   in  std_logic_vector(nbit-1 downto 0);
        rdata2_i:   in  std_logic_vector(nbit-1 downto 0);
        mem_en_i:   in  std_logic;
        mem_we_i:   in  std_logic;
        wreg_i:     in  std_logic_vector(nbit-1 downto 0);
        rdest_i:    in  std_logic_vector(4 downto 0);
        pc_o:       out std_logic_vector(nbit-1 downto 0);
        npc_o:      out std_logic_vector(nbit-1 downto 0);
        lmd_o:      out std_logic_vector(nbit-1 downto 0);
        wreg_o:     out std_logic_vector(nbit-1 downto 0);
        rdest_o:    out std_logic_vector(4 downto 0)
    );
end entity;

architecture struct of mem_access is
    component data_memory is
        generic(
            ram_width : integer := 32;
            ram_depth : integer := 32;
            ram_add   : integer := 5;
            init_file : string := "data_memory.mem"
        );
        port(
            clk_i   : in std_logic;
            reset_i : in std_logic;
            en_i    : in std_logic;
            we_i    : in std_logic;
            addr_i  : in std_logic_vector(ram_add-1 downto 0);  
            din_i   : in std_logic_vector(ram_width-1 downto 0);
            dout_o  : out std_logic_vector(ram_width-1 downto 0)
        );
    end component;

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

    signal mem_data_out : std_logic_vector(nbit-1 downto 0);

begin
    lmd_o <= mem_data_out;
    wreg_o <= wreg_i;
    rdest_o <= rdest_i;
    data_mem: data_memory
        generic map (
            ram_width => nbit,
            ram_depth => 32,
            ram_add   => 32,
            init_file => "data_memory.mem"
        )
        port map (
            clk_i   => clk_i,
            reset_i => reset_i,
            en_i    => mem_en_i,
            we_i    => mem_we_i,
            addr_i  => aluout_i(4 downto 0),
            din_i   => rdata2_i,
            dout_o  => mem_data_out
        );

    mux: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => npc_i,
            in1_i => aluout_i,
            sel_i => mux_sel_i,
            out_o => pc_o
        );

end architecture;
