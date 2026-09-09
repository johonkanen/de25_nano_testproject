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

module add_a_b_s0_s1 #(
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
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "qGpFQTyeB49TiKcJqi+SbFpijxmu4TXeK4ITJEFWP4fPXKh9yaFCbKPq+kx68ePe/yYwWxdqX1e7EH24ET9NTnFQoZQoiJ/oIv2MyWNmI+DEkfevd5fOfIXCW5BhS667nS4GweRodqOHXMpDqeX+jKphchekcZUQb1/1JvT/HUQT9yJdd5Z6kIOR7gUpuJ1TRtPV01tS4Fo+nDv1+mRSA4l6pbsX4MlEisKtJJWy54zZXuP+ChbVCcBLMsAIO/zGP/RuNJDk/oRcLHWkEtEZRBhKY8TEEgRa4xlZMFiZzLCv15bnWtdWmSvDa3Y+Ynt1PBoeeTOpPGalXE1q04OrlisISuEddT4rshSPPB4aHp2wrdS1DyDuFz9XWCcIIXUHV9DPDAFohol0jyYUahufaUoKp8fB5vhCiD8QqMz/aYWY0cHS8Ws4UpQUV4xGyeWhO/Xzm3i8Sh2CkuXf/eaVtiWl5OqUYtjmFzzn7gIgvIu7eqfqPYRaJJqk0pupIxxN+t1QUz0fWtC7IXAc7MI0FFLu0bP+jwH7J50cPJBP7BUgFGKSoFPHEntcTLcvwyjERQsiS49pZvCA+yy7ceXCw5F9bRE47BKdbiN/juS6Fy9CMmTgBlOhTQt336xA7djS+NE46TFWQjLDaCvxX6gIF5LQdSiM0irWgtXTxy4NOQTTmqNQzrdZhU8BSASiVLUQ4ZgpPWqDHz8fiREtovWSSbzqJ2IDE/JWBxH5PBTXOYs3T0WIMWVjCkBkJBaaHjDQ6S9VhkseZgAaujXKQKqahWCiMdlKHMhrrinRYiqCslH91GTlQfTkP1mBRxRUL3s+r5k/4isSk7S4oQsbW4ys9/ow1OpF7LFhrANhXg58NvnJgOBjm5rwrPaLmtVcv1wpPWThu/Lq/UvvU9ZjC5aoA5cyL3I2MuvTQXAU49DkWLjSa3vla2qb7sbfRyxEosMF3zTuK/GsJ+Bout7HCZuspatsVkxCNwhfRTEKqh9tTySEKk8JrsImq+rpn5H5jLzo"
`endif