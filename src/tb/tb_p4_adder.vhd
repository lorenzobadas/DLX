library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_p4_adder is
end tb_p4_adder;

architecture test of tb_p4_adder is
    
    -- p4 component declaration
    component p4_adder is
        generic (
            nbit :      integer := 32;
            subtractor: integer := 0);
        port (
            a:      in  std_logic_vector(nbit-1 downto 0);
            b:      in  std_logic_vector(nbit-1 downto 0);
            cin:    in  std_logic;
            sub:    in  std_logic;
            s:      out std_logic_vector(nbit-1 downto 0);
            cout :  out std_logic);
    end component;
    constant nbit: integer := 32;
    signal a_s, b_s, s_s: std_logic_vector(nbit-1 downto 0);
    signal cin_s, cout_s: std_logic;
begin
    p4_inst: p4_adder
        generic map (
            nbit => nbit,
            subtractor => 0
        )
        port map (
            a => a_s,
            b => b_s,
            cin => cin_s,
            sub  => '0',
            s => s_s,
            cout => cout_s
        );
    
    cin_s <= '0';
    test: process 
        -- variable aa, bb: unsigned(nbit-1 downto 0) := (others => '0');
    begin
        -- aa := aa + 8;
        -- bb := bb + 2;
        -- a_s <= std_logic_vector(aa);
        -- b_s <= std_logic_vector(bb);
        -- wait for 10 ns;
        a_s <=  "00000000000000000000000011111111", 
                "00000000000000001111111100000000" after 10 ns, 
                "00000000111111110000000000000000" after 20 ns, 
                "11111111000000000000000000000000" after 30 ns,

                "00000000000000001111111111111111" after 40 ns,
                "00000000111111111111111100000000" after 50 ns,
                "11111111111111110000000000000000" after 60 ns,

                "00000000111111111111111111111111" after 70 ns,
                "11111111111111111111111100000000" after 80 ns,

                "11111111111111111111111111111111" after 90 ns;
        
        b_s <=  "00000000000000000000000000000001",
                "00000000000000000000000100000000" after 10 ns,
                "00000000000000010000000000000000" after 20 ns,
                "00000001000000000000000000000000" after 30 ns,

                "00000000000000000000000000000001" after 40 ns,
                "00000000000000000000000100000000" after 50 ns,
                "00000000000000010000000000000000" after 60 ns,
                
                "00000000000000000000000000000001" after 70 ns,
                "00000000000000000000000100000000" after 80 ns,

                "00000000000000000000000000000001" after 90 ns;
        wait;
    end process test;

    assert_proc: process
    begin
        wait for 1 ns;
        assert s_s = "00000000000000000000000100000000" and cout_s = '0' report "errore01" severity error; wait for 10 ns;
        assert s_s = "00000000000000010000000000000000" and cout_s = '0' report "errore02" severity error; wait for 10 ns;
        assert s_s = "00000001000000000000000000000000" and cout_s = '0' report "errore03" severity error; wait for 10 ns;
        assert s_s = "00000000000000000000000000000000" and cout_s = '1' report "errore04" severity error; wait for 10 ns;

        assert s_s = "00000000000000010000000000000000" and cout_s = '0' report "errore11" severity error; wait for 10 ns;
        assert s_s = "00000001000000000000000000000000" and cout_s = '0' report "errore12" severity error; wait for 10 ns;
        assert s_s = "00000000000000000000000000000000" and cout_s = '1' report "errore13" severity error; wait for 10 ns;

        assert s_s = "00000001000000000000000000000000" and cout_s = '0' report "errore21" severity error; wait for 10 ns;
        assert s_s = "00000000000000000000000000000000" and cout_s = '1' report "errore22" severity error; wait for 10 ns;

        assert s_s = "00000000000000000000000000000000" and cout_s = '1' report "errore31" severity error;
        wait;
    end process assert_proc;
end test;

