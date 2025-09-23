library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instructions_pkg.all;
use work.utils_pkg.all;
use work.alu_instr_pkg.all;
use work.mem_pkg.all;

entity cpu is
    generic (
        nbit : integer := 32
    );
    port (
        clk_i   : in std_logic;
        rst_i   : in std_logic;
        -- instruction memory
        imem_en_o    : out std_logic;
        imem_addr_o  : out std_logic_vector(imem_addr_size-1 downto 0);
        imem_dout_i  : in std_logic_vector(imem_width-1 downto 0);
        -- data memory
        dmem_en_o    : out std_logic;
        dmem_we_o    : out std_logic;
        dmem_addr_o  : out std_logic_vector(dmem_addr_size-1 downto 0);
        dmem_din_o   : out std_logic_vector(dmem_width-1 downto 0);
        dmem_dout_i  : in std_logic_vector(dmem_width-1 downto 0)
    );
end entity;

architecture struct of cpu is
    ---------------------------------------------------------------------COMPONENTS
    component control_unit is
        generic(
            nbit : integer := 32
        );
        port (
            instr_i         : in std_logic_vector(nbit-1 downto 0);
            zero_i          : in std_logic;
            immSrc_o        : out std_logic;
            ALUSrc1_o       : out std_logic;
            ALUSrc2_o       : out std_logic;
            ALUOp_o         : out alu_op_t;
            regDest_o       : out std_logic;
            branchEn_o      : out std_logic;
            branchOnZero_o  : out std_logic;
            jumpEn_o        : out std_logic;
            memWrite_o      : out std_logic;
            memToReg_o      : out std_logic;
            regWrite_o      : out std_logic;
            jalEn_o         : out std_logic
        );
    end component;

    component instr_fetch is
        generic (
            nbit : integer := 32
        ); 
        port (
            clk_i   : in  std_logic;
            reset_i : in  std_logic;
            PCSrc_i : in  std_logic;
            aluout_i: in  std_logic_vector(nbit-1 downto 0);
            instr_addr_o : out std_logic_vector(imem_addr_size-1 downto 0);
            npc_o   : out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component if_id_regs is
        generic(
            nbit : integer := 32
        );
        port (
            clk_i    : in  std_logic;
            reset_i  : in  std_logic;
            npc_i    : in  std_logic_vector(nbit-1 downto 0);
            instr_i  : in  std_logic_vector(nbit-1 downto 0);
            npc_o    : out std_logic_vector(nbit-1 downto 0);
            instr_o  : out std_logic_vector(nbit-1 downto 0);
            -- Control signals
            immSrc_i   : in  std_logic;
            ALUSrc1_i  : in  std_logic;
            ALUSrc2_i  : in  std_logic;
            ALUOp_i    : in  alu_op_t;
            regDest_i  : in  std_logic;
            branchEn_i : in  std_logic;
            branchOnZero_i : in std_logic;
            jumpEn_i   : in  std_logic;
            memWrite_i : in  std_logic;
            memToReg_i : in  std_logic;
            regWrite_i : in  std_logic;
            jalEn_i    : in  std_logic;
            immSrc_o   : out std_logic;
            ALUSrc1_o  : out std_logic;
            ALUSrc2_o  : out std_logic;
            ALUOp_o    : out alu_op_t;
            regDest_o  : out std_logic;
            branchEn_o : out std_logic;
            branchOnZero_o : out std_logic;
            jumpEn_o   : out std_logic;
            memWrite_o : out std_logic;
            memToReg_o : out std_logic;
            regWrite_o : out std_logic;
            jalEn_o    : out std_logic
        );
    end component;

    component instr_decode is
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
            rdata1_o        : out std_logic_vector(nbit-1 downto 0);
            rdata2_o        : out std_logic_vector(nbit-1 downto 0);
            imm_o           : out std_logic_vector(nbit-1 downto 0);
            npc_o           : out std_logic_vector(nbit-1 downto 0);
            rdest_i_type_o  : out std_logic_vector(4 downto 0);
            rdest_r_type_o  : out std_logic_vector(4 downto 0);
            -- Control signals
            immSrc_i       : in std_logic;
            regWrite_i     : in std_logic
        );
    end component;

    component id_ex_regs is
        generic(
            nbit : integer := 32
        );
        port (
            clk_i           : in  std_logic;
            reset_i         : in  std_logic;
            npc_i           : in  std_logic_vector(nbit-1 downto 0);
            rdata1_i        : in  std_logic_vector(nbit-1 downto 0);
            rdata2_i        : in  std_logic_vector(nbit-1 downto 0);
            imm_i           : in  std_logic_vector(nbit-1 downto 0);
            rdest_i_type_i  : in  std_logic_vector(4 downto 0);
            rdest_r_type_i  : in  std_logic_vector(4 downto 0);
            npc_o           : out std_logic_vector(nbit-1 downto 0);
            rdata1_o        : out std_logic_vector(nbit-1 downto 0);
            rdata2_o        : out std_logic_vector(nbit-1 downto 0);
            imm_o           : out std_logic_vector(nbit-1 downto 0);
            rdest_i_type_o  : out std_logic_vector(4 downto 0);
            rdest_r_type_o  : out std_logic_vector(4 downto 0);
            -- Control signals
            ALUSrc1_i       : in  std_logic;
            ALUSrc2_i       : in  std_logic;
            ALUOp_i         : in  alu_op_t;
            regDest_i       : in  std_logic;
            branchEn_i      : in  std_logic;
            branchOnZero_i  : in  std_logic;
            jumpEn_i        : in  std_logic;
            memWrite_i      : in  std_logic;
            memToReg_i      : in  std_logic;
            regWrite_i      : in  std_logic;
            jalEn_i         : in  std_logic;
            ALUSrc1_o       : out std_logic;
            ALUSrc2_o       : out std_logic;
            ALUOp_o         : out alu_op_t;
            regDest_o       : out std_logic;
            branchEn_o      : out std_logic;
            branchOnZero_o  : out std_logic;
            jumpEn_o        : out std_logic;
            memWrite_o      : out std_logic;
            memToReg_o      : out std_logic;
            regWrite_o      : out std_logic;
            jalEn_o         : out std_logic
    );
    end component;

    component execution is
        generic (
            nbit : integer := 32
        );
        port (
            clk_i           : in  std_logic;
            reset_i         : in  std_logic;
            npc_i           : in  std_logic_vector(nbit-1 downto 0);
            rdata1_i        : in  std_logic_vector(nbit-1 downto 0);
            rdata2_i        : in  std_logic_vector(nbit-1 downto 0);
            imm_i           : in  std_logic_vector(nbit-1 downto 0);
            rdest_i_type_i  : in  std_logic_vector(4 downto 0);
            rdest_r_type_i  : in  std_logic_vector(4 downto 0);
            zero_o          : out std_logic;
            aluout_o        : out std_logic_vector(nbit-1 downto 0);
            rdest_o         : out std_logic_vector(4 downto 0);
            -- Control signals
            ALUSrc1_i       : in  std_logic;
            ALUSrc2_i       : in  std_logic;
            ALUOp_i         : in  alu_op_t;
            regDest_i       : in  std_logic
        );
    end component;

    component ex_mem_regs is
        generic(
            nbit : integer := 32
        );
        port (
            clk_i   : in  std_logic;
            reset_i : in  std_logic;
            aluout_i: in  std_logic_vector(nbit-1 downto 0);
            rdata2_i: in  std_logic_vector(nbit-1 downto 0);
            rdest_i : in  std_logic_vector(4 downto 0);
            zero_i  : in  std_logic;
            aluout_o: out std_logic_vector(nbit-1 downto 0);
            rdata2_o: out std_logic_vector(nbit-1 downto 0);
            rdest_o : out std_logic_vector(4 downto 0);
            zero_o  : out std_logic;
            -- Control signals
            branchEn_i  : in std_logic;
            branchOnZero_i : in std_logic;
            jumpEn_i    : in std_logic;
            memWrite_i  : in std_logic;
            memToReg_i  : in std_logic;
            regWrite_i  : in std_logic;
            jalEn_i     : in std_logic;
            branchEn_o  : out std_logic;
            branchOnZero_o : out std_logic;
            jumpEn_o    : out std_logic;
            memWrite_o  : out std_logic;
            memToReg_o  : out std_logic;
            regWrite_o  : out std_logic;
            jalEn_o     : out std_logic
        );
    end component;

    component mem_access is
        generic (
            nbit : integer := 32
        );
        port (
            clk_i   : in  std_logic;
            reset_i : in  std_logic;
            aluout_i: in  std_logic_vector(nbit-1 downto 0);
            rdata2_i: in  std_logic_vector(nbit-1 downto 0);
            rdest_i : in  std_logic_vector(4 downto 0);
            zero_i  : in std_logic;
            PCSrc_o : out std_logic;
            dmem_addr_o : out std_logic_vector(dmem_addr_size-1 downto 0);
            dmem_din_o  : out std_logic_vector(dmem_width-1 downto 0);
            rdest_o : out std_logic_vector(4 downto 0);
            -- Control signals
            branchEn_i  : in std_logic;
            branchOnZero_i : in std_logic;
            jumpEn_i    : in std_logic;
            memWrite_i  : in std_logic
        );
    end component;

    component mem_wb_regs is
        generic(
            nbit : integer := 32
        );
        port (
            clk_i       : in  std_logic;
            reset_i     : in  std_logic;
            aluout_i    : in  std_logic_vector(nbit-1 downto 0);
            dout_i       : in  std_logic_vector(nbit-1 downto 0);
            rdest_i     : in  std_logic_vector(4 downto 0);
            aluout_o    : out std_logic_vector(nbit-1 downto 0);
            dout_o       : out std_logic_vector(nbit-1 downto 0);
            rdest_o     : out std_logic_vector(4 downto 0);
            -- Control signals
            memToReg_i  : in std_logic;
            regWrite_i  : in std_logic;
            jalEn_i     : in std_logic;
            memToReg_o  : out std_logic;
            regWrite_o  : out std_logic;
            jalEn_o     : out std_logic
        );
    end component;

    component write_back is
        generic (
            nbit : integer := 32
        );
        port (
            aluout_i    : in  std_logic_vector(nbit-1 downto 0);
            dout_i       : in  std_logic_vector(nbit-1 downto 0);
            rdest_i     : in  std_logic_vector(4 downto 0);
            wbdata_o    : out std_logic_vector(nbit-1 downto 0);
            wbaddr_o    : out std_logic_vector(4 downto 0);
            -- Control signals
            memToReg_i  : in std_logic;
            jalEn_i     : in std_logic
        );
    end component;

    ---------------------------------------------------------------------SIGNALS
    ---------------- Datapath signals ----------------
    -- IF stage signals
    signal if_npc      : std_logic_vector(nbit-1 downto 0);
    signal if_instr    : std_logic_vector(nbit-1 downto 0);
    signal if_instr_addr    : std_logic_vector(imem_addr_size-1 downto 0);
    -- ID stage signals
    signal id_npc_in, id_npc_out    : std_logic_vector(nbit-1 downto 0);
    signal id_instr                 : std_logic_vector(nbit-1 downto 0);
    signal id_rdata1                : std_logic_vector(nbit-1 downto 0);
    signal id_rdata2                : std_logic_vector(nbit-1 downto 0);
    signal id_imm                   : std_logic_vector(nbit-1 downto 0);
    signal id_rdest_i_type, id_rdest_r_type   : std_logic_vector(4 downto 0);
    -- EX stage signals
    signal ex_npc                   : std_logic_vector(nbit-1 downto 0);
    signal ex_rdata1                : std_logic_vector(nbit-1 downto 0);
    signal ex_rdata2                : std_logic_vector(nbit-1 downto 0);
    signal ex_imm                   : std_logic_vector(nbit-1 downto 0);
    signal ex_aluout                : std_logic_vector(nbit-1 downto 0);
    signal ex_zero                  : std_logic;
    signal ex_rdest                 : std_logic_vector(4 downto 0);
    signal ex_rdest_i_type, ex_rdest_r_type   : std_logic_vector(4 downto 0);
    -- MEM stage signals
    signal mem_pc          : std_logic_vector(nbit-1 downto 0) := (others => '0');
    signal mem_zero        : std_logic;
    signal mem_aluout      : std_logic_vector(nbit-1 downto 0);
    signal mem_rdata2      : std_logic_vector(nbit-1 downto 0);
    signal mem_dout         : std_logic_vector(nbit-1 downto 0);
    signal mem_rdest_in, mem_rdest_out : std_logic_vector(4 downto 0);
    signal mem_dmem_addr   : std_logic_vector(dmem_addr_size-1 downto 0);
    signal mem_dmem_din    : std_logic_vector(dmem_width-1 downto 0);
    -- WB stage signals
    signal wb_data          : std_logic_vector(nbit-1 downto 0);
    signal wb_addr          : std_logic_vector(4 downto 0);
    signal wb_aluout        : std_logic_vector(nbit-1 downto 0);
    signal wb_dout           : std_logic_vector(nbit-1 downto 0);
    signal wb_rdest         : std_logic_vector(4 downto 0);

    ---------------- Control signals ----------------
    -- from IF stage
    signal if_immSrc     : std_logic;
    signal if_ALUSrc1    : std_logic;
    signal if_ALUSrc2    : std_logic;
    signal if_ALUOp      : alu_op_t;
    signal if_regDest    : std_logic;
    signal if_branchEn   : std_logic;
    signal if_branchOnZero: std_logic;
    signal if_jumpEn     : std_logic;
    signal if_memWrite   : std_logic;
    signal if_memToReg   : std_logic;
    signal if_regWrite   : std_logic;
    signal if_jalEn      : std_logic;
    -- from IF/ID stage
    signal id_immSrc    : std_logic;
    signal id_ALUSrc1   : std_logic;
    signal id_ALUSrc2   : std_logic;
    signal id_ALUOp     : alu_op_t;
    signal id_regDest   : std_logic;
    signal id_branchEn  : std_logic;
    signal id_branchOnZero: std_logic;
    signal id_jumpEn    : std_logic;
    signal id_memWrite  : std_logic;
    signal id_memToReg  : std_logic;
    signal id_regWrite  : std_logic;
    signal id_jalEn     : std_logic;
    -- from ID/EX stage
    signal ex_ALUSrc1   : std_logic;
    signal ex_ALUSrc2   : std_logic;
    signal ex_ALUOp     : alu_op_t;
    signal ex_regDest   : std_logic;
    signal ex_branchEn  : std_logic;
    signal ex_branchOnZero: std_logic;
    signal ex_jumpEn    : std_logic;
    signal ex_memWrite  : std_logic;
    signal ex_memToReg  : std_logic;
    signal ex_regWrite  : std_logic;
    signal ex_jalEn     : std_logic;
    -- from EX/MEM stage
    signal mem_branchEn  : std_logic;
    signal mem_branchOnZero: std_logic;
    signal mem_jumpEn    : std_logic;
    signal mem_PCSrc     : std_logic;
    signal mem_memWrite  : std_logic;
    signal mem_memToReg  : std_logic;
    signal mem_regWrite  : std_logic;
    signal mem_jalEn     : std_logic;
    -- from MEM/WB stage
    signal wb_memToReg  : std_logic;
    signal wb_regWrite  : std_logic;
    signal wb_jalEn     : std_logic;

