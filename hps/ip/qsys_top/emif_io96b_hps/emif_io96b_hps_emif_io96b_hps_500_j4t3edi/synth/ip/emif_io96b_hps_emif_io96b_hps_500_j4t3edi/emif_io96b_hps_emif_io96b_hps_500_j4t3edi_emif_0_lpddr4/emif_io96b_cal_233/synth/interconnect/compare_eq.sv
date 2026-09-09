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
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX7ZDcPKqxxdWwb90C0rB1JJE6Q5jRieOVfmmGuhUYcSJ4/zKXD4eDKroinBOLrpU/VCx6hnjt/jIe0LDSDuq0jdMt7zSRdLnpbiiYToyLcdSfx9Kh94DTEkx1/aN+92NdBSDmO7GZcaQJEgsS8Wyfq1tbzUTfgikc6nQ0ZkIlVXHRbWjR0LTpPvEXvo4EvZ0rB9cmLjeRZPhz07fESUl4GQJdIkWf24zEP9k4k8Ehxljt/QYKl+vriVbY4taStL0gKsQ7ZWETALEjwZCqDCUz7hcO+zdpLGCKgy0g0QoSMLJtF3JaNo3CZXFJjM47Jd6GOa6XWKQvNQhcASbXeMHnLz1wKXviPEmJrqHn25eJ2DTviHhLhPVQ9VEHwTfIKkQVWUuSV6x/AEQIzhU+x+EmsvRXZMNdvxqPZL9lXcEkj3yJzXKLmciDV8j1M1+y84y0X9J7kRPX4JLQZfXiioko8Iiukb6AiZOJoA/RiT4hCk9vQoL0fr/l2RBU87ZTdZoLkN/E+pYfk9rISNWnIhbSlFC+oVcqTtfWW0Pg4YtVWOoKpRL+OBXNcdG2mgIIfdeFsYouiIC52mjepWkwfRa0Gx8IyqDlVtCH7dPHxOkuyYPGa0WmyuSzAnYV+TuWF9Xwu31rCQvLBUjDolLdvV3py4FEJXCpESjB275Kt05opa4+bGZcvWcTAh+ucqWSimbJz/U5QAXhFBUSQW2ewjcIBU7W+0z2fybaESi88jXphOIsuiyzoAu/eLXlBx3PrNofxYH15X1dGyixwzn/YmIqB2"
`endif