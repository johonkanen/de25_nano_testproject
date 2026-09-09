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


// Copyright 2021 Intel Corporation. 
//
// This reference design file is subject licensed to you by the terms and 
// conditions of the applicable License Terms and Conditions for Hardware 
// Reference Designs and/or Design Examples (either as signed by you or 
// found at https://www.altera.com/common/legal/leg-license_agreement.html ).  
//
// As stated in the license, you agree to only use this reference design 
// solely in conjunction with Intel FPGAs or Intel CPLDs.  
//
// THE REFERENCE DESIGN IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY OF ANY KIND INCLUDING WARRANTIES OF MERCHANTABILITY, 
// NONINFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE. Intel does not 
// warrant or assume responsibility for the accuracy or completeness of any
// information, links or other items within the Reference Design and any 
// accompanying materials.
//
// In the event that you do not agree with such terms and conditions, do not
// use the reference design file.
/////////////////////////////////////////////////////////////////////////////

module scfifo_s_normal #(
    parameter LOG_DEPTH      = 5,
    parameter WIDTH          = 20,
    parameter ALMOST_FULL_VALUE = 30,
    parameter ALMOST_EMPTY_VALUE = 2,
    parameter NUM_WORDS = 2**LOG_DEPTH - 1,
    parameter MLAB_ALWAYS_READ = 1, // 1 to reduce amount of routing; 0 to reduce power consumption 
    parameter OVERFLOW_CHECKING = 0, // Overflow checking circuitry is using extra area. Use only if you need it
    parameter UNDERFLOW_CHECKING = 0, // Underflow checking circuitry is using extra area. Use only if you need it
    parameter BUFFER_TYPE = "MLAB" // M20K or MLAB
)(
    input clock,
    input aclr,
    input sclr,
    input [WIDTH-1:0] data,
    input wrreq,
    input rdreq,
    output [WIDTH-1:0] q,
    output [LOG_DEPTH-1:0] usedw,
    output reg empty,
    output reg full,
    output reg almost_empty,
    output reg almost_full    
);

