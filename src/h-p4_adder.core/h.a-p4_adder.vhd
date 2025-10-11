library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p4_adder is
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
end entity;

architecture struct of p4_adder is
    component xor_layer is
        generic (
            nbit: integer := 32
        );
        port (
            b_i: in  std_logic_vector(nbit-1 downto 0);
            c_i: in  std_logic;
            b_o: out std_logic_vector(nbit-1 downto 0)
        );
    end component;
    component carry_generator is
        generic (
            nbit: integer := 32;
            nbit_per_block: integer := 4
            );
        port (
            a  : in  std_logic_vector(nbit-1 downto 0);
            b  : in  std_logic_vector(nbit-1 downto 0);
            cin: in  std_logic;
            co : out std_logic_vector((nbit/nbit_per_block)-1 downto 0)
        );
    end component;
    component sum_generator is
        generic (
            nbit_per_block: integer := 4;
            nblocks       : integer := 8
        );
        port (
            a : in  std_logic_vector(nbit_per_block*nblocks-1 downto 0);
            b : in  std_logic_vector(nbit_per_block*nblocks-1 downto 0);
            ci: in  std_logic_vector(nblocks-1 downto 0);
            s : out std_logic_vector(nbit_per_block*nblocks-1 downto 0)
        );
    end component;
    constant nbit_per_block: integer := 4;
    signal b_xor: std_logic_vector(nbit-1 downto 0);
    signal co_s : std_logic_vector((nbit/nbit_per_block)-1 downto 0);
    signal cin_vec: std_logic_vector((nbit/nbit_per_block)-1 downto 0);
begin
    cin_vec <= co_s((nbit/nbit_per_block)-2 downto 0) & cin;
    generate_sub: if subtractor = 1 generate
        xor_layer_inst: xor_layer
            generic map (
                nbit => nbit
            )
            port map (
                b_i => b,
                c_i => sub,
                b_o => b_xor
            );
    end generate generate_sub;
    generate_no_sub: if subtractor /= 1 generate
        b_xor <= b;
    end generate generate_no_sub;

    carry_generator_inst: carry_generator
        generic map (
            nbit => nbit
        )
        port map (
            a => a,
            b => b_xor,
            cin => cin,
            co => co_s
        );

    sum_generator_inst: sum_generator
        generic map (
            nbit_per_block => nbit_per_block,
            nblocks => (nbit/nbit_per_block)
        )
        port map (
            a  => a,
            b  => b_xor,
            ci => cin_vec,
            s  => s
        );
    
    cout <= co_s((nbit/nbit_per_block)-1);
end struct;