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





module intel_axi4lite_injector_util_add_a_b_s0_s1 #(
    parameter SIZE = 5
)(
    input [SIZE-1:0] a,
    input [SIZE-1:0] b,
    input s0,
    input s1,
    output [SIZE-1:0] out
);
wire [SIZE:0] left;
wire [SIZE:0] right;
wire temp;
    
assign left = {a ^ b, s0};
assign right = {a[SIZE-2:0] & b[SIZE-2:0], s1, s0};
assign {out, temp} = left + right;  

endmodule


module intel_axi4lite_injector_util_binary_to_gray #(
    parameter WIDTH = 5
) (
    input clock,
    input aclr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

always @(posedge clock or posedge aclr) begin
    if (aclr)
        dout <= 0;
    else
        dout <= din ^ (din >> 1);
end

endmodule


module intel_axi4lite_injector_util_gray_to_binary #(
    parameter WIDTH = 5
) (
    input clock,
    input aclr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

wire [WIDTH-1:0] dout_w;

genvar i;
generate
    for (i = 0; i < WIDTH; i=i+1) begin : loop
        assign dout_w[i] = ^(din[WIDTH-1:i]);
    end
endgenerate

always @(posedge clock or posedge aclr) begin
    if (aclr)
        dout <= 0;
    else
        dout <= dout_w;
end

endmodule


(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module intel_axi4lite_injector_util_generic_mlab_sc #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter FAMILY = "Other" 
)(
    input clk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

genvar i;
generate
if (FAMILY == "S10") begin    
    reg [WIDTH-1:0] wdata_hipi;
    always @(posedge clk) wdata_hipi <= din;
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = clk; 
        wire rclk_w = clk; 
        fourteennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on           

            .portabyteenamasks(1'b1),
            .portadatain(wdata_hipi[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
end else if (FAMILY == "Agilex") begin    
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = clk; 
        wire rclk_w = clk; 
        tennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on       

            .portabyteenamasks(1'b1),
            .portadatain(din[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
    
end else begin

    localparam DEPTH = 1 << ADDR_WIDTH;
    (* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    reg [WIDTH-1:0] dout_r;
    always @(posedge clk) begin
        if (we)
            mem[waddr] <= din;
        if (re)
            dout_r <= mem[raddr];
    end
    assign dout = dout_r;

end
endgenerate    

endmodule


(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module intel_axi4lite_injector_util_generic_mlab_dc #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter FAMILY = "Other" 
)(
    input rclk,
    input wclk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

genvar i;
generate
if (FAMILY == "S10") begin    
    reg [WIDTH-1:0] wdata_hipi;
    always @(posedge wclk) wdata_hipi <= din;
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = wclk; 
        wire rclk_w = rclk; 
        fourteennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on       

            .portabyteenamasks(1'b1),
            .portadatain(wdata_hipi[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
end else if (FAMILY == "Agilex") begin    
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = wclk; 
        wire rclk_w = rclk; 
        (* altera_attribute = "-name MESSAGE_DISABLE 14320" *)
        tennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on       

            .portabyteenamasks(1'b1),
            .portadatain(din[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
    
end else begin

    localparam DEPTH = 1 << ADDR_WIDTH;
    (* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    reg [WIDTH-1:0] dout_r;
    always @(posedge wclk) begin
        if (we)
            mem[waddr] <= din;
    end
    always @(posedge rclk) begin
        if (re)
            dout_r <= mem[raddr];
    end
    assign dout = dout_r;

end
endgenerate    

endmodule


module intel_axi4lite_injector_util_synchronizer_ff_r2 #(
    parameter WIDTH = 8
)(
    input din_clk,
    input din_aclr,
    input [WIDTH-1:0] din,
    input dout_clk,
    input dout_aclr,
    output [WIDTH-1:0] dout
);

localparam MULTI = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]] 2\" ";
localparam FPATH = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]]\" ";
localparam FHOLD = "-name SDC_STATEMENT \"set_false_path -hold -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]]\" ";

reg [WIDTH-1:0] ff_launch = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge din_clk or posedge din_aclr) begin
    if (din_aclr)
        ff_launch <= 0;
    else
        ff_launch <= din;
end

localparam SDC = {MULTI,";",FHOLD};
(* altera_attribute = SDC *)
reg [WIDTH-1:0] ff_meta = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge dout_clk or posedge dout_aclr) begin
    if (dout_aclr)    
        ff_meta <= 0;
    else
        ff_meta <= ff_launch;
end

reg [WIDTH-1:0] ff_sync = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge dout_clk or posedge dout_aclr) begin
    if (dout_aclr)
        ff_sync <= 0;
    else
        ff_sync <= ff_meta;
end

assign dout = ff_sync;
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1p/64sBjcOZCnWw5VQv9vkf+V6lcOjVxLhD1nzVowAdLQAQ1FWhtFLhGmd+T/D6iDM9IJpyg/AAE4SJGXCx/p3nRHhGTsJckEvVg0YI1YvMtHkVLtIO/L5rc9Q06uRUWw0QthJFe1QUWofJNEMykEchiiGOXPV3Hy7JSO6R1R0raH8Zr3tfoEYWx2SCK2up1TQ/8Vf/NrbnDhajAPcxYfa4I1+98Efn3C0BiYYDxZXdVnK6BFo3TQTsLdZ4TkoiT+/tukRYk99BHlmh5J+y7mRXSMqibrX3/ljjIJvKZXoQeKjojEuNfj6fBn8EQA2zaN9gTkipt4qWXheE/adSXwIP2xx3vmNuSsrtrxYzKA7IDUuUoSP7Z4EV97yC8G6ymrUseUhIulLbi/Xx8LDfXqQhdYhuZj+o0AN8vnzlzPQ9pc+6Lxxr+Lb001qoWHoK/YcEuPvzu7nwwTUlYsqAl/NI7nQTA/Mn6jknf4tmk4EuP+GqZm3PF6XXlskV2XifQJhF8r3DOxFtLKlOcFbOj1PkAblJwXb8giqrg3T+/uvlRg1mfOjSurQ8zgxA/zR0Ls7AH4RGxDN/4NLmyPGMbKYK1neEkFCBwRw8Y2B0nPKXSnm9ClcWbOM0sADKNds0RzlY6KpYPJavV+QfTJNAHPZixnvPCu/eiWx0ekdhD1SVp+hDyiR7OdxKQ43lCAQsY+lzGaZvpwA445ubTIZGUKBVGVFVy15zmOPxdmZJ0DpQEivNKjRnTEIy4FxqyevDA++JqtUbhd2yG7zSfOrFH+SP"
`endif