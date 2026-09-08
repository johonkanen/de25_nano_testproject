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






`timescale 1 ns / 1 ns
module altera_merlin_reorder_memory 
#(
   parameter  DATA_W         = 32,
              ADDR_H_W       = 4, 
              ADDR_L_W       = 4,
              VALID_W        = 4,
              NUM_SEGMENT    = 4,
              SYNC_RESET     = 0,
              DEPTH          = 16,
              USE_FIFO       = 0

)
    
(
    input                       clk,
    input                       reset,
    input [DATA_W - 1 : 0]      in_data,
    input                       in_valid,
    output                      in_ready,
 
    output reg [DATA_W - 1 : 0] out_data,
    output reg                  out_valid,
    input                       out_ready,
    input [ADDR_H_W - 1 : 0]    wr_segment,
    input [ADDR_H_W - 1 : 0]    rd_segment
 
);

    localparam SEGMENT_W  = ADDR_H_W;
    
    wire [ADDR_H_W + ADDR_L_W - 1 : 0] mem_wr_addr;
    reg [ADDR_H_W + ADDR_L_W - 1 : 0]  mem_rd_addr;
    wire [ADDR_L_W - 1 : 0]            mem_wr_ptr;
    wire [ADDR_L_W - 1 : 0]            mem_rd_ptr;
    reg [ADDR_L_W - 1 : 0]             mem_next_rd_ptr;
    reg [DATA_W - 1 : 0]               out_payload;
    
    wire [NUM_SEGMENT - 1 : 0]         pointer_ctrl_in_ready;
    wire [NUM_SEGMENT - 1 : 0]         pointer_ctrl_in_valid;
    wire [NUM_SEGMENT - 1 : 0]         pointer_ctrl_out_valid;
    wire [NUM_SEGMENT - 1 : 0]         pointer_ctrl_out_ready;
    wire [ADDR_L_W - 1 : 0]            pointer_ctrl_wr_ptr [NUM_SEGMENT];
    wire [ADDR_L_W - 1 : 0]            pointer_ctrl_rd_ptr [NUM_SEGMENT];
    wire [ADDR_L_W - 1 : 0]            pointer_ctrl_next_rd_ptr [NUM_SEGMENT];
    
    
    (* ramstyle="no_rw_check" *) reg [DATA_W - 1 : 0]               mem [DEPTH - 1 : 0];
 always @(posedge clk) begin
  if (in_valid && in_ready)
   mem[mem_wr_addr] = in_data;
        out_payload = mem[mem_rd_addr];
 end
   
    assign mem_wr_ptr       = pointer_ctrl_wr_ptr[wr_segment];

    assign mem_wr_addr  = {wr_segment, mem_wr_ptr};

    wire endofpacket;
    wire [ADDR_H_W - 1: 0] next_rd_segment;
    assign next_rd_segment  = ((rd_segment + 1'b1) == NUM_SEGMENT) ? '0 : rd_segment + 1'b1;

    genvar j;
    generate 
    if (USE_FIFO == 1) begin
        reg [ADDR_H_W-1:0]rd_segment_d1;
        always@(posedge clk) begin
        rd_segment_d1 <= rd_segment;
        end
    
        always_comb begin
          out_valid = (rd_segment_d1 == NUM_SEGMENT) ? 1'b0 :  pointer_ctrl_out_valid[rd_segment_d1];  
          out_data  = out_payload;
        end
        assign endofpacket  = out_data[0];
        always_comb  begin
          mem_next_rd_ptr  = pointer_ctrl_next_rd_ptr[rd_segment];
          mem_rd_addr      = {rd_segment, mem_next_rd_ptr};
        end
          
        for (j = 0; j < NUM_SEGMENT; j = j + 1)   begin : pointer_signal
           assign pointer_ctrl_in_valid[j]  = (wr_segment == j) && in_valid;
           assign pointer_ctrl_out_ready[j] = (rd_segment_d1 == j) && out_ready;
        end
    end
    else begin
        always_comb     begin
               out_data  = out_payload;
               out_valid = pointer_ctrl_out_valid[rd_segment];
           end
        assign endofpacket  = out_payload[0];
        always_comb     begin
           if (out_valid && out_ready && endofpacket)   begin
               mem_next_rd_ptr  = pointer_ctrl_rd_ptr[next_rd_segment];
               mem_rd_addr      = {next_rd_segment, mem_next_rd_ptr};
           end
           else    begin
               mem_next_rd_ptr  = pointer_ctrl_next_rd_ptr[rd_segment];
               mem_rd_addr      = {rd_segment, mem_next_rd_ptr};
           end
        end
       
       for (j = 0; j < NUM_SEGMENT; j = j + 1)
       begin : pointer_signal
            assign pointer_ctrl_in_valid[j]  = (wr_segment == j) && in_valid;
            assign pointer_ctrl_out_ready[j]  = (rd_segment == j) && out_ready;
                   
       end
    end
    endgenerate 
    assign in_ready  = pointer_ctrl_in_ready[wr_segment];
    
    
    genvar i;
    generate
        for (i = 0; i < NUM_SEGMENT; i = i + 1)
            begin : each_segment_pointer_controller
      memory_pointer_controller 
                 #(
                   .SYNC_RESET (SYNC_RESET),
                   .ADDR_W   (ADDR_L_W)
                   ) reorder_memory_pointer_controller
                 (
                  .clk              (clk),
                  .reset            (reset),                  
                  .in_ready         (pointer_ctrl_in_ready[i]),
                  .in_valid         (pointer_ctrl_in_valid[i]),
                  .out_ready        (pointer_ctrl_out_ready[i]),
                  .out_valid        (pointer_ctrl_out_valid[i]),                  
                  .wr_pointer       (pointer_ctrl_wr_ptr[i]),
                  .rd_pointer       (pointer_ctrl_rd_ptr[i]),
                  .next_rd_pointer  (pointer_ctrl_next_rd_ptr[i])
                  );
            end 
    endgenerate
endmodule


module memory_pointer_controller 
#(
    parameter SYNC_RESET = 0,
    parameter ADDR_W   = 4
)
(
    input                   clk,
    input                   reset,
    output reg              in_ready,
 input                   in_valid,
    input                   out_ready,
    output reg              out_valid,
 output [ADDR_W - 1 : 0] wr_pointer,
 output [ADDR_W - 1 : 0] rd_pointer,
    output [ADDR_W - 1 : 0] next_rd_pointer
);

 reg [ADDR_W - 1 : 0]  incremented_wr_ptr;
 reg [ADDR_W - 1 : 0]  incremented_rd_ptr;
 reg [ADDR_W - 1 : 0]  wr_ptr;
 reg [ADDR_W - 1 : 0]  rd_ptr;
 reg [ADDR_W - 1 : 0]  next_wr_ptr;
 reg [ADDR_W - 1 : 0]  next_rd_ptr;
 reg full, empty, next_full, next_empty;
 reg read, write, internal_out_ready, internal_out_valid;
 
 assign incremented_wr_ptr = wr_ptr + 1'b1;
 assign incremented_rd_ptr = rd_ptr + 1'b1;
 assign next_wr_ptr =  write ?  incremented_wr_ptr : wr_ptr;
 assign next_rd_ptr = read ? incremented_rd_ptr : rd_ptr;
 assign wr_pointer  = wr_ptr;
   assign rd_pointer  = rd_ptr;
   assign next_rd_pointer  = next_rd_ptr;
   
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate
 
   assign read  = internal_out_ready && !empty;
   assign write = in_ready && in_valid;
     generate
     if (SYNC_RESET == 0) begin : aysnc_reg0 
      always_ff @(posedge clk or posedge reset) 
             begin
      if (reset) 
                     begin
    wr_ptr <= 0;
    rd_ptr <= 0;
   end 
                 else 
                     begin
    wr_ptr <= next_wr_ptr;
    rd_ptr <= next_rd_ptr;
   end
   end
      end 
      else begin 

         always_ff @(posedge clk ) 
             begin
      if (internal_sclr) 
                     begin
    wr_ptr <= 0;
    rd_ptr <= 0;
   end 
                 else 
                     begin
    wr_ptr <= next_wr_ptr;
    rd_ptr <= next_rd_ptr;
   end
   end
      end 
      endgenerate
 always_comb 
        begin
            next_full = full;
            next_empty = empty;
      if (read && !write) 
                begin
    next_full = 1'b0;
    if (incremented_rd_ptr == wr_ptr)
     next_empty = 1'b1;
                end
      if (write && !read) 
                begin
                    next_empty = 1'b0;
                    if (incremented_wr_ptr == rd_ptr)
                        next_full = 1'b1;
   end
     end 
   generate 
    if (SYNC_RESET == 0) begin : aysnc_reg1
         always_ff @(posedge clk or posedge reset) 
             begin
                 if (reset) 
                     begin
                         empty <= 1;
                         full  <= 0;
                     end
                 else 
                     begin 
                         empty <= next_empty;
                         full  <= next_full;
                     end
              end

    end 
 
    else begin 

       always_ff @(posedge clk ) 
            begin
                if (internal_sclr) 
                    begin
                        empty <= 1;
                        full  <= 0;
                    end
                else 
                    begin 
                        empty <= next_empty;
                        full  <= next_full;
                  end
            end
     end 
     endgenerate
    always_comb
        begin
            in_ready            = !full;
            out_valid           = !empty;
            internal_out_ready  = out_ready;
  end 
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FgNOzQxIiBqloeezeBLMvtkKUBhxMD3+Oo3xN1J0G8wxw3m2tfBIK+PZfw0dM+aODPW4BrHQ8jXT/rxpkBlJSU9VIe3l+0sa8oec+KlgheFD4eeLOxkhJLkj35H8K3uNhDhppXo2aGgKhhiKjPCdJGoKhjdBWrpKatiVsxckYfOqBQDYJB2LzNHlX0duhj7sI78Fw9FFfyt2aWmHcMIpgbcsSvu40Cy7XvwomDz+kKLQepfFp5KEZcpE4a99GTQbMUeCjvvDlZvnR//1gIKMVg6+2ptfDOrCilgK1rkKD365XT7ixV+Zjp0ScGmbe7XFca90gPJBhbNPGcZNPdBhEIA/l3ZAQ11Ula6DVXlUNQjKr9OPRCqJN/mSMkJKyOlAxua2AZJlh3fklRMWqcBkZ3XuX3ZjaiNuf3N7KiNgvQFBD+6c/OVivw0N1yhHHM9iOyTlQ1oXXbgdMahTIAYgS9EXT6T2JV6YNswczQsmN7RNaaACftG1b68gBf6VtleBRK0qcg1Hpq7dw++/HkO8uyIaj4S7sjgpabarqoonnFvtmSxWSXZ6MyasoAMgYosSldiAwBbgvpH4fA1Jo+c7BKunjaAIOWZDtO6724wchS9Nvl2BNVcUKwvI0Ki/SJzIkZ+vVeckd4dTLigRvlHjE9r7JIAs4pvQvAWzoQ1In9BZ8Qpx3HLOPZiQ23pTK299zf0P4CanxCI8nGPYaLuNbZ4mAe5rvwby98ys2rOLgLsPBllktDC/UTdu32qUlfH2GrED9hmwj3pB6Yj9bQu8tVg"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc8q+Rn1IqaPVmfJEmIgovsCaxdbX6aYotRNqalpl5/M0FhgttWMq2oQKFgpLEi2PNlhjj8IKLVYgd9lh23bTVukLZnJ24MyKR5wz2CuvQ82c1MRiTQTFR8in8/XJ13JKg48C7//OO8/gw3CJmH33WUEyu4sUaXznEEwzDVD/5KlsT/rGvyle2KZpIacou3PpyrmZWQVAf4BoAYjhg9xla4dktt6g3Z3X8m+VS1jsrKqwWk4CDMYDi1COvqHX/Z3sZI6r1InBkrfzapG7w1BUo/u+iYVHItmcPGqHIrcHuN/fnEPhYAC2jy/wUKuHTNn99czpkFDZBv9EOjlMHUz/IiGGiLg7RguMS86tHhMLqoDYcljFBitSg/4nKB4afFJNqf0/Bv/ITD24ioY6Rd49r/awW/AicnbA9QUOUeqe3tiBPqqdNt/pCYd1YjWhkt3yxj/Syuwf6AHsylNJ9lLfChxq/hrMQbeC3oDQhIqDckCX25U6WEqZlxWjnkDhZvSvCm9XOKBLDVQHLkuomun39g+98gQO96XK/c1HQY2VJ0vRJwhf8eulICik0kxJ27nfvDdnr2WFlODD0BPV2LGydSRr/JHixqyP4nTGnO6/1n40iGMgP+RTEAyzIOS8gk4KFw3ecVDF+9+LdGa8L84LX4KNKQ0g8bkS+aisFiba/QM6FpGeVGYhl3/5MCTpFm0F5D+IZC49E/uUmcBnVkBiCimL0K9yIHRaqFj3NuV5WQ5cOLEqweDZYNZ2tm1oVGuweHfRpSEoIA1mizhC5H6uE0i"
`endif