library ieee;
use ieee.std_logic_1164.all;
use work.instructions_pkg.all;

entity alu is 
    generic(
        nbit: integer := 32
    );
    port(
        alu_op_i:   in  std_logic_vector(5 downto 0);
        a_i:        in  std_logic_vector(nbit-1 downto 0);
        b_i:        in  std_logic_vector(nbit-1 downto 0); 
        alu_out_o:  out std_logic_vector(nbit-1 downto 0);  
    );
end entity;

architecture struc of alu is
    -- Components
    component is alu_logic_ops is 
        generic (
            nbit: integer := 32
        );
        port (
            a       : in std_logic_vector(nbit-1 downto 0);
            b       : in std_logic_vector(nbit-1 downto 0);
            alu_op  : in std_logic_vector(5 downto 0);
            c       : out std_logic_vector(nbit-1 downto 0);       
        );
    end component;

    component is t2_shifter is
        generic(
            nbit: integer := 32
        );
        port (
            data_i:        in  std_logic_vector(nbit-1 downto 0);
            amount_i:      in  std_logic_vector(clog2(nbit)-1 downto 0);
            logic_arith_i: in  std_logic;
            left_right_i:  in  std_logic;
            data_o:        out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component p4_adder is
        generic (
            nbit: integer := 32;
            subtractor: integer := 1
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

    -- Signals

    -- process t2 (drriving segnali di ingresso, 4 casi per t2)-> when sra ... logic_arith/left_right... is others


begin
    
    
    
end architecture struc;