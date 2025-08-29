library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instructions_pkg.all;
use work.utils_pkg.all;
use work.alu_ops_pkg.all;

entity CPU is
    generic (
        nbit : integer := 32
    );
    port (
        clk_i   : in std_logic;
        rst_i   : in std_logic;
        -- instruction memory
        imem_en_o    : out std_logic;
        imem_addr_o  : out std_logic_vector(7 downto 0);
        imem_rd_i    : in std_logic;
        imem_dout_i  : in std_logic_vector(nbit-1 downto 0);
        -- data memory
        dmem_en_o    : out std_logic;
        dmem_we_o    : out std_logic;
        dmem_addr_o  : out std_logic_vector(ram_add-1 downto 0);
        dmem_din_o   : out std_logic_vector(ram_width-1 downto 0);
        dmem_dout_i  : in std_logic_vector(ram_width-1 downto 0)
    );
end entity;

architecture struct of CPU is
    ---------------------------------------------------------------------COMPONENTS
    component control_unit is
        generic(
            nbit : integer := 32
        );
        port (
            instr_i     : in std_logic_vector(nbit-1 downto 0);
            zero_i      : in std_logic;
            immSrc_o    : out std_logic;
            ALUSrc1_o   : out std_logic;
            ALUSrc2_o   : out std_logic;
            ALUOp_o     : out alu_op_t;
            regDest_o   : out std_logic;
            PCSrc_o     : out std_logic;
            memRead_o   : out std_logic;
            memWrite_o  : out std_logic;
            memToReg_o  : out std_logic;
            regWrite_o  : out std_logic;
            jalEn_o     : out std_logic
        );
    end component;

    component instr_fetch is 
        generic (
            nbit : integer := 32
        ); 
        port (
            clk_i   : in  std_logic;
            reset_i : in  std_logic;
            pc_i    : in  std_logic_vector(nbit-1 downto 0);
            npc_o   : out std_logic_vector(nbit-1 downto 0);
            instr_o : out std_logic_vector(nbit-1 downto 0)
        );
    end component;

    component if_id_regs is
        generic(
            nbit : integer := 32
        );
        port (
            clk_i    : in  std_logic;
            reset_i  : in  std_logic;
            pc_i     : in  std_logic_vector(nbit-1 downto 0);
            npc_i    : in  std_logic_vector(nbit-1 downto 0);
            instr_i  : in  std_logic_vector(nbit-1 downto 0);
            pc_o     : out std_logic_vector(nbit-1 downto 0);
            npc_o    : out std_logic_vector(nbit-1 downto 0);
            instr_o  : out std_logic_vector(nbit-1 downto 0);
            -- Control signals
            immSrc_i   : in  std_logic;
            ALUSrc1_i  : in  std_logic;
            ALUSrc2_i  : in  std_logic;
            ALUOp_i    : in  alu_op_t;
            regDest_i  : in  std_logic;
            PCSrc_i    : in  std_logic;
            memRead_i  : in  std_logic;
            memWrite_i : in  std_logic;
            memToReg_i : in  std_logic;
            regWrite_i : in  std_logic;
            jalEn_i    : in  std_logic;
            immSrc_o   : out std_logic;
            ALUSrc1_o  : out std_logic;
            ALUSrc2_o  : out std_logic;
            ALUOp_o    : out alu_op_t;
            regDest_o  : out std_logic;
            PCSrc_o    : out std_logic;
            memRead_o  : out std_logic;
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
            pc_i            : in  std_logic_vector(nbit-1 downto 0);
            npc_i           : in  std_logic_vector(nbit-1 downto 0);
            instr_i         : in  std_logic_vector(nbit-1 downto 0);
            waddr_i         : in  std_logic_vector(4 downto 0);
            wbdata_i        : in  std_logic_vector(nbit-1 downto 0);
            rdata1_o        : out std_logic_vector(nbit-1 downto 0);
            rdata2_o        : out std_logic_vector(nbit-1 downto 0);
            imm_o           : out std_logic_vector(nbit-1 downto 0);
            pc_o            : out std_logic_vector(nbit-1 downto 0);
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
            pc_i            : in  std_logic_vector(nbit-1 downto 0);
            npc_i           : in  std_logic_vector(nbit-1 downto 0);
            rdata1_i        : in  std_logic_vector(nbit-1 downto 0);
            rdata2_i        : in  std_logic_vector(nbit-1 downto 0);
            imm_i           : in  std_logic_vector(nbit-1 downto 0);
            pc_o            : out std_logic_vector(nbit-1 downto 0);
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
            PCSrc_i         : in  std_logic;
            memRead_i       : in  std_logic;
            memWrite_i      : in  std_logic;
            memToReg_i      : in  std_logic;
            regWrite_i      : in  std_logic;
            jalEn_i         : in  std_logic;
            ALUSrc1_o       : out std_logic;
            ALUSrc2_o       : out std_logic;
            ALUOp_o         : out alu_op_t;
            regDest_o       : out std_logic;
            PCSrc_o         : out std_logic;
            memRead_o       : out std_logic;
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
            pc_i            : in  std_logic_vector(nbit-1 downto 0);
            npc_i           : in  std_logic_vector(nbit-1 downto 0);
            rdata1_i        : in  std_logic_vector(nbit-1 downto 0);
            rdata2_i        : in  std_logic_vector(nbit-1 downto 0);
            imm_i           : in  std_logic_vector(nbit-1 downto 0);
            rdest_i_type_i  : in  std_logic_vector(4 downto 0);
            rdest_r_type_i  : in  std_logic_vector(4 downto 0);
            zero_o          : out std_logic;
            rdata2_o        : out std_logic_vector(nbit-1 downto 0);
            pc_o            : out std_logic_vector(nbit-1 downto 0);
            npc_o           : out std_logic_vector(nbit-1 downto 0);
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
            pc_i    : in  std_logic_vector(nbit-1 downto 0);
            npc_i   : in  std_logic_vector(nbit-1 downto 0);
            aluout_i: in  std_logic_vector(nbit-1 downto 0);
            rdata2_i: in  std_logic_vector(nbit-1 downto 0);
            rdest_i : in  std_logic_vector(4 downto 0);
            zero_i  : in  std_logic;
            pc_o    : out std_logic_vector(nbit-1 downto 0);
            npc_o   : out std_logic_vector(nbit-1 downto 0);
            aluout_o: out std_logic_vector(nbit-1 downto 0);
            rdata2_o: out std_logic_vector(nbit-1 downto 0);
            rdest_o : out std_logic_vector(4 downto 0);
            zero_o  : out std_logic;
            -- Control signals
            PCSrc_i     : in std_logic;
            memRead_i   : in std_logic;
            memWrite_i  : in std_logic;
            memToReg_i  : in std_logic;
            regWrite_i  : in std_logic;
            jalEn_i     : in std_logic;
            PCSrc_o     : out std_logic;
            memRead_o   : out std_logic;
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
            lmd_o   : out std_logic_vector(nbit-1 downto 0);
            rdest_o : out std_logic_vector(4 downto 0);
            -- Control signals
            PCSrc_i     : in std_logic;
            memRead_i   : in std_logic;
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
            lmd_i       : in  std_logic_vector(nbit-1 downto 0);
            rdest_i     : in  std_logic_vector(4 downto 0);
            aluout_o    : out std_logic_vector(nbit-1 downto 0);
            lmd_o       : out std_logic_vector(nbit-1 downto 0);
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
            lmd_i       : in  std_logic_vector(nbit-1 downto 0);
            rdest_i     : in  std_logic_vector(4 downto 0);
            wbdata_o    : out std_logic_vector(nbit-1 downto 0);
            wbaddr_o    : out std_logic_vector(4 downto 0);
            -- Control signals
            memToReg_i  : in std_logic;
            jalEn_i     : in std_logic;
            regWrite_o  : out std_logic;
        );
    end component;

    ---------------------------------------------------------------------SIGNALS
    -- IF stage signals
    signal if_pc, if_npc   : std_logic_vector(nbit-1 downto 0);
    signal if_instr        : std_logic_vector(nbit-1 downto 0);
    
    -- ID stage signals
    signal id_pc, id_npc   : std_logic_vector(nbit-1 downto 0);
    signal id_instr        : std_logic_vector(nbit-1 downto 0);
    signal id_rdata1, id_rdata2 : std_logic_vector(nbit-1 downto 0);
    signal id_imm          : std_logic_vector(nbit-1 downto 0);
    signal id_rdest_i, id_rdest_r : std_logic_vector(4 downto 0);
    
    -- EX stage signals
    signal ex_pc, ex_npc   : std_logic_vector(nbit-1 downto 0);
    signal ex_rdata1, ex_rdata2 : std_logic_vector(nbit-1 downto 0);
    signal ex_imm          : std_logic_vector(nbit-1 downto 0);
    signal ex_aluout       : std_logic_vector(nbit-1 downto 0);
    signal ex_zero         : std_logic;
    signal ex_rdest        : std_logic_vector(4 downto 0);
    
    -- MEM stage signals
    signal mem_pc, mem_npc : std_logic_vector(nbit-1 downto 0);
    signal mem_zero        : std_logic;
    signal mem_aluout      : std_logic_vector(nbit-1 downto 0);
    signal mem_rdata2      : std_logic_vector(nbit-1 downto 0);
    signal mem_lmd         : std_logic_vector(nbit-1 downto 0);
    signal mem_rdest       : std_logic_vector(4 downto 0);
    
    -- WB stage signals
    signal wb_data         : std_logic_vector(nbit-1 downto 0);
    signal wb_addr         : std_logic_vector(4 downto 0);
    
    -- Control signals
    signal ctrl_immSrc     : std_logic;
    signal ctrl_ALUSrc1    : std_logic;
    signal ctrl_ALUSrc2    : std_logic;
    signal ctrl_ALUOp      : alu_op_t;
    signal ctrl_regDest    : std_logic;
    signal ctrl_PCSrc      : std_logic;
    signal ctrl_memRead    : std_logic;
    signal ctrl_memWrite   : std_logic;
    signal ctrl_memToReg   : std_logic;
    signal ctrl_regWrite   : std_logic;
    signal ctrl_jalEn      : std_logic;

