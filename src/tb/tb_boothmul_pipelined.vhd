library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_boothmul is
end tb_boothmul;

architecture test of tb_boothmul is
    constant numbit : integer := 4;
    --  input	 
    signal a_mp_i : std_logic_vector(numbit-1 downto 0) := (others => '0');
    signal b_mp_i : std_logic_vector(numbit-1 downto 0) := (others => '0');
    -- output
    signal y_mp_i : std_logic_vector(2*numbit-1 downto 0);
    component boothmul is
        generic (
            nbit: integer := 32 -- refers to the width of the output and not the width of the inputs
        );
        port (
            a  : in  std_logic_vector(nbit-1 downto 0);
            b  : in  std_logic_vector(nbit-1 downto 0);
            res: out std_logic_vector((2*nbit)-1 downto 0)
        );
    end component;
    begin
    -- mul instantiation
    mult_inst: boothmul
        generic map (
        nbit => numbit
        )
        port map (
        a   => a_mp_i,
        b   => b_mp_i,
        res => y_mp_i
        );
    -- process for testing test - complete cycle ---------
    test_proc: process
        variable result: std_logic_vector((2*numbit)-1 downto 0);
        variable i_signed: signed(numbit-1 downto 0);
        variable j_signed: signed(numbit-1 downto 0);
    begin
        -- cycle for operand a
        numrow : for i in 0 to 2**(numbit)-1 loop
        a_mp_i <= std_logic_vector(to_unsigned(i, a_mp_i'length));
            -- cycle for operand b
        numcol : for j in 0 to 2**(numbit)-1 loop
            b_mp_i <= std_logic_vector(to_unsigned(j, b_mp_i'length));
            i_signed := to_signed(i, i_signed'length);
            j_signed := to_signed(j, j_signed'length);
            result := std_logic_vector(to_signed(to_integer(i_signed)*to_integer(j_signed), result'length));
            wait for 10 ns;
            assert result = y_mp_i report "errore" severity error;
        end loop numcol;
        end loop numrow;
        assert result /= y_mp_i report "SIMULATION COMPLETED" severity note;
        wait;          
    end process test_proc;
end test;

-- suggerimento: sposta result a la assert in un process separato e ogni 10 con offset 80 controlli che il
-- risultato che stai sparando fuori sia corretto
