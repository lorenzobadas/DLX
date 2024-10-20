library ieee; 
use ieee.std_logic_1164.all;

entity sum_generator is
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
end entity;

architecture structural of sum_generator is -- with Carry Select Adder
    component carry_select_adder is
        generic (
            n: integer := 4
        );
        port (
            a        : in  std_logic_vector(n-1 downto 0);
            b        : in  std_logic_vector(n-1 downto 0);
            carry_in : in  std_logic;
            sum      : out std_logic_vector(n-1 downto 0)
        );
    end component;
begin
    generate_ext: for i in 0 to nblocks-1 generate
    begin
        csa_inst: carry_select_adder
            generic map (
                n => nbit_per_block
            )
            port map (
                a        => a((i*nbit_per_block)+3 downto (i*nbit_per_block)),
                b        => b((i*nbit_per_block)+3 downto (i*nbit_per_block)),
                carry_in => ci(i),
                sum      => s((i*nbit_per_block)+3 downto (i*nbit_per_block))
            );
    end generate generate_ext;
end structural;