begin
    ---------------------------------------------------------------------INSTANCES
    control_unit_inst: control_unit 
        generic map (nbit => nbit)
        port map (
            -- Control signals
            instr_i    => if_instr,
            zero_i     => mem_zero,
            immSrc_o   => ctrl_immSrc,
            ALUSrc1_o  => ctrl_ALUSrc1,
            ALUSrc2_o  => ctrl_ALUSrc2,
            ALUOp_o    => ctrl_ALUOp,
            regDest_o  => ctrl_regDest,
            PCSrc_o    => ctrl_PCSrc,
            memRead_o  => ctrl_memRead,
            memWrite_o => ctrl_memWrite,
            memToReg_o => ctrl_memToReg,
            regWrite_o => ctrl_regWrite,
            jalEn_o    => ctrl_jalEn
        );

    fetch_inst: instr_fetch
        generic map (nbit => nbit)
        port map (
            clk_i   => clk_i,
            reset_i => rst_i,
            pc_i    => if_pc,
            npc_o   => if_npc,
            instr_o => if_instr
        );

    if_id_regs_inst: if_id_regs
        generic map (nbit => nbit)
        port map (
            clk_i     => clk_i,
            reset_i   => rst_i,
            pc_i      => if_pc,
            npc_i     => if_npc,
            instr_i   => if_instr,
            pc_o      => id_pc,
            npc_o     => id_npc,
            instr_o   => id_instr,
            -- Control signals
            immSrc_i   => ctrl_immSrc,
            ALUSrc1_i  => ctrl_ALUSrc1,
            ALUSrc2_i  => ctrl_ALUSrc2,
            ALUOp_i    => ctrl_ALUOp,
            regDest_i  => ctrl_regDest,
            PCSrc_i    => ctrl_PCSrc,
            memRead_i  => ctrl_memRead,
            memWrite_i => ctrl_memWrite,
            memToReg_i => ctrl_memToReg,
            regWrite_i => ctrl_regWrite,
            jalEn_i    => ctrl_jalEn
        );

    decode_inst: instr_decode
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            pc_i           => id_pc,
            npc_i          => id_npc,
            instr_i        => id_instr,
            waddr_i        => wb_addr,
            wbdata_i       => wb_data,
            rdata1_o       => id_rdata1,
            rdata2_o       => id_rdata2,
            imm_o          => id_imm,
            pc_o           => id_pc,
            npc_o          => id_npc,
            rdest_i_type_o => id_rdest_i,
            rdest_r_type_o => id_rdest_r,
            -- Control signals
            immSrc_i       => ctrl_immSrc,
            regWrite_i     => ctrl_regWrite
        );

    id_ex_regs_inst: id_ex_regs
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            pc_i           => id_pc,
            npc_i          => id_npc,
            rdata1_i       => id_rdata1,
            rdata2_i       => id_rdata2,
            imm_i          => id_imm,
            pc_o           => ex_pc,
            npc_o          => ex_npc,
            rdata1_o       => ex_rdata1,
            rdata2_o       => ex_rdata2,
            imm_o          => ex_imm,
            rdest_i_type_o => id_rdest_i,
            rdest_r_type_o => id_rdest_r,
            -- Control signals
            ALUSrc1_i      => ctrl_ALUSrc1,
            ALUSrc2_i      => ctrl_ALUSrc2,
            ALUOp_i        => ctrl_ALUOp,
            regDest_i      => ctrl_regDest,
            PCSrc_i        => ctrl_PCSrc,
            memRead_i      => ctrl_memRead,
            memWrite_i     => ctrl_memWrite,
            memToReg_i     => ctrl_memToReg,
            regWrite_i     => ctrl_regWrite,
            jalEn_i        => ctrl_jalEn
        );

    execute_inst: execution
        generic map (nbit => nbit)
        port map (
            clk_i          => clk_i,
            reset_i        => rst_i,
            pc_i           => ex_pc,
            npc_i          => ex_npc,
            rdata1_i       => ex_rdata1,
            rdata2_i       => ex_rdata2,
            imm_i          => ex_imm,
            rdest_i_type_i => id_rdest_i,
            rdest_r_type_i => id_rdest_r,
            zero_o         => ex_zero,
            rdata2_o       => ex_rdata2,
            pc_o           => ex_pc,
            npc_o          => ex_npc,
            aluout_o       => ex_aluout,
            rdest_o        => ex_rdest,
            -- Control signals
            ALUSrc1_i      => ctrl_ALUSrc1,
            ALUSrc2_i      => ctrl_ALUSrc2,
            ALUOp_i        => ctrl_ALUOp,
            regDest_i      => ctrl_regDest
        );

    ex_mem_regs_inst: ex_mem_regs
        generic map (nbit => nbit)
        port map (
            clk_i         => clk_i,
            reset_i       => rst_i,
            pc_i          => ex_pc,
            npc_i         => ex_npc,
            aluout_i      => ex_aluout,
            rdata2_i      => ex_rdata2,
            rdest_i       => ex_rdest,
            zero_i        => ex_zero,
            pc_o          => mem_pc,
            npc_o         => mem_npc,
            aluout_o      => mem_aluout,
            rdata2_o      => mem_rdata2,
            rdest_o       => mem_rdest,
            zero_o        => mem_zero,
            -- Control signals
            PCSrc_i       => ctrl_PCSrc,
            memRead_i     => ctrl_memRead,
            memWrite_i    => ctrl_memWrite,
            memToReg_i    => ctrl_memToReg,
            regWrite_i    => ctrl_regWrite,
            jalEn_i       => ctrl_jalEn
        );

    mem_access_inst: mem_access
        generic map (nbit => nbit)
        port map (
            clk_i         => clk_i,
            reset_i       => rst_i,
            npc_i         => mem_npc,
            aluout_i      => mem_aluout,
            rdata2_i      => mem_rdata2,
            rdest_i       => mem_rdest,
            pc_o          => mem_pc,
            npc_o         => mem_npc,
            lmd_o         => mem_lmd,
            rdest_o       => mem_rdest,
            -- Control signals
            PCSrc_i       => ctrl_PCSrc,
            memRead_i     => ctrl_memRead,
            memWrite_i    => ctrl_memWrite
        );

    mem_wb_regs_inst: mem_wb_regs
        generic map (nbit => nbit)
        port map (
            clk_i         => clk_i,
            reset_i       => rst_i,
            aluout_i      => mem_aluout,
            lmd_i         => mem_lmd,
            rdest_i       => mem_rdest,
            aluout_o      => wb_aluout,
            lmd_o         => wb_lmd,
            rdest_o      => wb_rdest,
            -- Control signals
            memToReg_i    => ctrl_memToReg,
            regWrite_i    => ctrl_regWrite,
            jalEn_i       => ctrl_jalEn,
            memToReg_o    => wb_memToReg,
            regWrite_o    => wb_regWrite,
            jalEn_o       => wb_jalEn
        );

    write_back_inst: write_back
        generic map (nbit => nbit)
        port map (
            aluout_i      => mem_aluout,
            lmd_i         => mem_lmd,
            rdest_i       => mem_rdest,
            wbdata_o      => wb_data,
            wbaddr_o      => wb_addr,
            -- Control signals
            memToReg_i    => ctrl_memToReg,
            jalEn_i       => ctrl_jalEn,
            regWrite_o    => ctrl_regWrite
        );

end architecture;
