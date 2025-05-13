library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_decode_top is 
    port (

    );
end entity;

architecture struc of fetch_decode_top is
    component mux2to1 is 
        port (
            in0_i:  in  std_logic;  
            in1_i:  in  std_logic;
            sel_i:  in  std_logic;
            out_o:  out std_logic
        );
    end component;

    component pc is 
        generic (
            nbit: integer := 32
        ); 
        port (
            clk_i:  in  std_logic;
            reset_i: in  std_logic;
            in_i:   in  std_logic_vector(nbit-1 downto 0);
            out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component bpu is 
        generic (
            n_entries_bpu: integer := 64
        );
        port (
            clk_i: in  std_logic;
            reset_i: in  std_logic;
            pc_cut_i: in  std_logic_vector(clog2(n_entries_bpu)-1 downto 0);
            prediction_o: out std_logic;
            -- Reorder Buffer Interface
            rob_result_i: in rob_branch_result_t
        );
    end component bpu;

    component imem  --TODO given from professor, modify it to make in combinatory
    end component;
    
    component f_d_pipeline_registers is
        port (
            clk_i:      in  std_logic;
            reset_i:    in  std_logic;
            flush_i:    in  std_logic;
            pc_i:       in  std_logic_vector(31 downto 0);
            instr_i:    in  std_logic_vector(31 downto 0);
            bp_i:       in  std_logic; 
            pc_o:       out std_logic_vector(31 downto 0);
            instr_o:    out std_logic_vector(31 downto 0);
            bp_o:       out std_logic
        );
    end component f_d_pipeline_registers;

    component instruction_parser is
        port (
            instruction_i:  in  std_logic_vector(31 downto 0);
            opcode_o:       out std_logic_vector( 5 downto 0);
            func_o:         out std_logic_vector(10 downto 0);
            rs1_o:          out std_logic_vector( 4 downto 0);
            rs2_o:          out std_logic_vector( 4 downto 0);
            rd_o:           out std_logic_vector( 4 downto 0);
            i_immediate_o:  out std_logic_vector(31 downto 0);
            i_uimmediate_o: out std_logic_vector(31 downto 0);
            j_immediate_o:  out std_logic_vector(31 downto 0);
            reservation_station_i: out reservation_station_t;
            alu_operation_i:       out alu_operation_t;
            commit_type_i:         out commit_type_t
        );
    end component instruction_parser;

    component decoder --TODO switch case with all the opcode of instructions_pkg.vhd
    end component decode;
begin 
    mux: mux2to1 port map (); 
    pc: pc port map ();
    bpu: bpu port map ();
    imem:  
    pipe_regs: f_d_pipeline_registers port map ();
    iparser: instruction_parser port map ();
    decoder: 
    
        
    
end struc;