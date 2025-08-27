library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execution is
    generic (
        nbit: integer := 32
    );
    port (
        clk_i   : in  std_logic;
        reset_i : in  std_logic;
        alu_op_i    : in  alu_op_t;
        mux1_sel_i  : in  std_logic;
        mux2_sel_i  : in  std_logic;
        pc_i       : in  std_logic_vector(nbit-1 downto 0);
        npc_i      : in  std_logic_vector(nbit-1 downto 0);
        rdata1_i   : in  std_logic_vector(nbit-1 downto 0);
        rdata2_i   : in  std_logic_vector(nbit-1 downto 0);
        wbdata_i   : in  std_logic_vector(nbit-1 downto 0);
        imm_i      : in  std_logic_vector(nbit-1 downto 0);
        rdest_i_type_i  : in std_logic_vector(4 downto 0);
        rdest_r_type_i  : in std_logic_vector(4 downto 0);
        ctrl_reg_dest_i : in  std_logic;
        zero_o  : out std_logic;
        rdata2_o    : out std_logic_vector(nbit-1 downto 0);
        pc_o    : out std_logic_vector(nbit-1 downto 0);
        npc_o   : out std_logic_vector(nbit-1 downto 0);
        aluout_o    : out std_logic_vector(nbit-1 downto 0);
        wbdata_o    : out std_logic_vector(nbit-1 downto 0);
        rdest_o    : out std_logic_vector(4 downto 0)
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

    signal mux1_out, mux2_out: std_logic_vector(nbit-1 downto 0);
begin
    pc_o <= pc_i;
    npc_o <= npc_i;
    wbdata_o <= wbdata_i;
    alu_inst: alu
        generic map (
            nbit => nbit
        )
        port map (
            alu_op_i => alu_op_i,
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

    mux_rdata1: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => npc_i,
            in1_i => rdata1_i,
            sel_i => mux1_sel_i,
            out_o => mux1_out
        );

    mux_rdata2: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => rdata2_i,
            in1_i => imm_i,
            sel_i => mux2_sel_i,
            out_o => mux2_out
        );

    mux_rdest: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => rdest_i_type_i,
            in1_i => rdest_r_type_i,
            sel_i => ctrl_reg_dest_i,
            out_o => rdest_o
        );
end architecture;
