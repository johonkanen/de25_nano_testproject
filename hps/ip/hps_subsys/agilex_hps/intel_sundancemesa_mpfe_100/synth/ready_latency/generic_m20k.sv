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


// // Copyright 2021 Intel Corporation. 
// //
// // This reference design file is subject licensed to you by the terms and 
// // conditions of the applicable License Terms and Conditions for Hardware 
// // Reference Designs and/or Design Examples (either as signed by you or 
// // found at https://www.altera.com/common/legal/leg-license_agreement.html ).  
// //
// // As stated in the license, you agree to only use this reference design 
// // solely in conjunction with Intel FPGAs or Intel CPLDs.  
// //
// // THE REFERENCE DESIGN IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
// // WARRANTY OF ANY KIND INCLUDING WARRANTIES OF MERCHANTABILITY, 
// // NONINFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE. Intel does not 
// // warrant or assume responsibility for the accuracy or completeness of any
// // information, links or other items within the Reference Design and any 
// // accompanying materials.
// //
// // In the event that you do not agree with such terms and conditions, do not
// // use the reference design file.
// /////////////////////////////////////////////////////////////////////////////

(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module  generic_m20k   #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5
)(
    input clk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout,
    input sclr
    );

    localparam DEPTH = 1 << ADDR_WIDTH;
    altera_syncram  altera_syncram_component (
                .address_a (waddr),
                .address_b (raddr),
                .clock0 (clk),
                .data_a (din),
                .wren_a (we),
                .rden_b (re),
                .q_b (dout),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address2_a (1'b1),
                .address2_b (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a (1'b1),
                .byteena_b (1'b1),
                .clock1 (1'b1),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_b ({WIDTH{1'b1}}),
                .eccencbypass (1'b0),
                .eccencparity (8'b0),
                .eccstatus (),
                .q_a (),
                .rden_a (1'b1),
                .sclr (sclr),
                .wren_b (1'b0));
    defparam
        altera_syncram_component.address_aclr_b  = "NONE",
        altera_syncram_component.address_reg_b  = "CLOCK0",
        altera_syncram_component.clock_enable_input_a  = "BYPASS",
        altera_syncram_component.clock_enable_input_b  = "BYPASS",
        altera_syncram_component.clock_enable_output_b  = "BYPASS",
        altera_syncram_component.enable_ecc  = "FALSE",
        altera_syncram_component.enable_force_to_zero  = "FALSE",
        altera_syncram_component.optimization_option  = "HIGH_SPEED",
        altera_syncram_component.intended_device_family  = "Agilex 5",
        altera_syncram_component.lpm_type  = "altera_syncram",
        altera_syncram_component.numwords_a  = DEPTH,
        altera_syncram_component.numwords_b  = DEPTH,
        altera_syncram_component.operation_mode  = "DUAL_PORT",
        altera_syncram_component.outdata_aclr_b  = "NONE",
        altera_syncram_component.outdata_sclr_b  = "SCLEAR",
        altera_syncram_component.outdata_reg_b  = "CLOCK0",
        altera_syncram_component.power_up_uninitialized  = "FALSE",
        altera_syncram_component.ram_block_type  = "M20K",
        altera_syncram_component.read_during_write_mode_mixed_ports  = "DONT_CARE",
        altera_syncram_component.widthad_a  = ADDR_WIDTH,
        altera_syncram_component.widthad_b  = ADDR_WIDTH,
        altera_syncram_component.width_a  = WIDTH,
        altera_syncram_component.width_b  = WIDTH,
        altera_syncram_component.width_byteena_a  = 1;


endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8mA+XfEYDikaFO6LpJ8G+rpAGJqFnmkXbc8gkSvikdNPTXD1wLd3K5uoYtVCKgpRTV22XKfhvQFb9w9ByyKiKuFEK5BlxCUwtCjodGtGIXYcqdkeNTlkXGkvWMApc7AwHbrcsHmhty/Q4Iq2eUQSVIDfLUUkVCqczwVeXe4O3m5ugWCHE1g01HSDmQtr8W1VXdPlSK+ch4mxA1jLSkZELKXpreKIWntIOvxumBAIC5D0rNNg3NzcJ1OTdgbfgTRmt2qs9O67QcWghA65WZzPBn+pumTuKmK29kLVOPRRn3n1Y7xkHjOCAswY8yplZETaMpVgqKnrWC+zLZmR+mY5L11qwEduIJSWQmMYWDOxyWVof0hHge+7VACcUeuuZINBNf2yjSBetv/kpX5My2bdXtalAbNCqL2iNqTOn+VQcEqAw74V2aUZtCvjKZj8mM80L/HEjQmpavSvjUOJ3vc9Iz7wRqC6oemPWVajxDbGh3VNkDV88AqkKOCCvOgr2QY3A3rMcwRXJY0o6gDYrK4SWkcUw0iBgJojTFbqKfoND+wgWXrARBaPKX+zzdhEIYFfq6SElsZAP57HYRB8jxK4JsD6clZaUHdebu0eXXx/r+NaG56/wAIo8o/h77MvqIuXsqlGsyGqE8e89WJi7ST/5N4k61sqqSUGvQL2dXchOPm0M4C6izImyszH3dhaKC7wK1x9yfnMP8/yBFODn8GXERVXO+L7LfRn95LlafFu7OAkwJ5D2P6z3U6yzch5dzARu6SFSm3MYrMayoh8jiIvG52"
`endif