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


`timescale 1ns / 100ps

// this module has zero ready latency input and non zero latency output


module ready_latency_adapter # (
 parameter READY_LATENCY_OUT = 2,
 parameter PAYLOAD_WIDTH = 256,
 parameter LOG_DEPTH = 3,
 parameter BUFFER_TYPE = "MLAB"
) (  
 output logic         in_ready,
 input  logic            in_valid,
 input  logic   [PAYLOAD_WIDTH-1: 0]  in_data,
 // Interface: out
 input  logic             out_ready,
 output logic          out_valid,
 output logic [PAYLOAD_WIDTH-1: 0] out_data,
  // Interface: clk
 input logic          clk,
 // Interface: reset
 input logic           reset

 /*AUTOARG*/);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------
   
   logic [PAYLOAD_WIDTH-1:0]   in_payload;
   logic [PAYLOAD_WIDTH-1:0]   out_payload;
   logic            in_ready_wire;
   logic            out_valid_wire;
   logic [2:0]      fifo_fill;
   logic    rdreq;
   logic empty;   

   logic [READY_LATENCY_OUT-1:0] in_ready_dly_reg;
   logic in_ready_dly;
   assign in_ready_dly = (READY_LATENCY_OUT > 0) ? in_ready_dly_reg[0] : in_ready;

   logic fifo_wr_req;
   assign fifo_wr_req = (in_valid === 1'b1) && (in_ready_dly === 1'b1);
 
   localparam DEPTH = 2 ** LOG_DEPTH -1 ;

   // ---------------------------------------------------------------------
   //| Payload Mapping
   // ---------------------------------------------------------------------
   always @* begin
     in_payload = {in_data};
     {out_data} = out_payload;
   end

   // ---------------------------------------------------------------------
   //| FIFO
   // ---------------------------------------------------------------------                           
    scfifo_s # (
      .LOG_DEPTH (LOG_DEPTH),
      .WIDTH (PAYLOAD_WIDTH),
      .ALMOST_FULL_VALUE (DEPTH-1),
      .SHOW_AHEAD (1),
      .BUFFER_TYPE (BUFFER_TYPE)
    ) fifo_inst ( 
       .clock        (clk),
       .aclr       (1'b0),
       .sclr (reset),
       //.in_ready   (),
       .wrreq  (fifo_wr_req),      
       .data    (in_payload),
      //.out_ready  (out_ready),
       .rdreq      (rdreq),
       .q (out_payload),
       .usedw (fifo_fill),
       .empty (empty),
       .full (full),
       .almost_empty (),
       .almost_full ()
       );

   // ---------------------------------------------------------------------
   //| Ready & valid signals.
   // ---------------------------------------------------------------------
   always @* begin
      in_ready = ( DEPTH- fifo_fill > READY_LATENCY_OUT);
   end

    always @(posedge clk) begin
        in_ready_dly_reg[READY_LATENCY_OUT-1] <= in_ready;
        for (int i = 0; i < READY_LATENCY_OUT - 1; i++) begin
            in_ready_dly_reg[i] <= in_ready_dly_reg[i+1];
        end
    end

    generate
      if (BUFFER_TYPE == "MLAB") begin 
        assign out_valid = !empty;
      end
      else begin
        always @(posedge clk) begin
          out_valid <= !empty;
        end
      end
    endgenerate

   // ---------------------------------------------------------------------
   //| Read logic
   // ---------------------------------------------------------------------
   // read when out ready and fifo not empty

assign rdreq = out_ready && !empty;



endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8kkDgrQbCeC9VoM2l8v2Zbetvly1aGo9C1f3toOjfd7MvDlJIeNiSGX85W5gcKdulAYq5cnGQ5uA0LnsySuJoPWATVvhduRJq4Hn08YWMAeLWwpjAVwFWrr9m6zmd2C9D0p8hQWxRmqMvoGeZ6IIrSQ86l5FVJFBA0j/zKJb6UICOf7Sm7M4I2w8kH89QqxxohKFtjpbn/1iX9ZG6ajgMuIJeOVn+uCFYRSwVJs42+aF6DP2PAaGY5sD5hpbyhtzwVUjifVTjp3zgB3qt/dYuBfCGqTMflve3YOaIzkX3c/Gag9DFYqW0ZTLMdfHpyE/dM357OhJU1lXM5O8xAYk6TpjvBREuqmUFWG/btStlDkUu6WuWMCvRTESLT1FW6Nh8eLZmkZwNc2JdMN6kY+a8fk1XkAQ7YyZHNwXqo878vKZBA2DG/FS9ifsY4918N+nwFKGWYcPlT285z7oQdlzx8x+sxETfzFxnoMrPQyxnleU9g/nHgVRdqZBfEaCqOGwt7TYU1FqgSBVk/OCrK7YmnFFEYcOINoR20Qta12oIxFPA3ZZ4Sa6lvUQA5uH3cXfijJeEDNLKbI5aWVkpC+9+7mxpLN5i8SZdMXfYz+t8aTZEmjXjrOWg/95ZUC+SJobIbiO9xdkd9neVq7XFnxftrZbnDcGgUtW6gOpak3jdLcnE+UCDPD7LG2rJFT4y9nUbi/pwzf0kn3Zb6rGIRxoelR9xCoQW8/isf6OFExZ4kqEIr3zj836sBS9KKEGlf8jLma3wozJIfV+b0lDjMLZNIi"
`endif