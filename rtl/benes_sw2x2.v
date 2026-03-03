/*
17/02/26
A simple 2x2 switch for Benes(N) network (clos style network)
*/

module benes_sw2x2 (
    input wire enable,
    input wire cfg,
    input wire [1:0] in,
    output wire [1:0] out
);

assign out = (!cfg) ? {in[1] , in[0]} : {in[0] , in[1]};

endmodule;
