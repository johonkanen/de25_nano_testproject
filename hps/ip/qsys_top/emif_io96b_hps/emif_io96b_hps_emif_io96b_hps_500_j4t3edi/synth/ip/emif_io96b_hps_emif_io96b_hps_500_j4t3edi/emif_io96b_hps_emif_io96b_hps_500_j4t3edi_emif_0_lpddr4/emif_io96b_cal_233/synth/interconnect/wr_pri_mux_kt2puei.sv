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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW50GRRjZwDnf2ZfZL3kEn4GBw15gZSDmKtEUDrzdGy7kguenAcpJPdJq9XY46wGmNLZGw3aM/QXhcLOvFtUp9nyUCGJk+pKEZpN4G0N5mTSedi9eb222IeswGHtMD23F5oizdd4kfic02YUvUGfoFpsjG6T5UIkCB4dw3i1k0txbd/7Vz7CHhEkk4yBjPTIFfJKReGXyzYedy0qM3Qg2Rd6MmXIP8RqLk08TX9LRoLLybd30GIWExF61bh1ZrRz4zZzcjQ6YG6herDMhnQ7yTP0dJjwDl03UGT59d+Dr2Fdj5HH//ZuN8TP+13mbNqrWLMag1ZVEFhM6xh2lSI4pEa2wSZaOOf0fCztZiIKX3IOQ93wTHrQUwYjGRmtpAVFv4x4vmRdN9Wzi3uqhX6q343yw+jBjA/NQdTdUdi8QIkj6KDTCB/QbN17TJwjZx+T3qWJhgtNdfgJiMsRbLjhfeJsEPKfxIV73eoGvJLV9ByJClmH9Rm5nhbrYOHTM6cnWMqymyTRoGXPPOLoFSgvg9XntgxKJi7TgXpEUmtcxWMqSC1xnvFnbD1ddwoEpAFoB07YJe5eZ3QbmK9ZqcB76LN1KhxNLv+RZ8oB3z4ByIsGhXOTf1pxFAtBeALBl9sSlL07yNlDXLTljFaQtZQSqUdTIP4C4QruMzkbOJCc15hb0/eshPclFysYifhI7xbKpOIH3vsVu67Ck6sdDxvYQMd7xuwxTj8dUSwKAf8hqbtZn83g70QtaZswr3L9fV1GiSDBfv7oZC7myzXLd7OdsejB"
`endif