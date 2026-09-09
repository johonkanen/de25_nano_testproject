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

// scfifo_s is designed as a faster and smaller replacement of scfifo
// 
// Notes
// 1. The only scfifo port not supported by scfifo_s is "eccstatus".
//    All the other ports are identical to scfifo.
//
// 2. Both "normal" and "show-ahead" modes are supported. (parameter SHOW_AHEAD)
//
// 3. almost_empty and almost_full thresholds are supported 
//    See parameters ALMOST_EMPTY_VALUE and ALMOST_FULL_VALUE
//
// 4. scfifo_s is either MLAB or M20k-based and is able to store up to 31 words.
//
// 5. All MLABs or M20ks are fully registered in every mode.
//    This is different from scfifo which has unregistered MLAB or M20k in show-ahead mode

module scfifo_s #(
    parameter LOG_DEPTH      = 5,
    parameter WIDTH          = 20,
    parameter ALMOST_FULL_VALUE = 30,
    parameter ALMOST_EMPTY_VALUE = 2,
    parameter SHOW_AHEAD = 0, // Show-ahead mode is using a lot of area. Use Normal mode if possible  
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
    output empty,
    output full,
    output almost_empty,
    output almost_full    
);

initial begin
    if ((LOG_DEPTH >= 6) || (LOG_DEPTH <= 2))
        $error("Invalid parameter value: LOG_DEPTH = %0d; valid range is 2 < LOG_DEPTH < 6", LOG_DEPTH);

    if (WIDTH <= 0)
        $error("Invalid parameter value: WIDTH = %0d; it must be greater than 0", WIDTH);
        
    if ((ALMOST_FULL_VALUE >= 2 ** LOG_DEPTH - 1) || (ALMOST_FULL_VALUE < 4))
        $error("Incorrect parameter value: ALMOST_FULL_VALUE = %0d; valid range is 3 < ALMOST_FULL_VALUE < %0d", 
            ALMOST_FULL_VALUE, 2 ** LOG_DEPTH - 1);     

    if ((ALMOST_EMPTY_VALUE >= 2 ** LOG_DEPTH - 4) || (ALMOST_EMPTY_VALUE < 1))
        $error("Incorrect parameter value: ALMOST_EMPTY_VALUE = %0d; valid range is 0 < ALMOST_EMPTY_VALUE < %0d", ALMOST_EMPTY_VALUE, 2 ** LOG_DEPTH - 4);  
end

generate
if (SHOW_AHEAD == 1)
    scfifo_s_showahead #(
        .LOG_DEPTH(LOG_DEPTH),
        .WIDTH(WIDTH),
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
        .OVERFLOW_CHECKING(OVERFLOW_CHECKING),
        .UNDERFLOW_CHECKING(UNDERFLOW_CHECKING),
        .BUFFER_TYPE(BUFFER_TYPE)
    ) a1 (
        .clock(clock),
        .aclr(aclr),
        .sclr(sclr),
        .data(data),
        .wrreq(wrreq),
        .rdreq(rdreq),
        .q(q),
        .usedw(usedw),
        .empty(empty),
        .full(full),
        .almost_empty(almost_empty),
        .almost_full(almost_full)    
    );
else
    scfifo_s_normal #(
        .LOG_DEPTH(LOG_DEPTH),
        .WIDTH(WIDTH),
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),
        .OVERFLOW_CHECKING(OVERFLOW_CHECKING),
        .UNDERFLOW_CHECKING(UNDERFLOW_CHECKING),
        .BUFFER_TYPE(BUFFER_TYPE)
    ) a2 (
        .clock(clock),
        .aclr(aclr),
        .sclr(sclr),
        .data(data),
        .wrreq(wrreq),
        .rdreq(rdreq),
        .q(q),
        .usedw(usedw),
        .empty(empty),
        .full(full),
        .almost_empty(almost_empty),
        .almost_full(almost_full)    
    );
endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8nNbyNdkmqRO6oOdWpPOWe6eUhhu9mzgIviXmheV+dc11dQ+bAkViTZShGnHc0M/6p14VfO+lrQLESUulYKRbesomCZu6lC0zPYxG5QtZR7FGXL3Yq50zlz5EIu24U2Uvnv28+c/syo2QOg54nXVmmh+CXMtpitevjZYsHvtp+NZAfWsMk1cXt59d5azExNWM3ZXT2ooOnECw9nTtINF7MRKImyczx8apBQwaZGGnrS4IUJmvpG4dbSHmP4YtKZ/QA6X8H+SdhTuk4BePmJcJPuOBf9gtwLJbbTMCvmrWBVS+qNl22LCmDTiFBTwBE9bUkBS1J0/UAXDOd67GLCMUDMAD76uvGdV05oSZQ6Qp+f4iBwM/CmjeN6ka71s5exKLUDoov2C9TIvF3NyssR63Iwuy0csQgQUzSTGs0gtMQ7osoCJcCcNcpbOs9plMepTzSk8jrI/EbkV7fSDnWQk21/yLqfLz9pilvH2THvvOb5fV7ALmD6IALzppfEmInXu0VYJVQ8TRDd6HN9cx/Q4FAwENVLLGCryf2hYvg/YqIJ2Q3KiYx2514CtwWD/8eUoVvsB6QiyqPSK2+wycqnTkZCm52sQKUGxYwigUa8xfswyQb0zECWYbgDpEmXADiNNgtmVNEdSMzGXhSr7iWoRAFaiu+OWhAHjl/AhcLjvgxHnkftMrj0frARbxVMSvNv2Fv3TSYR7xAkuQmCaTR3rVd+CouM+r34xZv9LzrY4J6fXgz8+EktUkRB32tvUOKpqjdgMKdmAGtZzQltav6JADLr"
`endif