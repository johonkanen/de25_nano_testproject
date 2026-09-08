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


module wr_pri_mux_kt2puei (
input in0,
input [1-1:0] clr, 
input [1-1:0] shift_index_out, 
output logic sel,
output logic [1-1:0] sel_index
);

always @ * begin
    if (in0 && !clr[0]) begin
        sel = in0;
        sel_index=0;
    end
end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1rm1jvTZJUmnBNv8C2fzpOPuQslSGnsVHUJhABrVGJxW0pqBzYpvfDRlUS8YY0VSNDI6YGLae+jPG0KBSuVBCUzo+RKlVgt2L2YhFfTtOMf9FwD8Y+n3iqEB1jJeIiizINhD3wE7zJvZWszalGl86Joy3HJqCU/zaHhfwJGHyfztDss/9TuYA8JARVicO64eE6vCHxvT+t3DPWqd6FMIWYbN91bH6A4i2lA11Ml2dCjl8Dcp8jD2FdMtVeaNzzzk6vcwQbkRDQFJ+nqyg2w8HfkzarhYlvQflRZqB6KD1yApG6AC9FIpghAHnO3rxAQfuLhsxtMZ8t5FaeBrwjDaWbWhO5uZ2T6ZNnDrhOl9p58czKOabybVG42dntTyYpGJhH6vR6vMKnK+gQqOHLmOKhRxAJIqwM9XX+ZXJsDC8CLnR/4aZdbOAIrO5IVl0h71V3WB86u8ZNniCONSfSWXJXXE5br1NZHddStH5lcXUkOLmT8xhPN7hcZQuYGcsDDxJlo4MuVxqmMb9hlF3J67NKCtrCkILZhp36hg2CfLbW+YvRd/+RqT9qwAOQhUzBfXIsLmTZ9QHbIYu7EjkykTSFADe2G12EuiqtLcR9/MoMTo7CHR0gDR25Nflv1659opkzYZkzS+gVosL65moOjGSkRehPHlURB+nTAqeFM+Gsk8dQ4T2blgH/4CEb5J16m95lDdV8UKqqAsDfk/lf4HmRnbmGzwTEiKePw1m8VXtAdcsi3dXB3uPhXsniFyLHIXIsGLTKSkz48YlQgcW+hUKDW"
`endif