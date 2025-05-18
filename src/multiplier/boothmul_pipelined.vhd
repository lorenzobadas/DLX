library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity boothmul_pipelined is
    generic (
        nbit: integer := 32 -- refers to the width of the inputs
    );
    port (
        a  : in  std_logic_vector(nbit-1 downto 0);
        b  : in  std_logic_vector(nbit-1 downto 0);
        res: out std_logic_vector((2*nbit)-1 downto 0);
        en_pipeline : in std_logic_vector((nbit/2)-2 downto 0); -- number of stages-2 => 1 per stage
        clk: in std_logic;
        clr: in std_logic_vector((nbit/2)-2 downto 0); -- TODO: aggiorna l'assgnamento sotto
        rst: in std_logic 
    );
end entity;

architecture structural of boothmul_pipelined is
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
    component shifter_left is
        generic (
            nbit  : integer := 32;
            amount: integer := 2
        );
        port (
            a      : in  std_logic_vector(nbit-1 downto 0);
            a_shift: out std_logic_vector(nbit-1 downto 0)
        );
    end component;
    component mux_mul is
        generic (
            nbit: integer := 32
        );
        port (
            i0 : in  std_logic_vector(nbit-1 downto 0);
            i1 : in  std_logic_vector(nbit-1 downto 0);
            i2 : in  std_logic_vector(nbit-1 downto 0);
            i3 : in  std_logic_vector(nbit-1 downto 0);
            i4 : in  std_logic_vector(nbit-1 downto 0);
            sel: in  std_logic_vector(     2 downto 0);
            o  : out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    -- component per il dff
    component dff is
        generic (
            nbit: integer := 32  -- Width of the data signal
        );
        port (
            clk : in std_logic;             -- Clock signal
            rst : in std_logic;             -- Reset signal (active high)
            clr : in std_logic;
            en  : in std_logic;
            d   : in std_logic_vector(nbit-1 downto 0);  -- Data input
            q   : out std_logic_vector(nbit-1 downto 0)  -- Data output
        );
    end component;


    type array3d_shift is array
        (0 to (nbit/2)-1, -- **slice index**: one entry per Booth slice
        0 to 4) -- **shift variant**: fixe "atoms" {0, +1, -1, +2, -2}
        of std_logic_vector((2*nbit)-1 downto 0); -- **element width**: partial product, double precision

    type array3d_sum is array
        (0 to (nbit/2)-1, --**slice index**
        0 to 1) --**sum stage**: two per slice, pre & post add, 0 post-adder running sum leaving slice i, 1 pre-adder new partial from slice i.
        of std_logic_vector((2*nbit)-1 downto 0); -- **element width**

    type array2d_enc is array
        (0 to (nbit/2)-1) -- **slice index**
        of std_logic_vector(2 downto 0); -- 3 bits, tells the mux_mul which of the five shift variants to select

    type reg_stage_wire_array is array
        (0 to (nbit/2)-1, -- **slice index** 
        0 to 5) -- 6 registers per slice, TODO: in theory we are not using the 6th reg?
        of std_logic_vector((2*nbit)-1 downto 0); -- **element width**

    type nbit_array is array -- stores b along the different stages
        (0 to (nbit/2)-1) -- **slice index**
        of std_logic_vector(nbit-1 downto 0);


    signal shift_array: array3d_shift;
    signal sum_array  : array3d_sum;
    signal enc        : array2d_enc;
    signal a_ext      : std_logic_vector((2*nbit)-1 downto 0);
    signal complement : std_logic_vector((2*nbit)-1 downto 0);
    signal zero       : std_logic_vector((2*nbit)-1 downto 0);
    signal regw_stage : reg_stage_wire_array;
    signal b_array    : nbit_array;
begin

    extend_a: for i in 0 to a_ext'length-1 generate
        copy: if i < a'length generate
            a_ext(i) <= a(i);
        end generate copy;
        sign_extension: if i >= a'length generate
            a_ext(i) <= a(a'length-1);
        end generate sign_extension;
    end generate extend_a;

    zero <= std_logic_vector(to_unsigned(0, zero'length));

    shift_array(0, 0) <= (others => '0');
    shift_array(0, 1) <= a_ext;
    shift_array(0, 2) <= complement;

    shift03_inst: shifter_left
        generic map (
            nbit   => 2*nbit,
            amount => 1
        )
        port map (
            a       => a_ext,
            a_shift => shift_array(0, 3)
        );

    complement_inst: p4_adder
        generic map (
            nbit      => 2*nbit,
            subtractor => 1
        )
        port map (
            a    => zero,
            b    => a_ext,
            cin  => '1',
            sub  => '1',
            s    => complement,
            cout => open
        );
    shift04_inst: shifter_left
        generic map (
            nbit   => 2*nbit,
            amount => 1
        )
        port map (
            a       => complement,
            a_shift => shift_array(0, 4)
        );

    generate_loop: for i in 0 to (nbit/2)-1 generate
        first_case: if i = 0 generate
            enc(0) <= b(1) & b(0) & '0';
            mux0_inst: mux_mul
                generic map (
                    nbit => 2*nbit
                )
                port map (
                    i0  => shift_array(i, 0),
                    i1  => shift_array(i, 1),
                    i2  => shift_array(i, 2),
                    i3  => shift_array(i, 3),
                    i4  => shift_array(i, 4),
                    sel => enc(0),
                    o   => sum_array  (i, 0)
                );

            b_array(0) <= b;
        end generate first_case;

        else_first_case: if i /= 0 generate

            shift_array(i, 0) <= (others => '0');

            shifters_gen: for j in 1 to 4 generate
                dff_shift_inst : dff
                        generic map (
                            nbit => 2*nbit
                        )
                        port map (
                            clk => clk,
                            rst => rst,             
                            clr => clr(i-1),
                            en  => en_pipeline(i-1), -- perche' parti da 1-1 = 0, 2-1 = 1 ..
                            d   => shift_array(i-1, j), -- simply copied from the shift_inst
                            q   => regw_stage(i-1, j-1) -- (0,0), (0,1), (0,2), (0,3)
                        );


                shift_inst: shifter_left
                    generic map (
                        nbit => 2*nbit,
                        amount => 2
                    )
                    port map (
                        -- taking as imput the wire connected to the register
                        a       => regw_stage(i-1, j-1),
                        a_shift => shift_array(  i, j)
                    );
                
            end generate shifters_gen;

            mux_inst: mux_mul
                generic map (
                    nbit => 2*nbit
                )
                port map (
                    i0  => shift_array(i, 0),
                    i1  => shift_array(i, 1),
                    i2  => shift_array(i, 2),
                    i3  => shift_array(i, 3),
                    i4  => shift_array(i, 4),
                    sel => enc(i),
                    o   => sum_array  (i-1, 1)
                );

            -- the adder register
            dff_add_inst : dff
                generic map (
                    nbit => 2*nbit
                )
                port map (
                    clk => clk,
                    rst => rst,
                    clr => clr(i-1),
                    en => en_pipeline(i-1),
                    d => sum_array(i-1, 0),
                    q => regw_stage(i-1,4)
                );


            adder_inst: p4_adder
                generic map (
                    nbit      => 2*nbit,
                    subtractor => 0
                )
                port map (
                    a    => regw_stage(i-1, 4),
                    b    => sum_array(i-1, 1),
                    cin  => '0',
                    sub  => '0',
                    s    => sum_array(i, 0),
                    cout => open
                );

            -- previous version
            -- enc(i) <= b((i*2)+1) & b(i*2) & b((i*2)-1);
            enc(i) <= b_array(i)((i*2)+1) & b_array(i)(i*2) & b_array(i)((i*2)-1);
            
            -- this is the register for the b reg
            dff_breg_inst : dff
                generic map (
                    nbit => nbit
                )
                port map (
                    clk => clk,
                    rst => rst,
                    clr => clr(i-1),
                    en  => en_pipeline(i-1),
                    d   => b_array(i-1), -- the input is the reg in the previous layer
                    q   => b_array(i)
                );

        end generate else_first_case;
    end generate generate_loop;
    
    res <= sum_array((nbit/2)-1, 0);
end structural;