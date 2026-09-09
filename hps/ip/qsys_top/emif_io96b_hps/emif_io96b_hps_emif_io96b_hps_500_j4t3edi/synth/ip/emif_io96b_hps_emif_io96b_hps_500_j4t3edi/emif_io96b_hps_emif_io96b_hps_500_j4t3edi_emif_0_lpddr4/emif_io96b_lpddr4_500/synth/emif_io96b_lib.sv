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




module emif_ph2_gen_ff_init_1 (
    input wire clk,
    input wire d,
    output reg q 
    );
    
    initial
        q <= 1'b1;
        
    always @(posedge clk)
        q <= d;
    
    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3r7eKJk6TD83snHqVsGnBetQtyQnjTXUB3wChRnntnKY3wPaGneubuMI5Tg1TMIMLhc3T1m6G+WdFMml9yrkgUaNFNiUcAd5rqdu3pjyxRZ4j0V+IGe1npmr2i5Fr9lggnfHPYeZMNx4BSgSl8MnT37WUmbDjSpHcAzGYHdHNWud3y5EZUTRfg4Ek6GoUZlZMkovDfCJFBpHFC5c+zTZGsMOMTeQvB6piGwKHIfMr1+eI0IdQK+T7C07vFnMTqkFNBwTABbQr6BG669bpeWKn1/XlwymPw0u51NqtnqmQiB3f21PMpgosfv+C7p2GZDRQbLDbw/+QNLkQlcHgNbixnfRjQC7x5I7kPtMJ5DtJLv5xj1683fDFgn7mBz6+3Uzm/5j4WcEehu0u/sGbj9vxXgdzih2M4TVMFjRlCX7Miz4JwxeHT/n4TzdeZreFtth31Gq/Hh+HbX9mJFqtxStF8BHXrYOSY04AmdX/9oRNWnC1rfQiw6QQ3o2PHRQ1KzZUzO+roenOTB1Vw7PO8OLWYNz3SlJs8WS2IlfoJyl/enV7SVpSAP0GUTssZh1R7QZdDO4Ccl0Pz8yKDVbC2X4upqcXkUVH0RuEruIeb0gOEUnC4fJgL6zlk0amk5NVft7x6M4BjGSeWIIQgLHJVB0OUYwKKGX1xT+6KNzXW9vwR5YBLzKCp9z/92ELG4x5DTgPJa9D8T09kRvW9cZmi0aZ0tqC6FXpLV6BBI1Rsrf6ZnsMBpcoujw+4nQvlJPFYSDNNT5BUR9ozJofYaLwZoeuMccHH4yI7MEUFS/iMsOOPItFaCPhb3l6Zk0Hx6twBnmDGQxKAxNZKQtvRrbNogQBNVan56lGz80gG/mGImsvhdn09BhulJ+1xOfah5mMPKMYH8VhfoDhVoy1vA3wWfXh6PlQFPUFPUTqGOSxGYJ+cI/mRKEVJjz3Ir/VM86bNuwHp8AV7Sx21FdkJQ0EEMy4pEeCLPyixFgKzfpwY8Vcrz0ac0EmN0GHpiWBkDOkArq"
`endif