initial begin
    if ((LOG_DEPTH > 5) || (LOG_DEPTH < 3))
        $error("Invalid parameter value: LOG_DEPTH = %0d; valid range is 2 < LOG_DEPTH < 6", LOG_DEPTH);
        
    if ((ALMOST_FULL_VALUE >= NUM_WORDS) || (ALMOST_FULL_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_FULL_VALUE = %0d; valid range is 0 < ALMOST_FULL_VALUE < %0d", 
            ALMOST_FULL_VALUE, NUM_WORDS);     

    if ((ALMOST_EMPTY_VALUE >= NUM_WORDS) || (ALMOST_EMPTY_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_EMPTY_VALUE = %0d; valid range is 0 < ALMOST_EMPTY_VALUE < %0d", 
            ALMOST_EMPTY_VALUE, NUM_WORDS);  

    if ((NUM_WORDS > 2 ** LOG_DEPTH - 1) || (NUM_WORDS < 1))
        $error("Incorrect parameter value: NUM_WORDS = %0d; valid range is 0 < NUM_WORDS < %0d", 
            NUM_WORDS, 2 ** LOG_DEPTH);  
end

(* altera_attribute = "-name AUTO_CLOCK_ENABLE_RECOGNITION OFF" *) reg [LOG_DEPTH-1:0] write_addr = 0;
(* altera_attribute = "-name AUTO_CLOCK_ENABLE_RECOGNITION OFF" *) reg [LOG_DEPTH-1:0] read_addr = 0;
reg [LOG_DEPTH-1:0] capacity = 0;
wire [LOG_DEPTH-1:0] capacity_w;

wire wrreq_safe;
wire rdreq_safe;
assign wrreq_safe = OVERFLOW_CHECKING ? wrreq & ~full : wrreq;
assign rdreq_safe = UNDERFLOW_CHECKING ? rdreq & ~empty : rdreq;

initial begin 
    empty = 1;
    full = 0;
    almost_empty = 1;
    almost_full = 0;
end

add_a_b_s0_s1 #(LOG_DEPTH) adder(
    .a(write_addr),
    .b(~read_addr),
    .s0(wrreq_safe),
    .s1(~rdreq_safe),
    .out(capacity_w)
);

always @(posedge clock or posedge aclr) begin
    if (aclr) begin
        write_addr <= 0;
        read_addr <= 0;
        capacity <= 0;
        empty <= 1;
        full <= 0;
        almost_empty <= 1;
        almost_full <= 0;  
    
    end else if (sclr) begin
        write_addr <= 0;
        read_addr <= 0;
        capacity <= 0;
        empty <= 1;
        full <= 0;
        almost_empty <= 1;
        almost_full <= 0;  

    end else begin
    
        write_addr <= write_addr + wrreq_safe;
        read_addr <= read_addr + rdreq_safe;

        capacity <= capacity_w;
        
        empty <= (capacity == 0) && (wrreq == 0) || (capacity == 1) && (rdreq == 1) && (wrreq == 0);
            
        full <= (capacity == NUM_WORDS) && (rdreq == 0) || (capacity == NUM_WORDS - 1) && (rdreq == 0) && (wrreq == 1);
        
        almost_empty <=
            (capacity < (ALMOST_EMPTY_VALUE-1)) || 
            (capacity == (ALMOST_EMPTY_VALUE-1)) && ((wrreq == 0) || (rdreq == 1)) || 
            (capacity == ALMOST_EMPTY_VALUE) && (rdreq == 1) && (wrreq == 0);
            
        almost_full <= 
            (capacity > ALMOST_FULL_VALUE) ||
            (capacity == ALMOST_FULL_VALUE) && ((rdreq == 0) || (wrreq == 1)) ||
            (capacity == ALMOST_FULL_VALUE - 1) && (rdreq == 0) && (wrreq == 1);    
    end
end

assign usedw = capacity;

generate
    if (BUFFER_TYPE == "MLAB") begin 
        generic_mlab #(.WIDTH(WIDTH), .ADDR_WIDTH(LOG_DEPTH)) mlab_inst (
            .clk(clock),
            .din(data),
            .waddr(write_addr),
            .we(1'b1),
            .re(MLAB_ALWAYS_READ ? 1'b1 : rdreq_safe),
            .raddr(read_addr),
            .dout(q)
        );
    end
    else begin
    generic_m20k #(.WIDTH(WIDTH), .ADDR_WIDTH(LOG_DEPTH)) m20k_inst (
        .clk(clock),
        .din(data),
        .waddr(write_addr),
        .we(1'b1),
        .re(MLAB_ALWAYS_READ ? 1'b1 : rdreq_safe),
        .raddr(read_addr),
        .dout(q),
        .sclr(sclr)
    );
    end
endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8l3f/bpd2D/ffYubt6ehpdysQpWcCSj6y41GGpMm0pUGTtLXLjypb2Z9dMvcTMBUawQX1b8Im2E7Do0eNOx1k1kP1UL5u/FjOQ/8IWytXUJQmq6nq1vI0MEsiZfvb3DaagqRsYXJ21Qc7YWKjs/YYIG74weQEast9e+PB/qfyOerSWF5KHzmRaVDfagx3vv+DkVpYU/O69Z7Vy+yriAIQVaCeeJWc/k29A9IWVCeLa7pGQ95g57TlkRdpbWKFLrrNNuzgRI2nKe0qiwNM3fB5El8tOh4TAOBfGT/lk/zyu3DRijO8VOjvzHJhLk1abJdzVM1uLvtA88juP94sC6o1rYfOa8KI1kdJqEmgfajXcnKJNMXfq45vIklInikRIilzF3Wb2ktLL1Y+Wn6Mv3oteIloA2GRGz77gd6CsCpsY69clWyK/rBTWdKdHjfIy/2I7t7yJVB+YdhNnmOM93LJhQ1mD+IYAURObZrLLnvDIQ/mfc82RrkESWe2/5yBUA8e74DC3wF2iEFN7vbOSOl5TQAqTcBhGEDRfd9HJzEqgv6hxmksvUsrOpB+1EL6xPune5MtUbELjunqeJkwjbSbMLY0/krJDsbgSKzaXeGQKfz0ojgHykx2CMtArfrJCy0QKLAT2CdASRqV+4l+MnAna2eR4yhj1CHzS3jcngQVdHsfsEvYk177XFyZXiOm4X1UFLGf7OUhfBbs7b3oWgiHnM/JTD9NNrHNUesypVTS1Hl1HnV9n5kGhrCIb6bK+HPfLyngulhlw7JUCViQQ/Sv/5"
`endif