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

module compare_eq #(
    parameter WIDTH=10
) (
    input [WIDTH-1:0]  in_a,
    input [WIDTH-1:0]  in_b,
    output             equal
);

assign equal = (in_a==in_b);

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjQL9exbfXYTp137Dtd6Y0g6L4MgYOzwjRQpR0jP8MXyY0JHzOEOLBvGLeAfT0zJFN5eB54bfkyPWJXaUD9Yt++782v+rIWyQg5F3Q+VN5KWZObQSZSJZjskCikMATWs4odQUY2/UcTZ3iS0cyZ1gXZBv5vGyXsGpo3JMt8UqBRfF1GddwcaSNOLRFHi1adCsXu76Z1F1CAuiXCV+d92LcX5yDP9SbxTbuY8uOetEv1wHnVth16O1avdtiqUj8qtb0rrDaBUiskNDQOGgJrkP3YC2PV5p5Ep5C4udKdywI3ziips38Ds90PuJy67yjR8tG/R6zabBtu54dn1e8SLL326vGTA2sisJaEzjaRfIKsLJnA326qDRFJRXuJyNTM7cWuc6AbVd7frqsYkl08yfw34RPfW1+c+YH4f3PlPLrR0O6uYYvNhwJ9mQUj23tFchjYyASeMky7PNT0BIRTQEikjAtaLzBKpg5fs5fbnOqOERLQBFzbBPh4+FDq/9hu4gCx7eTa7MyIsxZKV5gt/lwT2hZcqDd/Z33loBENj5mAY5TuV7o5T6CQNg04nejD9dHDDPGwYJWtrjyx7Cdd/NXGCkPee8GzhdSawScqvEdT4qSIxEZ5C/Yaco4E3KjR+kltA956dS76He9dUzKofYAjSx8SNrd00sOxpHpDnq0yCOcmq6U2usnwNpYR4/6dZvcbsyarjLzWAiNvHJzbqrGMYbPHq2pU03yyDXkLFcSkzzETYMcG+/Jb0ZL6RUUP88PAn1MYWRVdlTzrc4hYcISV"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc/3fRCOMC7ZtuwldGcjP9hBCPb9R6+43F29EAlHvwDdqpHad9gRrgZbtD58p8F/OF+8ut1sRHN0JaLes6jT9fDWXGh+sDBJjTJ/wINpNUzZd4yO2sjBvhIzvHEpaEkiI1mpQwY2p8vMDq1AKz9NtqDyosBds+3yyQ9Ge2FyMMd2nipwmNlpHzbXajrP7HO5j3MNItLNjGhneh+raAzpI6UR6bTdS1gJqqfowVP5NrEBLbKzi9cofjXVTIm7/DH8TykZrtjJCFx6cxeQLMinO0Wzk1lKYnh1qrG+xe2dernSLBRz/vUOFZRsCPd1ZdNyf3cIlMvoEnexDh0CAVb7O+BL4jLX6uOvvfB9tIJAtomPasqV2ukeMbh0lU2Lf7yZRbYos47wdYZisJOlszLC0d7D7JZo0oTIgmfxQH6bZkbK2zi8yKFsj3K7CYpJw/M2yynxXojvtryzC/ZUzbWoXE6qfHwPthBVr1wSWCcZcXgt57+hUgWc4QlKbKsHli4ECzQhzT3Vbp8tzKyjz0QkWzhHltMAc1vIVOG0kffl0bIP2oXMIY7Gq545n6rCuP3kSS/Cp7tQZICjS9mnNzXPZdEQYcsoRPbIvdpbR1ZAsYWtC3KV4asbHvzArlFYYy+RDrQRrItYCFfAw/2TNBOB9jHfFcDZfIpRc6d3QR8ajJYuNNyOtzqaI3ikZTSvNYIPV3Tmj2ECBv/vw+Biwolx97gZFduZxNnaX9Pvx+HNxy9h10es47fxSPY98hmAbRCqjku6lF9pZCs8nhYSeiGHNxmG"
`endif