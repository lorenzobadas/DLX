library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity carry_select_adder is
    generic (
        n: integer := 4
    );
    port (
        a        : in  std_logic_vector(n-1 downto 0);
        b        : in  std_logic_vector(n-1 downto 0);
        carry_in : in  std_logic;
        sum      : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture structural of carry_select_adder is
    component rca is
        generic (
            n: integer := 4
        );
        port (
            a        : in  std_logic_vector(n-1 downto 0);
            b        : in  std_logic_vector(n-1 downto 0);
            carry_in : in  std_logic;
            sum      : out std_logic_vector(n-1 downto 0);
            carry_out: out std_logic
        );
    end component;
    signal sum0, sum1: std_logic_vector(n-1 downto 0);
begin
	rca_ci_0: rca
        generic map (
            n => n
        )
        port map (
            a        => a,
            b        => b,
            carry_in => '0',
            sum      => sum0
            -- no carry out needed
        );
    rca_ci_1: rca
    generic map (
        n => n
    )
    port map (
        a        => a,
        b        => b,
        carry_in => '1',
        sum      => sum1
        -- no carry out needed
    );

    mux_proc: process (sum0, sum1, carry_in) begin
        if carry_in = '0' then
            sum <= sum0;
        else
            sum <= sum1;
        end if;
    end process mux_proc;
end structural;