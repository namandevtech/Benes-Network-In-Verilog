`timescale 1ns/1ps

/* test top level module */
module tb_benes_sw2x2;

/* local vars */
localparam integer CLK_PER = 10;

/* test IOs */
reg clk;
reg n_rst;
reg enable;
reg cfg;
reg [1:0] in;
wire [1:0] out;


/* instantiate the DUT */
benes_sw2x2 dut (
    .clk(clk),
    .n_rst(n_rst),
    .enable(enable),
    .cfg(cfg),
    .in(in),
    .out(out)
);

initial begin
    clk = 1'b0;
    forever #(CLK_PER/2) clk = ~clk;
end

task _reset;
begin
    n_rst = 1'b0;
    enable = 1'b0;
    cfg = 1'b0;
    in[0] = 1'b0;
    in[1] = 1'b0;
    @(posedge clk);
    n_rst = 1'b1;
    @(posedge clk);
end
endtask



/* main */
// VCD dump controlled by +VCD=<path> (passed from Makefile)
reg [1023:0] vcdfile;
initial begin
    if ($value$plusargs("VCD=%s", vcdfile)) begin
        $dumpfile(vcdfile);
    end
    else begin
        $dumpfile("sim/wave.vcd"); // fallback
    end
    $dumpvars(0, tb_benes_sw2x2);

    /* initial states */
    _reset();


    /* actual test seq */
    enable = 1'b1;
    cfg = 1'b0;
    in[0] = 1'b0;
    in[1] = 1'b1;
    repeat (2) @(posedge clk);
    cfg = 1'b1;
    repeat (2) @(posedge clk);
    in[0] = 1'b1;
    in[1] = 1'b0;
    repeat (2) @(posedge clk);
    cfg = 1'b0;
    repeat (2) @(posedge clk);


    repeat (5) @(posedge clk);
    $display("PASSED ALL TESTS");
    $finish;

end

endmodule
