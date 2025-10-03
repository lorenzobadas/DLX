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
        dmem_data_format_o : out std_logic_vector(1 downto 0);
        dmem_data_sign_o   : out std_logic;
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
            immSrc_o        : out std_logic;
            immUnsigned_o   : out std_logic;
            regDest_o       : out std_logic;
            jumpEn_o        : out std_logic;
            jrEn_o          : out std_logic;
            branchEn_o      : out std_logic;
            branchOnZero_o  : out std_logic;
            ALUSrc2_o       : out std_logic;
            ALUOp_o         : out alu_op_t;
            jalEn_o         : out std_logic;
            memWrite_o      : out std_logic;
            memDataFormat_o : out std_logic_vector(1 downto 0);
            memDataSign_o   : out std_logic;
            memToReg_o      : out std_logic;
            regWrite_o      : out std_logic
        );
    end component;

    component instr_fetch is
        generic (
            nbit : integer := 32
        ); 
        port (
            clk_i   : in  std_logic;
            reset_i : in  std_logic;
            pc_enable_i : in  std_logic;
            PCSrc_i : in  std_logic;
            branch_pc_i : in  std_logic_vector(nbit-1 downto 0);
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
            enable_i : in  std_logic;
            flush_i  : in  std_logic;
            npc_i    : in  std_logic_vector(nbit-1 downto 0);
            instr_i  : in  std_logic_vector(nbit-1 downto 0);
            npc_o    : out std_logic_vector(nbit-1 downto 0);
            instr_o  : out std_logic_vector(nbit-1 downto 0)
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
            mem_fwd_rdata_i : in std_logic_vector(nbit-1 downto 0);
            rdata1_o        : out std_logic_vector(nbit-1 downto 0);
            rdata2_o        : out std_logic_vector(nbit-1 downto 0);
            imm_o           : out std_logic_vector(nbit-1 downto 0);
            rdest_o         : out std_logic_vector(4 downto 0);
            rsrc1_o         : out std_logic_vector(4 downto 0);
            rsrc2_o         : out std_logic_vector(4 downto 0);
            branch_pc_o     : out std_logic_vector(nbit-1 downto 0);
            PCSrc_o         : out std_logic;
            -- Control signals
            immSrc_i       : in std_logic;
            immUnsigned_i  : in std_logic;
            regDest_i      : in std_logic;
            regWrite_i     : in std_logic;
            branchEn_i     : in std_logic;
            branchOnZero_i : in std_logic;
            jumpEn_i       : in std_logic;
            jalEn_i        : in std_logic;
            jrEn_i         : in std_logic;
            forwardC_i     : in std_logic
        );
    end component;

    component hazard_unit is
        port (
            -- Inputs
            ex_memToReg_i : in  std_logic; -- Instruction is a load
            ex_regWrite_i : in  std_logic; -- Instruction writes to a register
            ex_rdest_i    : in  std_logic_vector(4 downto 0);
            id_rs1_i      : in  std_logic_vector(4 downto 0);
            id_rs2_i      : in  std_logic_vector(4 downto 0);
            id_regDest_i  : in  std_logic; -- Instruction is R-type (uses rs2 as source)
            id_PCSrc_i    : in  std_logic; -- Branch taken
            id_branchEn_i : in  std_logic; -- Instruction is a branch
            id_jumpEn_i   : in  std_logic; -- Instruction is a jump
            id_jrEn_i     : in  std_logic; -- Instruction is a jump register
            -- Outputs
            pc_write_o    : out std_logic;
            if_id_write_o : out std_logic;
            if_id_flush_o : out std_logic;
            id_ex_nop_o   : out std_logic
        );
    end component;

    component id_ex_regs is
        generic(
            nbit : integer := 32
        );
        port (
            clk_i           : in  std_logic;
            reset_i         : in  std_logic;
            insert_nop_i    : in  std_logic;
            npc_i           : in  std_logic_vector(nbit-1 downto 0);
            rdata1_i        : in  std_logic_vector(nbit-1 downto 0);
            rdata2_i        : in  std_logic_vector(nbit-1 downto 0);
            imm_i           : in  std_logic_vector(nbit-1 downto 0);
            rdest_i         : in  std_logic_vector(4 downto 0);
            rsrc1_i         : in  std_logic_vector(4 downto 0);
            rsrc2_i         : in  std_logic_vector(4 downto 0);
            npc_o           : out std_logic_vector(nbit-1 downto 0);
            rdata1_o        : out std_logic_vector(nbit-1 downto 0);
            rdata2_o        : out std_logic_vector(nbit-1 downto 0);
            imm_o           : out std_logic_vector(nbit-1 downto 0);
            rdest_o         : out std_logic_vector(4 downto 0);
            rsrc1_o         : out std_logic_vector(4 downto 0);
            rsrc2_o         : out std_logic_vector(4 downto 0);
            -- Control signals
            ALUSrc2_i       : in  std_logic;
            ALUOp_i         : in  alu_op_t;
            memWrite_i      : in  std_logic;
            memDataFormat_i : in  std_logic_vector(1 downto 0);
            memDataSign_i   : in  std_logic;
            memToReg_i      : in  std_logic;
            regWrite_i      : in  std_logic;
            jalEn_i         : in  std_logic;
            ALUSrc2_o       : out std_logic;
            ALUOp_o         : out alu_op_t;
            memWrite_o      : out std_logic;
            memDataFormat_o : out  std_logic_vector(1 downto 0);
            memDataSign_o   : out std_logic;
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
            clk_i            : in  std_logic;
            reset_i          : in  std_logic;
            npc_i            : in  std_logic_vector(nbit-1 downto 0);
            rdata1_i         : in  std_logic_vector(nbit-1 downto 0);
            rdata2_i         : in  std_logic_vector(nbit-1 downto 0);
            imm_i            : in  std_logic_vector(nbit-1 downto 0);
            mem_fwd_rdata_i  : in  std_logic_vector(nbit-1 downto 0);
            wb_fwd_rdata_i   : in  std_logic_vector(nbit-1 downto 0);
            rdata2_o         : out std_logic_vector(nbit-1 downto 0);
            aluout_o         : out std_logic_vector(nbit-1 downto 0);
            -- Control signals
            ALUSrc2_i        : in  std_logic;
            ALUOp_i          : in  alu_op_t;
            jalEn_i          : in  std_logic;
            -- Forwarding signals
            forwardA_i       : in  std_logic_vector(1 downto 0);
            forwardB_i       : in  std_logic_vector(1 downto 0)
        );
    end component;

    component forwarding_unit is
        port (
            ex_mem_regwrite_i : in  std_logic;
            mem_wb_regwrite_i : in  std_logic;
            if_id_branchEn_i  : in  std_logic;
            if_id_jumpEn_i    : in  std_logic;
            if_id_jrEn_i      : in  std_logic;
            ex_mem_rd_i       : in  std_logic_vector(4 downto 0);
            mem_wb_rd_i       : in  std_logic_vector(4 downto 0);
            id_ex_rs1_i       : in  std_logic_vector(4 downto 0);
            id_ex_rs2_i       : in  std_logic_vector(4 downto 0);
            if_id_rs1_i       : in  std_logic_vector(4 downto 0);

            forwardA_o        : out std_logic_vector(1 downto 0);
            forwardB_o        : out std_logic_vector(1 downto 0);
            forwardC_o        : out std_logic
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
            aluout_o: out std_logic_vector(nbit-1 downto 0);
            rdata2_o: out std_logic_vector(nbit-1 downto 0);
            rdest_o : out std_logic_vector(4 downto 0);
            -- Control signals
            memWrite_i  : in std_logic;
            memDataFormat_i : in std_logic_vector(1 downto 0);
            memDataSign_i : in std_logic;
            memToReg_i  : in std_logic;
            regWrite_i  : in std_logic;
            memWrite_o  : out std_logic;
            memDataFormat_o : out std_logic_vector(1 downto 0);
            memDataSign_o : out std_logic;
            memToReg_o  : out std_logic;
            regWrite_o  : out std_logic
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
            dmem_addr_o : out std_logic_vector(dmem_addr_size-1 downto 0);
            dmem_din_o  : out std_logic_vector(dmem_width-1 downto 0);
            -- Control signals
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
            memToReg_o  : out std_logic;
            regWrite_o  : out std_logic
        );
    end component;

    component write_back is
        generic (
            nbit : integer := 32
        );
        port (
            aluout_i    : in  std_logic_vector(nbit-1 downto 0);
            dout_i       : in  std_logic_vector(nbit-1 downto 0);
            wbdata_o    : out std_logic_vector(nbit-1 downto 0);
            -- Control signals
            memToReg_i  : in std_logic
        );
    end component;

    ---------------------------------------------------------------------SIGNALS
    ---------------- Datapath signals ----------------
    -- IF stage signals
    signal if_npc        : std_logic_vector(nbit-1 downto 0);
    signal if_instr      : std_logic_vector(nbit-1 downto 0);
    signal if_instr_addr : std_logic_vector(imem_addr_size-1 downto 0);
    signal id_branch_pc  : std_logic_vector(nbit-1 downto 0);
    signal id_PCSrc      : std_logic;
    -- ID stage signals
    signal id_npc    : std_logic_vector(nbit-1 downto 0);
    signal id_instr  : std_logic_vector(nbit-1 downto 0);
    signal id_rdata1 : std_logic_vector(nbit-1 downto 0);
    signal id_rdata2 : std_logic_vector(nbit-1 downto 0);
    signal id_imm    : std_logic_vector(nbit-1 downto 0);
    signal id_rdest  : std_logic_vector(4 downto 0);
    signal id_rsrc1  : std_logic_vector(4 downto 0);
    signal id_rsrc2  : std_logic_vector(4 downto 0);
    signal id_zero   : std_logic;
    -- EX stage signals
    signal ex_npc          : std_logic_vector(nbit-1 downto 0);
    signal ex_rdata1       : std_logic_vector(nbit-1 downto 0);
    signal ex_rdata2       : std_logic_vector(nbit-1 downto 0);
    signal ex_rdata2_final : std_logic_vector(nbit-1 downto 0);
    signal ex_imm          : std_logic_vector(nbit-1 downto 0);
    signal ex_aluout       : std_logic_vector(nbit-1 downto 0);
    signal ex_rdest        : std_logic_vector(4 downto 0);
    signal ex_rsrc1        : std_logic_vector(4 downto 0);
    signal ex_rsrc2        : std_logic_vector(4 downto 0);
    signal forwardA        : std_logic_vector(1 downto 0);
    signal forwardB        : std_logic_vector(1 downto 0);
    signal forwardC        : std_logic;
    -- MEM stage signals
    signal mem_pc        : std_logic_vector(nbit-1 downto 0);
    signal mem_aluout    : std_logic_vector(nbit-1 downto 0);
    signal mem_rdata2    : std_logic_vector(nbit-1 downto 0);
    signal mem_dout      : std_logic_vector(nbit-1 downto 0);
    signal mem_rdest     : std_logic_vector(4 downto 0);
    signal mem_dmem_addr : std_logic_vector(dmem_addr_size-1 downto 0);
    signal mem_dmem_din  : std_logic_vector(dmem_width-1 downto 0);
    -- WB stage signals
    signal wb_data   : std_logic_vector(nbit-1 downto 0);
    signal wb_aluout : std_logic_vector(nbit-1 downto 0);
    signal wb_dout   : std_logic_vector(nbit-1 downto 0);
    signal wb_rdest  : std_logic_vector(4 downto 0);

    ---------------- Control signals ----------------
    -- from ID stage (Control Unit)
    signal id_immSrc        : std_logic;
    signal id_immUnsigned   : std_logic;
    signal id_regDest       : std_logic;
    signal id_jumpEn        : std_logic;
    signal id_jrEn          : std_logic;
    signal id_branchEn      : std_logic;
    signal id_branchOnZero  : std_logic;
    signal id_ALUSrc2       : std_logic;
    signal id_ALUOp         : alu_op_t;
    signal id_jalEn         : std_logic;
    signal id_memWrite      : std_logic;
    signal id_memDataFormat : std_logic_vector(1 downto 0);
    signal id_memDataSign   : std_logic;
    signal id_memToReg      : std_logic;
    signal id_regWrite      : std_logic;
    -- from ID/EX stage
    signal ex_ALUSrc2       : std_logic;
    signal ex_ALUOp         : alu_op_t;
    signal ex_jalEn         : std_logic;
    signal ex_memWrite      : std_logic;
    signal ex_memDataFormat : std_logic_vector(1 downto 0);
    signal ex_memDataSign   : std_logic;
    signal ex_memToReg      : std_logic;
    signal ex_regWrite      : std_logic;
    -- from EX/MEM stage
    signal mem_memWrite      : std_logic;
    signal mem_memDataFormat : std_logic_vector(1 downto 0);
    signal mem_memDataSign   : std_logic;
    signal mem_memToReg      : std_logic;
    signal mem_regWrite      : std_logic;
    -- from MEM/WB stage
    signal wb_memToReg : std_logic;
    signal wb_regWrite : std_logic;

    ---------------- Hazard signals ----------------
    signal pc_enable   : std_logic;
    signal if_id_write : std_logic;
    signal if_id_flush : std_logic;
    signal id_ex_nop   : std_logic;