begin
    ---------------------------------------------------------------------INSTANCES
    -- Control Unit
    control_unit_inst: control_unit 
        generic map (nbit => nbit)
        port map (
            instr_i    => id_instr,
            zero_i     => ex_zero,
            immSrc_o   => if_immSrc,
            ALUSrc1_o  => if_ALUSrc1,
            ALUSrc2_o  => if_ALUSrc2,
            ALUOp_o    => if_ALUOp,
            regDest_o  => if_regDest,
            branchEn_o => if_branchEn,
            branchOnZero_o => if_branchOnZero,
            jumpEn_o   => if_jumpEn,
            memWrite_o => if_memWrite,
            memToReg_o => if_memToReg,
            regWrite_o => if_regWrite,
            jalEn_o    => if_jalEn
        );

    -- Fetch Stage
    fetch_inst: instr_fetch
        generic map (nbit => nbit)
        port map (
            clk_i   => clk_i,
            reset_i => rst_i,
            PCSrc_i => mem_PCSrc,
            aluout_i => mem_aluout,
            instr_addr_o => if_instr_addr,
            npc_o => if_npc
        );

    -- IF/ID Pipeline Register
    if_id_regs_inst: if_id_regs
        generic map (nbit => nbit)
        port map (
            clk_i     => clk_i,
            reset_i   => rst_i,
            npc_i     => if_npc,
            instr_i   => imem_dout_i,
            npc_o     => id_npc_in,
            instr_o   => id_instr,
            -- Control signals
            immSrc_i   => if_immSrc,
            ALUSrc1_i  => if_ALUSrc1,
            ALUSrc2_i  => if_ALUSrc2,
            ALUOp_i    => if_ALUOp,
            regDest_i  => if_regDest,
            branchEn_i => if_branchEn,
            branchOnZero_i => if_branchOnZero,
            jumpEn_i   => if_jumpEn,
            memWrite_i => if_memWrite,
            memToReg_i => if_memToReg,
            regWrite_i => if_regWrite,
            jalEn_i    => if_jalEn,
            immSrc_o   => id_immSrc,
            ALUSrc1_o  => id_ALUSrc1,
            ALUSrc2_o  => id_ALUSrc2,
            ALUOp_o    => id_ALUOp,
            regDest_o  => id_regDest,
            branchEn_o => id_branchEn,
            branchOnZero_o => id_branchOnZero,
            jumpEn_o   => id_jumpEn,
            memWrite_o => id_memWrite,
            memToReg_o => id_memToReg,
            regWrite_o => id_regWrite,
            jalEn_o    => id_jalEn
        );

    -- Decode Stage
    decode_inst: instr_decode
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            npc_i          => id_npc_in,
            instr_i        => id_instr,
            waddr_i        => wb_addr,
            wbdata_i       => wb_data,
            rdata1_o       => id_rdata1,
            rdata2_o       => id_rdata2,
            imm_o          => id_imm,
            npc_o          => id_npc_out,
            rdest_i_type_o => id_rdest_i_type,
            rdest_r_type_o => id_rdest_r_type,
            -- Control signals
            immSrc_i       => id_immSrc,
            regWrite_i     => wb_regWrite
        );

    -- ID/EX Pipeline Register
    id_ex_regs_inst: id_ex_regs
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            npc_i          => id_npc_out,
            rdata1_i       => id_rdata1,
            rdata2_i       => id_rdata2,
            imm_i          => id_imm,
            rdest_i_type_i => id_rdest_i_type,
            rdest_r_type_i => id_rdest_r_type,
            npc_o          => ex_npc,
            rdata1_o       => ex_rdata1,
            rdata2_o       => ex_rdata2,
            imm_o          => ex_imm,
            rdest_i_type_o => ex_rdest_i_type,
            rdest_r_type_o => ex_rdest_r_type,
            -- Control signals
            ALUSrc1_i      => id_ALUSrc1,
            ALUSrc2_i      => id_ALUSrc2,
            ALUOp_i        => id_ALUOp,
            regDest_i      => id_regDest,
            branchEn_i     => id_branchEn,
            branchOnZero_i  => id_branchOnZero,
            jumpEn_i       => id_jumpEn,
            memWrite_i     => id_memWrite,
            memToReg_i     => id_memToReg,
            regWrite_i     => id_regWrite,
            jalEn_i        => id_jalEn,
            ALUSrc1_o      => ex_ALUSrc1,
            ALUSrc2_o      => ex_ALUSrc2,
            ALUOp_o        => ex_ALUOp,
            regDest_o      => ex_regDest,
            branchEn_o    => ex_branchEn,
            branchOnZero_o => ex_branchOnZero,
            jumpEn_o      => ex_jumpEn,
            memWrite_o     => ex_memWrite,
            memToReg_o     => ex_memToReg,
            regWrite_o     => ex_regWrite,
            jalEn_o        => ex_jalEn
        );

    -- Execute Stage
    execute_inst: execution
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            npc_i          => ex_npc,
            rdata1_i       => ex_rdata1,
            rdata2_i       => ex_rdata2,
            imm_i          => ex_imm,
            rdest_i_type_i => ex_rdest_i_type,
            rdest_r_type_i => ex_rdest_r_type,
            zero_o         => ex_zero,
            aluout_o       => ex_aluout,
            rdest_o        => ex_rdest,
            -- Control signals
            ALUSrc1_i      => ex_ALUSrc1,
            ALUSrc2_i      => ex_ALUSrc2,
            ALUOp_i        => ex_ALUOp,
            regDest_i      => ex_regDest
        );

    -- EX/MEM Pipeline Register
    ex_mem_regs_inst: ex_mem_regs
        generic map (nbit => nbit)
        port map (
            clk_i         => clk_i,
            reset_i       => rst_i,
            aluout_i      => ex_aluout,
            rdata2_i      => ex_rdata2,
            rdest_i       => ex_rdest,
            zero_i        => ex_zero,
            aluout_o      => mem_aluout,
            rdata2_o      => mem_rdata2,
            rdest_o       => mem_rdest_in,
            zero_o        => mem_zero,
            -- Control signals
            branchEn_i    => ex_branchEn,
            branchOnZero_i => ex_branchOnZero,
            jumpEn_i      => ex_jumpEn,
            memWrite_i    => ex_memWrite,
            memToReg_i    => ex_memToReg,
            regWrite_i    => ex_regWrite,
            jalEn_i       => ex_jalEn,
            branchEn_o    => mem_branchEn,
            branchOnZero_o => mem_branchOnZero,
            jumpEn_o      => mem_jumpEn,
            memWrite_o    => mem_memWrite,
            memToReg_o    => mem_memToReg,
            regWrite_o    => mem_regWrite,
            jalEn_o       => mem_jalEn
        );

    -- Memory Stage
    mem_access_inst: mem_access
        generic map (nbit => nbit)
        port map (
            clk_i       => clk_i,
            reset_i     => rst_i,
            aluout_i    => mem_aluout,
            rdata2_i    => mem_rdata2,
            rdest_i     => mem_rdest_in,
            zero_i      => mem_zero,
            PCSrc_o     => mem_PCSrc,
            dmem_addr_o => mem_dmem_addr,
            dmem_din_o  => mem_dmem_din,
            rdest_o     => mem_rdest_out,
            -- Control signals
            branchEn_i   => mem_branchEn,
            branchOnZero_i => mem_branchOnZero,
            jumpEn_i     => mem_jumpEn,
            memWrite_i   => mem_memWrite
        );

    -- MEM/WB Pipeline Register
    mem_wb_regs_inst: mem_wb_regs
        generic map (nbit => nbit)
        port map (
            clk_i         => clk_i,
            reset_i       => rst_i,
            aluout_i      => mem_aluout,
            dout_i        => mem_dout,
            rdest_i       => mem_rdest_out,
            aluout_o      => wb_aluout,
            dout_o        => wb_dout,
            rdest_o       => wb_rdest,
            -- Control signals
            memToReg_i    => mem_memToReg,
            regWrite_i    => mem_regWrite,
            jalEn_i       => mem_jalEn,
            memToReg_o    => wb_memToReg,
            regWrite_o    => wb_regWrite,
            jalEn_o       => wb_jalEn
        );

    -- Write Back Stage
    write_back_inst: write_back
        generic map (nbit => nbit)
        port map (
            aluout_i      => wb_aluout,
            dout_i         => wb_dout,
            rdest_i       => wb_rdest,
            wbdata_o      => wb_data,
            wbaddr_o      => wb_addr,
            -- Control signals
            memToReg_i    => wb_memToReg,
            jalEn_i       => wb_jalEn
        );

    -- Instruction Memory
    imem_en_o <= '1';
    imem_addr_o <= if_instr_addr;
    if_instr <= imem_dout_i;
    -- Data Memory
    dmem_en_o <= '1';
    dmem_we_o <= mem_memWrite;
    dmem_addr_o <= mem_dmem_addr;
    dmem_din_o <= mem_rdata2;
    mem_dout <= dmem_dout_i;
    
end architecture;
