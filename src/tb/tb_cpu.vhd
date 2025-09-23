library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instructions_pkg.all;
use work.alu_instr_pkg.all;
use work.ctrl_signals_pkg.all;
use work.mem_pkg.all;


entity tb_cpu is
end tb_cpu;

architecture test of tb_cpu is
    -- Constants
    constant nbit      : integer := 32;
    constant ram_width : integer := 32;
    constant ram_add   : integer := 8;
    constant CLK_PERIOD: time := 10 ns;

    -- Clock and reset
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';

    -- Instruction memory signals
    signal imem_en    : std_logic;
    signal imem_addr  : std_logic_vector(imem_addr_size-1 downto 0);
    signal imem_dout  : std_logic_vector(imem_width-1 downto 0);

    -- Data memory signals
    signal dmem_en    : std_logic;
    signal dmem_we    : std_logic;
    signal dmem_addr  : std_logic_vector(dmem_addr_size-1 downto 0);
    signal dmem_din   : std_logic_vector(dmem_width-1 downto 0);
    signal dmem_dout  : std_logic_vector(dmem_width-1 downto 0);

    -- End simulation signal
    signal simulation_done : boolean := false;

    -- Component declaration
    component cpu is
        generic (
            nbit      : integer := 32
        );
        port (
            clk_i       : in  std_logic;
            rst_i       : in  std_logic;
            -- instruction memory
            imem_en_o   : out std_logic;
            imem_addr_o : out std_logic_vector(imem_addr_size-1 downto 0);
            imem_dout_i : in  std_logic_vector(imem_width-1 downto 0);
            -- data memory
            dmem_en_o   : out std_logic;
            dmem_we_o   : out std_logic;
            dmem_addr_o : out std_logic_vector(dmem_addr_size-1 downto 0);
            dmem_din_o  : out std_logic_vector(dmem_width-1 downto 0);
            dmem_dout_i : in  std_logic_vector(dmem_width-1 downto 0)
        );
    end component;

    component instr_memory is
        generic(
            ram_width : integer := imem_width;
            ram_depth : integer := imem_depth;
            ram_add   : integer := imem_addr_size;
            init_file : string := "instr_memory.mem"
        );
        port(
            clk_i  : in std_logic;
            reset_i: in std_logic;
            en_i   : in std_logic;
            addr_i : in std_logic_vector(ram_add-1 downto 0);  
            dout_o : out std_logic_vector(ram_width-1 downto 0)
        );
    end component;

    component data_memory is
        generic(
            ram_width : integer := dmem_width;
            ram_depth : integer := dmem_depth;
            ram_add   : integer := dmem_addr_size;
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

begin
    cpu_inst: cpu
        generic map ( nbit => nbit )
        port map (
            clk_i       => clk,
            rst_i       => rst,
            imem_en_o   => imem_en,
            imem_addr_o => imem_addr,
            imem_dout_i => imem_dout,
            dmem_en_o   => dmem_en,
            dmem_we_o   => dmem_we,
            dmem_addr_o => dmem_addr,
            dmem_din_o  => dmem_din,
            dmem_dout_i => dmem_dout
        );

    imem_inst: instr_memory
        generic map (
            ram_width => imem_width,
            ram_depth => imem_depth,
            ram_add   => imem_addr_size,
            init_file => "instr_memory.mem"
        )
        port map (
            clk_i  => clk,
            reset_i=> rst,
            en_i   => imem_en,
            addr_i => imem_addr,
            dout_o => imem_dout
        );

    dmem_inst: data_memory
        generic map (
            ram_width => dmem_width,
            ram_depth => dmem_depth,
            ram_add   => dmem_addr_size,
            init_file => "data_memory.mem"
        )
        port map (
            clk_i   => clk,
            reset_i => rst,
            en_i    => dmem_en,
            we_i    => dmem_we,
            addr_i  => dmem_addr,
            din_i   => dmem_din,
            dout_o  => dmem_dout
        );

    clk_process: process
    begin
        if (not simulation_done) then
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        else
            wait;
        end if;
    end process;

    test_proc: process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD * 1000;
        simulation_done <= true;
    end process;

end architecture;