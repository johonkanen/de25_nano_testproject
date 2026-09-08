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


module wr_pri_mux_cwyib4q (
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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1rbu0GoNCH0FRRsqlwHlKfWXBHtdACsCugleBl+VppnFAVGCiljVU/hVg039mNos0FLvUGtTtn+S69V2Bk99AEmRqWVLVdtmemNW5i5X5e/W0WMcu8Gab7c0kdBc9yIQ0ckwl9Gp0fjmHNegpAHUJ4H2hMawCrd7fygmbdMNAr74pyUiawF4yqj/nb27jHABTVVaMp4sAdoFmR0zV4jFIfWoOkpK5vXvlUXgTplSsHQsaoAkhE1OWcP+gvjf65kp7wdZpLY9T1spuWtZiNVMbUsEucGuyMoDmv4l931DFZcczoXePMYZF4DCUpblAlMb8SS0WF75DblacFVSFqTMBNyRzLXMzvwEweD4acrl5ypOAWDeNrT2Qy4UKGgXZhNgZDlGDG4E8YFoUgvXets3L8hPFZDQoynfTWrNEN2ZzWBqIkKDoTr0R7/al/oAShtnss7m9oLGefpqBaca7p0XE+XKMrwZwa8DXktujfuGLWoZocU5jS0Ak4GJE1sqKK8DhIMKtj5bEQ5ZVmrbctFMFJOus67aY8NILhmtnleILtrbSdvzHxWrP7K9hGYaikU9Wu8QtKo7jivdJ0LjhXhsPC2Rt2frcIJObxmkxvVYJqx92t7g8LLD8Td6xebALgSRtfPU1X0g7GTvai6/odiNzsi+O4Mi1lKzgGhzqbw4redmm+zDRNPJGcV3TPwOnJGU38ZOEBD2dtlN4YjFj/1XLmWHdT940P/A9H3FHdvMHMZzJfiNcTn/2ODylJhuhLQWNpxPx7H90VC+uS/YXdCM0O3"
`endif