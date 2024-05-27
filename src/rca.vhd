library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rca is
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
end entity;

architecture behav of rca is
	function std_logic_to_integer(s: std_logic) return integer is
	begin
		if s = '1' then
			return 1;
		else
			return 0;
		end if;
	end function;
	signal sum_vector: std_logic_vector(n downto 0);
begin
	sum_vector <= std_logic_vector(resize(unsigned(a), n+1) + resize(unsigned(b), n+1) + unsigned'('0'&carry_in));
	sum  <= sum_vector(n-1 downto 0);
	carry_out <= sum_vector(n);
	--process (a, b, carry_in)
	--	variable sum_vector: std_logic_vector(n downto 0);
	-- begin
		-- a_int := to_integer(unsigned(a));
		-- b_int := to_integer(unsigned(b));
		-- carry_in_int := std_logic_to_integer(carry_in);
		-- sum_int := a_int + b_int + carry_in_int;
		-- sum_vector := std_logic_vector(to_unsigned(sum_int, sum_vector'length));
		-- carry_out <= sum_vector(n);
		-- sum <= sum_vector(n-1 downto 0);
	-- end process;
end behav;