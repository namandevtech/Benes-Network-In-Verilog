/* A parameterised Benes network (unidirectional)
No. of stages -> 2log2(N)-1 --- eq.1
Switches/stage -> N/2 --- eq.2
Total no. of SW -> eq.1 * eq.2
Ref. table for N:
N --- stages-SW/stage-total no. of SW
8 --- 5-4-20
16 --- 7-8-56
32 --- 9-16-144
64 --- 11-32-352
128 --- 13-64-832
256 --- 15-128-1920
512 --- 17-256-4352
1024 --- 19-512-9728 */

/* top module definition */
module benes_net #(
    parameter integer ELEMENTS = 8
) (
    input wire clk,
    input wire n_rst,
    input wire enable,
    input wire [TOTAL_SW-1:0] cfg,
    input wire [ELEMENTS-1:0] data_in,
    output wire [ELEMENTS-1:0] data_out
);

localparam integer STAGES = (2 * clog2(ELEMENTS)) - 1;
localparam integer SW_PER_STAGE = ELEMENTS / 2;
localparam integer TOTAL_SW = STAGES * SW_PER_STAGE;

    /* ceiling log2 function */
    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clog2 = 0;
            while (v > 0) begin
                v = v >> 1;
                clog2 = clog2 + 1;
            end
        end
    endfunction

    /* internal registers and wires */
    /* inter-stage bus for connecting adjoining stages */
    wire [ELEMENTS-1:0] inter_stage_bus[0:STAGES];

    /* static assignments */
    assign inter_stage_bus[0] = data_in;
    assign data_out = inter_stage_bus[STAGES];


    /* Generating a true Benes network with distanced mirrored topology */
    genvar stagex, swx;
    generate
        for (stagex = 0 ; stagex < STAGES ; stagex = stagex + 1) begin : NET_STAGES
            for (swx = 0 ; swx < SW_PER_STAGE ; swx = swx + 1) begin : STAGES_SWS
                localparam integer dist_0 = stagex - ((STAGES-1)/2);
                localparam integer dist_1 = (dist_0 < 0) ? -dist_0 : dist_0;
                localparam integer dist_2 = ((STAGES-1)/2);
                localparam integer D = (1 << (dist_2 - dist_1));

                localparam integer base_wire = ((swx / D) * (2 * D)) + (swx % D);
                localparam integer partner_wire = base_wire + D;

                benes_sw2x2 unit (
                    .clk(clk),
                    .n_rst(n_rst),
                    .enable(enable),
                    .cfg(cfg[stagex * SW_PER_STAGE + swx]),
                    .in({inter_stage_bus[stagex][partner_wire],
                        inter_stage_bus[stagex][base_wire]}),
                    .out({inter_stage_bus[stagex+1][partner_wire],
                        inter_stage_bus[stagex+1][base_wire]})
                );
            end
        end
    endgenerate


endmodule
