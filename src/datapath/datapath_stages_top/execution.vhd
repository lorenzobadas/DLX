library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_instr_pkg.all;

entity execution is
    generic (
        nbit : integer := 32
    );
    port (
        clk_i            : in  std_logic;
        reset_i          : in  std_logic;
        rdata1_i         : in  std_logic_vector(nbit-1 downto 0);
        rdata2_i         : in  std_logic_vector(nbit-1 downto 0);
        imm_i            : in  std_logic_vector(nbit-1 downto 0);
        rdest_i_type_i   : in  std_logic_vector(4 downto 0);
        rdest_r_type_i   : in  std_logic_vector(4 downto 0);
        mem_fwd_rdata1_i : in std_logic_vector(nbit-1 downto 0);
        mem_fwd_rdata2_i : in std_logic_vector(nbit-1 downto 0);
        wb_fwd_rdata1_i  : in std_logic_vector(nbit-1 downto 0);
        wb_fwd_rdata2_i  : in std_logic_vector(nbit-1 downto 0);
        zero_o           : out std_logic;
        aluout_o         : out std_logic_vector(nbit-1 downto 0);
        rdest_o          : out std_logic_vector(4 downto 0);
        -- Control signals
        ALUSrc2_i       : in  std_logic;
        ALUOp_i         : in  alu_op_t;
        regDest_i       : in  std_logic;
        -- Forwarding signals
        forwardA_i      : in  std_logic_vector(1 downto 0);
        forwardB_i      : in  std_logic_vector(1 downto 0)
    );
end entity;

architecture struct of execution is
    component alu is
        generic(
            nbit: integer := 32
        );
        port(
            alu_op_i:  in  alu_op_t;
            a_i:       in  std_logic_vector(nbit-1 downto 0);
            b_i:       in  std_logic_vector(nbit-1 downto 0);
            alu_out_o: out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component zero_detector is
        generic(
            nbit: integer := 32
        );
        port(
            a_i:       in  std_logic_vector(nbit-1 downto 0);
            zero_o:    out std_logic
        );
    end component;

    component mux2to1 is
        generic(
            nbit: integer := 32
        );
        port(
            in0_i:  in  std_logic_vector(nbit-1 downto 0);
            in1_i:  in  std_logic_vector(nbit-1 downto 0);
            sel_i:  in  std_logic;
            out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;
    
    component mux3to1 is
        generic(
            nbit: integer := 32
        );
        port(
            in0_i:  in  std_logic_vector(nbit-1 downto 0);
            in1_i:  in  std_logic_vector(nbit-1 downto 0);
            in2_i:  in  std_logic_vector(nbit-1 downto 0);
            sel_i:  in  std_logic_vector(1 downto 0);
            out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    signal mux1_out : std_logic_vector(nbit-1 downto 0);
    signal mux2_out : std_logic_vector(nbit-1 downto 0);
    signal id_data2 : std_logic_vector(nbit-1 downto 0);
begin
    alu_inst: alu
        generic map (
            nbit => nbit
        )
        port map (
            alu_op_i => ALUOp_i,
            a_i => mux1_out,
            b_i => mux2_out,
            alu_out_o => aluout_o
        );

    zero_inst: zero_detector
        generic map (
            nbit => nbit
        )
        port map (
            a_i => rdata1_i,
            zero_o => zero_o
        );

    mux_rdata1: mux3to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => rdata1_i,
            in1_i => wb_fwd_rdata1_i,
            in2_i => mem_fwd_rdata1_i,
            sel_i => forwardA_i,
            out_o => mux1_out
        );


    mux_rdata2_imm: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => rdata2_i,
            in1_i => imm_i,
            sel_i => ALUSrc2_i,
            out_o => id_data2
        );


    mux_rdata2: mux3to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => id_data2,
            in1_i => wb_fwd_rdata2_i,
            in2_i => mem_fwd_rdata2_i,
            sel_i => forwardB_i,
            out_o => mux2_out
        );

    mux_rdest: mux2to1
        generic map (
            nbit => 5
        )
        port map (
            in0_i => rdest_i_type_i,
            in1_i => rdest_r_type_i,
            sel_i => regDest_i,
            out_o => rdest_o
        );
end architecture;
