/*
17/02/26
A simple 2x2 switch for Benes(N) network (clos style network)
*/

module benes_sw2x2 (
    input wire clk,
    input wire n_rst,
    input wire enable,
    input wire cfg,
    input wire [1:0] in,
    output reg [1:0] out
);

always @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        out[0] <= 1'b0;
        out[1] <= 1'b0;
    end
    else if (enable) begin
        if (!cfg) begin
            out[0] <= in[0];
            out[1] <= in[1];
        end
        else begin
            out[0] <= in[1];
            out[1] <= in[0];
        end
    end
    else begin
        out[0] <= 1'b0;
        out[1] <= 1'b0;
    end
end

endmodule;
