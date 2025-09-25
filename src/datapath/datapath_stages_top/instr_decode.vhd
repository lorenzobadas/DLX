library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity instr_decode is
    generic (
        nbit : integer := 32
    ); 
    port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        npc_i           : in  std_logic_vector(nbit-1 downto 0);
        instr_i         : in  std_logic_vector(nbit-1 downto 0);
        waddr_i         : in  std_logic_vector(4 downto 0);
        wbdata_i        : in  std_logic_vector(nbit-1 downto 0);
        mem_fwd_rdata1_i : in  std_logic_vector(nbit-1 downto 0);
        rdata1_o        : out std_logic_vector(nbit-1 downto 0);
        rdata2_o        : out std_logic_vector(nbit-1 downto 0);
        imm_o           : out std_logic_vector(nbit-1 downto 0);
        rdest_i_type_o  : out std_logic_vector(4 downto 0);
        rdest_r_type_o  : out std_logic_vector(4 downto 0);
        rsrc1_o         : out std_logic_vector(4 downto 0);
        rsrc2_o         : out std_logic_vector(4 downto 0);
        branch_pc_o     : out std_logic_vector(nbit-1 downto 0);
        PCSrc_o         : out std_logic;
        -- Control signals
        immSrc_i       : in std_logic;
        regWrite_i     : in std_logic;
        branchEn_i     : in std_logic;
        branchOnZero_i : in std_logic;
        jumpEn_i       : in std_logic;
        jalEn_i        : in std_logic;
        forwardC_i     : in std_logic
    );
end entity;

architecture struct of instr_decode is
    component register_file is
        generic (
            nreg : integer := 32;
            nbit : integer := 32
        );
        port (
            clk_i   : in  std_logic;
            we_i    : in  std_logic;
            waddr_i : in  std_logic_vector(clog2(nreg)-1 downto 0);
            wbdata_i: in  std_logic_vector(nbit-1 downto 0);
            raddr1_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
            raddr2_i: in  std_logic_vector(clog2(nreg)-1 downto 0);
            rdata1_o: out std_logic_vector(nbit-1 downto 0);
            rdata2_o: out std_logic_vector(nbit-1 downto 0)
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

    component zero_detector is
        generic (
            nbit : integer := 32
        );
        port (
            a_i    : in  std_logic_vector(nbit-1 downto 0);
            zero_o : out std_logic
        );
    end component;

    component p4_adder is
        generic (
            nbit: integer := 32;
            subtractor: integer := 0
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

    signal imm_i_type, imm_j_type: std_logic_vector(nbit-1 downto 0);
    signal imm: std_logic_vector(nbit-1 downto 0);
    signal rdest_i_type: std_logic_vector(4 downto 0);
    signal raddr1, raddr2: std_logic_vector(4 downto 0);
    signal rs1_zero: std_logic;
    signal rdata1: std_logic_vector(nbit-1 downto 0);
    signal rdata2: std_logic_vector(nbit-1 downto 0);
    signal bypass1 : std_logic;
    signal bypass2 : std_logic;
    signal rdata1_bypassed : std_logic_vector(nbit-1 downto 0);
    signal rdata1_final    : std_logic_vector(nbit-1 downto 0);
    signal rdata2_bypassed : std_logic_vector(nbit-1 downto 0);
begin
    imm_i_type <= (31 downto 16 => instr_i(15)) & instr_i(15 downto 0);
    imm_j_type <= (31 downto 26 => instr_i(25)) & instr_i(25 downto 0);
    rdest_i_type <= instr_i(20 downto 16);
    rdest_r_type_o <= instr_i(15 downto 11);
    raddr1 <= instr_i(25 downto 21);
    raddr2 <= instr_i(20 downto 16);
    rsrc1_o <= raddr1;
    rsrc2_o <= raddr2;
    
    reg_file: register_file
        generic map (
            nreg => 32,
            nbit => nbit
        )
        port map (
            clk_i => clk_i,
            we_i => regWrite_i,
            waddr_i => waddr_i,
            wbdata_i => wbdata_i,
            raddr1_i => raddr1,
            raddr2_i => raddr2,
            rdata1_o => rdata1,
            rdata2_o => rdata2
        );

    branch_adder: p4_adder
        generic map (
            nbit => nbit,
            subtractor => 1
        )
        port map (
            a   => npc_i,
            b   => imm,
            cin => '0',
            sub => '0',
            s   => branch_pc_o,
            cout => open
        );

    PCSrc_o <= (branchEn_i and (rs1_zero xor (not branchOnZero_i))) or jumpEn_i;

    imm_mux: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => imm_i_type,
            in1_i => imm_j_type,
            sel_i => immSrc_i,
            out_o => imm
        );

    imm_o <= imm;

    mux_jalEn: mux2to1
        generic map (
            nbit => 5
        )
        port map (
            in0_i => rdest_i_type,
            in1_i => std_logic_vector(to_unsigned(31, 5)),
            sel_i => jalEn_i,
            out_o => rdest_i_type_o
        );

    bypass_proc: process(raddr1, raddr2, waddr_i, regWrite_i)
    begin
        bypass1 <= '0';
        bypass2 <= '0';
        if (regWrite_i = '1' and waddr_i /= "00000") then
            if (raddr1 = waddr_i) then
                bypass1 <= '1';
            end if;

            if (raddr2 = waddr_i) then
                bypass2 <= '1';
            end if;
        end if;
    end process;

    mux_bypass1: mux2to1
     generic map(
        nbit => nbit
    )
     port map(
        in0_i => rdata1,
        in1_i => wbdata_i,
        sel_i => bypass1,
        out_o => rdata1_bypassed
    );

    mux_bypass2: mux2to1
     generic map(
        nbit => nbit
    )
     port map(
        in0_i => rdata2,
        in1_i => wbdata_i,
        sel_i => bypass2,
        out_o => rdata2_bypassed
    );

    mux_branch_fwd: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => rdata1_bypassed,
            in1_i => mem_fwd_rdata1_i,
            sel_i => forwardC_i,
            out_o => rdata1_final
        );

    zero_detector_inst: zero_detector
        generic map (
            nbit => nbit
        )
        port map (
            a_i    => rdata1_final,
            zero_o => rs1_zero
        );

    rdata1_o <= rdata1_bypassed;
    rdata2_o <= rdata2_bypassed;

end architecture;
