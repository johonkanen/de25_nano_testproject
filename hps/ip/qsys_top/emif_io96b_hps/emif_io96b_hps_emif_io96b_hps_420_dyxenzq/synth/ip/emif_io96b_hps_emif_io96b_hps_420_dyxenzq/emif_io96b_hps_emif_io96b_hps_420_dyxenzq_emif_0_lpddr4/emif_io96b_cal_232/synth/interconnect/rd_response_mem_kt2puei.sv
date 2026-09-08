// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.




`timescale 1ps/1ps

module rd_response_mem_kt2puei #(
    parameter ST_DATA_W = 35,
    parameter ID_W      = 10,
    parameter PIPELINE_OUT = 0,
    parameter PIPELINE_CMP = 0
) ( 
    input                 clk,
    input                 rst,
    input                 in_valid,
    input [ST_DATA_W-1:0] in_data,
    output                in_ready,
    output logic          out_valid,
    output[ST_DATA_W-1:0] out_data,
    input                 out_ready,
    output                cmd_valid,
    output [ID_W-1:0]     cmd_id,
    input                 cmd_ready,
    input                 rsp_valid,
    input [ID_W-1:0]      rsp_id,
    output logic          rsp_ready    
);

localparam PIPELINE_CNT = PIPELINE_OUT + PIPELINE_CMP ;


	  localparam [4:0] depth = 1;
	  localparam [4:0] depth_index = 1;


logic [ST_DATA_W:0] dout0;
logic [1-1:0] sel_index;
logic [1-1 :0] demuxed,demuxed_valid;
logic ready_out_mem;
logic [1 -1 :0] shift_occurred;

rd_sipo_plus_kt2puei #(
    .TOTAL_W (ST_DATA_W+1),
    .ID_W    (ID_W) 
) mem (
    .clk             (clk),
    .rst             (rst),
    .in_valid        (in_valid  & cmd_ready),
    .in_data         (in_data),
    .in_ready       (ready_out_mem),
    .clr             (demuxed_valid), 
    .shift_occurred  (shift_occurred),
    .dout0           (dout0)
);


rd_comp_sel_kt2puei #(
    .PIPELINE_OUT(PIPELINE_OUT),
    .PIPELINE_CMP(PIPELINE_CMP),
    .WIDTH       (ID_W)
) comp_sel (
    .clk            (clk),
    .in_0           ({dout0[ST_DATA_W],dout0[ID_W-1:0]}),
    .base           (rsp_id),
    .shift_occurred (shift_occurred),
    .sel            (),
    .sel_index      (sel_index),
    .clr            (demuxed_valid)
);

rd_demux_kt2puei demux ( .index(sel_index), .demuxed(demuxed)  );

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_0
        assign demuxed_valid[i] = demuxed[i] & rsp_valid & rsp_ready;
    end
endgenerate 
rd_mux_kt2puei #(
    .DATA_W(ST_DATA_W)
) mux (
    .index (sel_index),
    .in0           (dout0[ST_DATA_W-1:0]),
    .muxed (out_data)
);

assign in_ready = ready_out_mem;
generate 
    if (PIPELINE_CMP==1) begin : PPL_1
        always @ (posedge clk) begin
            out_valid <= rsp_valid;
            rsp_ready    <= out_ready;
        end
    end
    else begin : PPL_0
        assign out_valid = rsp_valid;
        assign rsp_ready    = out_ready;
    end
endgenerate


assign cmd_valid = in_valid & in_ready;
assign cmd_id    = in_data[ID_W-1:0];

endmodule

module rd_demux_kt2puei (
    input  [1-1:0] index,
    output [1 -1 :0] demuxed
);

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_1
        assign demuxed[i] = (i==index);
    end
endgenerate
endmodule


module rd_mux_kt2puei #(
    parameter DATA_W = 10
) (
    input [1-1:0] index,

    input  [DATA_W-1:0] in0,

    output logic [DATA_W-1:0] muxed
);
  
always @ * 
    case (index)
     default : muxed = in0;

    endcase

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1pySI+LhC2bHZQ8tBkwVuH8ga8fiqKvaMhgZH1Vd5IRhFe3HlaLMot0nvXu1nt6g1b0annpU8OfgF4Ofg95gwJG1anpgcPycYnS6SZkAOiLimZdccm+OL7S6sDC3bGdd5T5GAN2f4HyKf3lBw5KPv+nn4HyAzOyx2cnoHMaCNA72t7aSiSTaWDjsHM3p2/HesQb807L6f3HrF5ZZWf2k79LSsxLbLdkjJDj7IQKAtPXPkgJkUloS4IsDOmugXslJp1ZPrGDv8oLWaSyqGLsVns9b8s1Q0LK0Xl29oV/3IuvwwsE/O1wltf0nSSJzX0vVt1Uas3IZ+mD+Vg3EiDbHjx4TAFYX8WYVZW/Nrcn/z9dZQWym1iWuvMO8KcIwT9b7BePzZNO6c+ETGm2mAI4HI8E3FnML8bsCHc5LsE84RWmqSFaagFrNPi+3CXa7lzkPpOGFWHkQ/gn2RKup/M+6axYD09PZBjmLfOaJeaEdq9AFsIEVTHxjucAznRtUyuxO0CqsiEs8sskYm0Q69fctYBPKia4FZHt65SsBfAuuaLRrIZHR/vMd4d61fx22ZaUxFLTJ5MWZdXl/0j/eVFn51EodC9vG6xAdbAVk1Y5pL33SsdzL15J4UoGUM/iSidqudarYCUJMObsZq1k8q4lw47oovH4+CKjFMESZPQ8aLkLCW66GPXDS4yTWjWHfnk5oFOoRk/ueWgoiXAq/CRfqSDfiwFi10WJYhH3DRrGs9+t2PanSXv+h0tFrfPm5b//ELf2/B//rapXD2AXQnBHVTD8"
`endif