begin
    ---------------------------------------------------------------------INSTANCES
    -- Fetch Stage
    fetch_inst: instr_fetch
        generic map (nbit => nbit)
        port map (
            clk_i        => clk_i,
            reset_i      => rst_i,
            pc_enable_i  => pc_enable,
            PCSrc_i      => id_PCSrc,
            branch_pc_i  => id_branch_pc,
            instr_addr_o => if_instr_addr,
            npc_o        => if_npc
        );

    -- IF/ID Pipeline Register
    if_id_regs_inst: if_id_regs
        generic map (nbit => nbit)
        port map (
            clk_i     => clk_i,
            reset_i   => rst_i,
            enable_i  => if_id_write,
            flush_i   => if_id_flush,
            npc_i     => if_npc,
            instr_i   => imem_dout_i,
            npc_o     => id_npc,
            instr_o   => id_instr
        );

    -- Control Unit
    control_unit_inst: control_unit 
        generic map (nbit => nbit)
        port map (
            instr_i         => id_instr,
            immSrc_o        => id_immSrc,
            immUnsigned_o   => id_immUnsigned,
            regDest_o       => id_regDest,
            jumpEn_o        => id_jumpEn,
            jrEn_o          => id_jrEn,
            branchEn_o      => id_branchEn,
            branchOnZero_o  => id_branchOnZero,
            ALUSrc2_o       => id_ALUSrc2,
            ALUOp_o         => id_ALUOp,
            jalEn_o         => id_jalEn,
            memWrite_o      => id_memWrite,
            memDataFormat_o => id_memDataFormat,
            memDataSign_o   => id_memDataSign,
            memToReg_o      => id_memToReg,
            regWrite_o      => id_regWrite
        );

    -- Decode Stage
    decode_inst: instr_decode
        generic map (nbit => nbit)
        port map (
            clk_i           => clk_i,
            reset_i         => rst_i,
            npc_i           => id_npc,
            instr_i         => id_instr,
            waddr_i         => wb_rdest,
            wbdata_i        => wb_data,
            mem_fwd_rdata_i => mem_aluout,
            rdata1_o        => id_rdata1,
            rdata2_o        => id_rdata2,
            imm_o           => id_imm,
            rdest_o         => id_rdest,
            rsrc1_o         => id_rsrc1,
            rsrc2_o         => id_rsrc2,
            branch_pc_o     => id_branch_pc,
            PCSrc_o         => id_PCSrc,
            -- Control signals
            immSrc_i       => id_immSrc,
            immUnsigned_i  => id_immUnsigned,
            regDest_i      => id_regDest,
            regWrite_i     => wb_regWrite,
            branchEn_i     => id_branchEn,
            branchOnZero_i => id_branchOnZero,
            jumpEn_i       => id_jumpEn,
            jalEn_i        => id_jalEn,
            jrEn_i         => id_jrEn,
            forwardC_i     => forwardC
        );

    -- Hazard Unit
    hazard_unit_inst: hazard_unit
        port map (
            ex_memToReg_i => ex_memToReg,
            ex_regWrite_i => ex_regWrite,
            ex_rdest_i    => ex_rdest,
            id_rs1_i      => id_rsrc1,
            id_rs2_i      => id_rsrc2,
            id_regDest_i  => id_regDest,
            id_PCSrc_i    => id_PCSrc,
            id_branchEn_i => id_branchEn,
            id_jumpEn_i   => id_jumpEn,
            id_jrEn_i     => id_jrEn,
            pc_write_o    => pc_enable,
            if_id_write_o => if_id_write,
            if_id_flush_o => if_id_flush,
            id_ex_nop_o   => id_ex_nop
        );

    -- ID/EX Pipeline Register
    id_ex_regs_inst: id_ex_regs
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            insert_nop_i   => id_ex_nop,
            npc_i          => id_npc,
            rdata1_i       => id_rdata1,
            rdata2_i       => id_rdata2,
            imm_i          => id_imm,
            rdest_i        => id_rdest,
            rsrc1_i        => id_rsrc1,
            rsrc2_i        => id_rsrc2,
            npc_o          => ex_npc,
            rdata1_o       => ex_rdata1,
            rdata2_o       => ex_rdata2,
            imm_o          => ex_imm,
            rdest_o        => ex_rdest,
            rsrc1_o        => ex_rsrc1,
            rsrc2_o        => ex_rsrc2,
            -- Control signals
            ALUSrc2_i       => id_ALUSrc2,
            ALUOp_i         => id_ALUOp,
            memWrite_i      => id_memWrite,
            memDataFormat_i => id_memDataFormat,
            memDataSign_i   => id_memDataSign,
            memToReg_i      => id_memToReg,
            regWrite_i      => id_regWrite,
            jalEn_i         => id_jalEn,
            ALUSrc2_o       => ex_ALUSrc2,
            ALUOp_o         => ex_ALUOp,
            memWrite_o      => ex_memWrite,
            memDataFormat_o => ex_memDataFormat,
            memDataSign_o   => ex_memDataSign,
            memToReg_o      => ex_memToReg,
            regWrite_o      => ex_regWrite,
            jalEn_o         => ex_jalEn
        );

    -- Execute Stage
    execute_inst: execution
        generic map (nbit => nbit)
        port map (
            clk_i           => clk_i,
            reset_i         => rst_i,
            npc_i           => ex_npc,
            rdata1_i        => ex_rdata1,
            rdata2_i        => ex_rdata2,
            imm_i           => ex_imm,
            mem_fwd_rdata_i => mem_aluout,
            wb_fwd_rdata_i  => wb_data,
            rdata2_o        => ex_rdata2_final,
            aluout_o        => ex_aluout,
            -- Control signals
            ALUSrc2_i      => ex_ALUSrc2,
            ALUOp_i        => ex_ALUOp,
            jalEn_i        => ex_jalEn,
            -- Forwarding signals
            forwardA_i     => forwardA,
            forwardB_i     => forwardB
        );

    -- Forwarding Unit
    forwarding_unit_inst: forwarding_unit
        port map (
            ex_mem_regwrite_i => mem_regWrite,
            mem_wb_regwrite_i => wb_regWrite,
            if_id_branchEn_i  => id_branchEn,
            if_id_jumpEn_i    => id_jumpEn,
            if_id_jrEn_i      => id_jrEn,
            ex_mem_rd_i       => mem_rdest,
            mem_wb_rd_i       => wb_rdest,
            id_ex_rs1_i       => ex_rsrc1,
            id_ex_rs2_i       => ex_rsrc2,
            if_id_rs1_i       => id_rsrc1,
            forwardA_o        => forwardA,
            forwardB_o        => forwardB,
            forwardC_o        => forwardC
        );

    -- EX/MEM Pipeline Register
    ex_mem_regs_inst: ex_mem_regs
        generic map (nbit => nbit)
        port map (
            clk_i         => clk_i,
            reset_i       => rst_i,
            aluout_i      => ex_aluout,
            rdata2_i      => ex_rdata2_final,
            rdest_i       => ex_rdest,
            aluout_o      => mem_aluout,
            rdata2_o      => mem_rdata2,
            rdest_o       => mem_rdest,
            -- Control signals
            memWrite_i    => ex_memWrite,
            memDataFormat_i => ex_memDataFormat,
            memDataSign_i => ex_memDataSign,
            memToReg_i    => ex_memToReg,
            regWrite_i    => ex_regWrite,
            memWrite_o    => mem_memWrite,
            memDataFormat_o => mem_memDataFormat,
            memDataSign_o => mem_memDataSign,
            memToReg_o    => mem_memToReg,
            regWrite_o    => mem_regWrite
        );

    -- Memory Stage
    mem_access_inst: mem_access
        generic map (nbit => nbit)
        port map (
            clk_i       => clk_i,
            reset_i     => rst_i,
            aluout_i    => mem_aluout,
            rdata2_i    => mem_rdata2,
            dmem_addr_o => mem_dmem_addr,
            dmem_din_o  => mem_dmem_din,
            -- Control signals
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
            rdest_i       => mem_rdest,
            aluout_o      => wb_aluout,
            dout_o        => wb_dout,
            rdest_o       => wb_rdest,
            -- Control signals
            memToReg_i    => mem_memToReg,
            regWrite_i    => mem_regWrite,
            memToReg_o    => wb_memToReg,
            regWrite_o    => wb_regWrite
        );

    -- Write Back Stage
    write_back_inst: write_back
        generic map (nbit => nbit)
        port map (
            aluout_i      => wb_aluout,
            dout_i        => wb_dout,
            wbdata_o      => wb_data,
            -- Control signals
            memToReg_i    => wb_memToReg
        );

    -- Instruction Memory
    imem_en_o   <= '1';
    imem_addr_o <= if_instr_addr;
    if_instr    <= imem_dout_i;
    -- Data Memory
    dmem_en_o          <= '1';
    dmem_we_o          <= mem_memWrite;
    dmem_addr_o        <= mem_dmem_addr;
    dmem_din_o         <= mem_rdata2;
    dmem_data_format_o <= mem_memDataFormat;
    dmem_data_sign_o   <= mem_memDataSign;
    mem_dout           <= dmem_dout_i;
    
end architecture;
