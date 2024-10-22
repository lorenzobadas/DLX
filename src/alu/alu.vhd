library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity alu is 
    generic(
        nbit: integer := 32
    );
    port(
        alu_op_i:   in  alu_op_t;
        a_i:        in  std_logic_vector(nbit-1 downto 0);
        b_i:        in  std_logic_vector(nbit-1 downto 0); 
        alu_out_o:  out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture struct of alu is
    -- Components
    component alu_logic_ops is 
        generic (
            nbit: integer := 32
        );
        port (
            a_i:        in std_logic_vector(nbit-1 downto 0);
            b_i:        in std_logic_vector(nbit-1 downto 0);
            alu_op_i:   in alu_op_t;
            result_o:   out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component t2_shifter is
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

    component alu_comparator_logic is
        generic (
            nbit : integer := 32
        );
        port (
            a_last_i:       in  std_logic;
            b_last_i:       in  std_logic;
            result_last_i:  in  std_logic;
            cout_i  :       in  std_logic;
            alu_op_i:       in  alu_op_t;
            result_o:       out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    -- Signals
    signal logic_ops_result: std_logic_vector(nbit-1 downto 0);
    signal shifter_data_o: std_logic_vector(nbit-1 downto 0);
    signal shifter_amount: std_logic_vector(clog2(nbit)-1 downto 0);
    signal shifter_logic_arith: std_logic;
    signal shifter_left_right: std_logic;
    signal adder_cin: std_logic;
    signal adder_sub: std_logic;
    signal adder_result: std_logic_vector(nbit-1 downto 0);
    signal adder_cout: std_logic;
    signal comparator_result: std_logic_vector(nbit-1 downto 0);

begin
    logic_ops_inst: alu_logic_ops
    generic map (
        nbit => nbit
    )
    port map (
        a_i         => a_i,
        b_i         => b_i,
        alu_op_i    => alu_op_i,
        result_o    => logic_ops_result
    );
    
    t2_shifter_inst: t2_shifter
    generic map (
        nbit => nbit
    )
    port map (
        data_i        => a_i,
        amount_i      => b_i,
        logic_arith_i => shifter_logic_arith,
        left_right_i  => shifter_left_right,
        data_o        => shifter_data_o
    );

    p4_adder_inst: p4_adder
    generic map (
        nbit => nbit,
        subtractor => 1
    )
    port map (
        a    => a_i,
        b    => b_i,
        cin  => adder_cin,
        sub  => adder_sub,
        s    => adder_result,
        cout => adder_cout
    );

    comparator_logic_inst: alu_comparator_logic
    generic map (
        nbit => nbit
    )
    port map (
        a_last_i      => a_i(nbit-1),
        b_last_i      => b_i(nbit-1),
        result_last_i => adder_result(nbit-1),
        cout_i   => adder_cout,
        alu_op_i => alu_op_i,
        result_o => comparator_result
    );

    shifter_control: process(alu_op_i, b_i)
    begin
        shifter_amount <= b_i;
        
        case alu_op_i is
            when alu_sll =>
                shifter_logic_arith <= '0';  -- Logical shift
                shifter_left_right <= '0';   -- Left shift
            when alu_srl =>
                shifter_logic_arith <= '0';  -- Logical shift
                shifter_left_right <= '1';   -- Right shift
            when alu_sra =>
                shifter_logic_arith <= '1';  -- Arithmetic shift
                shifter_left_right <= '1';   -- Right shift
            when others =>
                shifter_logic_arith <= '0';
                shifter_left_right <= '0';
        end case;
    end process;

    adder_control: process(alu_op_i)
    begin   
        adder_cin <= '0';
        adder_sub <= '0';

        case alu_op_i is
            when alu_add =>
                adder_cin <= '0';
                adder_sub <= '0';
            when alu_sub =>
                adder_cin <= '1';
                adder_sub <= '1';
            when others =>
                adder_cin <= '1';
                adder_sub <= '1';  
        end case;
    end process;

    -- Main ALU output selection process
    alu_output: process(alu_op_i, a_i, b_i, shifter_data_o, logic_ops_result, adder_result, comparator_result)
    begin
        case alu_op_i is
            when alu_and | alu_or | alu_xor =>
                alu_out_o <= logic_ops_result;
            when alu_sll | alu_srl | alu_sra =>
                alu_out_o <= shifter_data_o;
            when alu_add | alu_sub =>
                alu_out_o <= adder_result;
            when alu_slt | alu_sltu | alu_sge | alu_sgeu | alu_sle | alu_sleu | alu_sgt | alu_sgtu | alu_seq | alu_sne =>
                alu_out_o <= comparator_result;
            when others =>
                alu_out_o <= (others => '0'); 
        end case;
    end process;

end architecture struct;
