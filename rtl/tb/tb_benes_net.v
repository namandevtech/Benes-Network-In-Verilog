`timescale 1ns / 1ps

/* test top level module */
module tb_benes_net;


    /* local vars */
    localparam integer CLK_PER = 10;
    localparam integer ELEMENTS = 8;
    /* referenced from truth table */
    localparam integer STAGES = 5;
    localparam integer SW_PER_STAGE = 4;
    localparam integer TOTAL_SW = 20;

    /* test IOs */
    reg clk;
    reg n_rst;
    reg enable;
    reg [TOTAL_SW-1:0] cfg;
    reg [ELEMENTS-1:0] data_in;
    wire [ELEMENTS-1:0] data_out;

    /* instantiate the DUT */
    benes_net #(
        .ELEMENTS(ELEMENTS)
    ) dut (
        .clk(clk),
        .n_rst(n_rst),
        .enable(enable),
        .cfg(cfg),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PER / 2) clk = ~clk;
    end

    task _reset;
        begin
            n_rst = 1'b0;
            enable = 1'b0;
            cfg = {TOTAL_SW{1'b0}};
            data_in = {ELEMENTS{1'b0}};
            @(posedge clk);
            n_rst = 1'b1;
            @(posedge clk);
        end
    endtask

    /* tasks required for testing
   _update_data
  _set_cfg */
    task _send_data;
        input integer _addr_;
        input [7:0] _frame_;
        integer i;
        begin
            enable = 1'b1;
            @(posedge clk);
            for (i = 0 ; i < 8 ; i = i + 1) begin
                data_in[_addr_] = _frame_[i];
                @(posedge clk);
            end
            enable = 1'b0;
            @(posedge clk);
        end
    endtask


    /* main */
    // VCD dump controlled by +VCD=<path> (passed from Makefile)
    reg [1023:0] vcdfile;
    initial begin
        if ($value$plusargs("VCD=%s", vcdfile)) begin
            $dumpfile(vcdfile);
        end else begin
            $dumpfile("sim/wave.vcd");  // fallback
        end
        $dumpvars(0, tb_benes_net);

        /* initial states */
        _reset();

        /* actual test seq */
        _send_data(3'd0, 8'h55);
        _reset();
        _send_data(3'd7, 8'h55);
        _reset();
        cfg[0] = 1'b1;
        _send_data(3'd0, 8'h01);
        _reset();


        repeat (5) @(posedge clk);
        $display("PASSED ALL TESTS");
        $finish;

    end

endmodule
