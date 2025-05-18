library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_boothmul_pipelined is
end entity tb_boothmul_pipelined;

architecture behavior of tb_boothmul_pipelined is

  -----------------------------------------------------------------
  -- Operand width (ricordati del do script se la cambi)
  -----------------------------------------------------------------
  constant WIDTH : integer := 32; -- 

  -----------------------------------------------------------------
  -- Derived parameters
  -----------------------------------------------------------------
  constant N_SLICES         : integer := WIDTH / 2; -- 2 bits per cycle => x partial-product slices
  constant PIPELINE_LATENCY : integer := N_SLICES - 1;   -- one register between each slice
  constant CLK_PERIOD       : time    := 10 ns;

  -----------------------------------------------------------------
  -- Test vectors
  -----------------------------------------------------------------
  type tb_vec is record
    a, b : signed(WIDTH-1 downto 0);
  end record;

  type tb_array is array(natural range <>) of tb_vec;

  constant TB_VECTORS : tb_array := (
    (a => to_signed(  0, WIDTH), b => to_signed(  0, WIDTH)),
    (a => to_signed(  1, WIDTH), b => to_signed(  1, WIDTH)),
    (a => to_signed( -1, WIDTH), b => to_signed( -1, WIDTH)),
    (a => to_signed(  7, WIDTH), b => to_signed(  3, WIDTH)),
    (a => to_signed( -8, WIDTH), b => to_signed(  2, WIDTH)),
    (a => to_signed( 15, WIDTH), b => to_signed(-16, WIDTH)),
    (a => to_signed( 123, WIDTH), b => to_signed(  45, WIDTH)),
    (a => to_signed(-200, WIDTH), b => to_signed(  17, WIDTH)),
    (a => to_signed(1000, WIDTH), b => to_signed(-300, WIDTH)),
    (a => to_signed(-512, WIDTH), b => to_signed(-512, WIDTH))
  );

  constant TB_LEN : integer := TB_VECTORS'length;  -- number of test vectors

  -----------------------------------------------------------------
  -- 4) SIGNALS & EXPECTED-RESULT QUEUE
  -----------------------------------------------------------------
  signal clk     : std_logic := '0';
  signal rst     : std_logic := '0';
  signal A_in    : std_logic_vector(WIDTH-1 downto 0);
  signal B_in    : std_logic_vector(WIDTH-1 downto 0);
  signal res     : std_logic_vector(2*WIDTH-1 downto 0);

  signal idx     : integer range 0 to TB_LEN := 0; -- at which test vector we've arrived
  signal chk_idx : integer range 0 to TB_LEN + PIPELINE_LATENCY := 0; -- total clocks

  -- FIFO of depth PIPELINE_LATENCY+1
  -- after PIPELINE_LATENCY cycles exoq(0) will contain the result of the first product
  type exp_array is array(0 to PIPELINE_LATENCY) of signed(2*WIDTH-1 downto 0);
  signal expq     : exp_array := (others => (others => '0'));

  component boothmul_pipelined
    generic ( nbit : integer );
    port (
      a           : in  std_logic_vector(nbit-1 downto 0);
      b           : in  std_logic_vector(nbit-1 downto 0);
      res         : out std_logic_vector((2*nbit)-1 downto 0);
      en_pipeline : in  std_logic_vector((nbit/2)-2 downto 0);
      clk         : in  std_logic;
      clr         : in  std_logic_vector((nbit/2)-2 downto 0);
      rst         : in  std_logic
    );
  end component;

begin

  uut: boothmul_pipelined
    generic map(nbit => WIDTH)
    port map(
      a           => A_in,
      b           => B_in,
      res         => res,
      en_pipeline => (others => '1'),
      clk         => clk,
      clr         => (others => '0'),
      rst         => rst
    );

  -----------------------------------------------------------------
  -- Clock & reset process
  -----------------------------------------------------------------
  clk_gen: process
  begin
    clk <= '0'; wait for CLK_PERIOD/2;
    clk <= '1'; wait for CLK_PERIOD/2;
  end process;

  rst_pulse: process
  begin
    rst <= '1'; 
    wait for 2*CLK_PERIOD; -- 2 cicli di reset iniziali
    rst <= '0';
    wait;  -- done
  end process;

  -----------------------------------------------------------------
  -- Stimulus + update of the queue
  -----------------------------------------------------------------
  stim_proc: process(clk)
    variable golden : signed(2*WIDTH-1 downto 0);
  begin
    if rising_edge(clk) then

      -- pick next vector (or zero beyond end)
      if idx < TB_LEN then
        A_in   <= std_logic_vector(TB_VECTORS(idx).a);
        B_in   <= std_logic_vector(TB_VECTORS(idx).b);
        golden := TB_VECTORS(idx).a * TB_VECTORS(idx).b;
        idx    <= idx + 1;
      else
        A_in   <= (others => '0');
        B_in   <= (others => '0');
        golden := (others => '0');
      end if;

      -- shifting the queue down
      for i in 0 to PIPELINE_LATENCY-1 loop
        expq(i) <= expq(i+1);
      end loop;
      expq(PIPELINE_LATENCY) <= golden;

    end if;
  end process;

  -----------------------------------------------------------------
  -- Check
  -----------------------------------------------------------------
  check_proc: process
  begin
    wait until rst = '0';
    while true loop
      wait until rising_edge(clk);

      if chk_idx >= PIPELINE_LATENCY and chk_idx < TB_LEN + PIPELINE_LATENCY then
        assert res = std_logic_vector(expq(0))
          report "Mismatch detected at vector " & integer'image(chk_idx-PIPELINE_LATENCY) &
                 ": got-> " & integer'image(to_integer(signed(res))) &
                 " expeted-> " & integer'image(to_integer(expq(0)))
          severity error;

      elsif chk_idx = TB_LEN + PIPELINE_LATENCY then
        report "ALL TEST PASSED (WIDTH=" & integer'image(WIDTH) &
               ", LAT=" & integer'image(PIPELINE_LATENCY) & ")" severity note;
        wait;
      end if;

      chk_idx <= chk_idx + 1;
    end loop;
  end process;

end architecture behavior;
