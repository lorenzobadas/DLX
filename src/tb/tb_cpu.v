module tb_cpu;

    // Constants
    parameter nbit = 32;
    parameter ram_width = 32;
    parameter ram_add = 8;
    parameter CLK_PERIOD = 10;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // Instruction memory signals
    wire imem_en;
    wire [ram_add-1:0] imem_addr;
    wire [ram_width-1:0] imem_dout;

    // Data memory signals
    wire dmem_en;
    wire dmem_we;
    wire [ram_add-1:0] dmem_addr;
    wire [ram_width-1:0] dmem_din;
    wire [1:0] dmem_data_format;
    wire dmem_data_sign;
    wire [ram_width-1:0] dmem_dout;

    // End simulation signal
    reg simulation_done = 0;

    // Instantiate the CPU
    cpu cpu_inst (
        .clk_i(clk),
        .rst_i(rst),
        .imem_en_o(imem_en),
        .imem_addr_o(imem_addr),
        .imem_dout_i(imem_dout),
        .dmem_en_o(dmem_en),
        .dmem_we_o(dmem_we),
        .dmem_addr_o(dmem_addr),
        .dmem_din_o(dmem_din),
        .dmem_data_format_o(dmem_data_format),
        .dmem_data_sign_o(dmem_data_sign),
        .dmem_dout_i(dmem_dout)
    );

    // Instantiate the instruction memory
    instr_memory #(
        .ram_width(ram_width),
        .ram_depth(1 << ram_add),
        .ram_add(ram_add),
        .init_file("../sim/instr_memory.mem")
    ) imem_inst (
        .clk_i(clk),
        .reset_i(rst),
        .en_i(imem_en),
        .addr_i(imem_addr),
        .dout_o(imem_dout)
    );

    // Instantiate the data memory
    data_memory #(
        .ram_width(ram_width),
        .ram_depth(1 << ram_add),
        .ram_add(ram_add),
        .init_file("../sim/data_memory.mem")
    ) dmem_inst (
        .clk_i(clk),
        .reset_i(rst),
        .en_i(dmem_en),
        .we_i(dmem_we),
        .addr_i(dmem_addr),
        .din_i(dmem_din),
        .data_format_i(dmem_data_format),
        .data_sign_i(dmem_data_sign),
        .dout_o(dmem_dout)
    );

    // Clock generation
    always begin
        if (!simulation_done) begin
            clk = 0;
            #(CLK_PERIOD/2);
            clk = 1;
            #(CLK_PERIOD/2);
        end else begin
            #1;
        end
    end

    // Test process
    initial begin
        rst = 1;
        #(CLK_PERIOD * 2);
        rst = 0;
        #(CLK_PERIOD * 10000);
        simulation_done = 1;
    end

endmodule
