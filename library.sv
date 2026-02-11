`default_nettype none

module Decoder
    (input logic [2:0] I,
     input logic   en,
     output logic [7:0] D);

     always_comb begin
         if (en)
             D = 8'b1 << I;
         else
             D = 8'b0;
     end

endmodule : Decoder

module BarrelShifter
    (input logic [15:0] V,
     input logic   [3:0] by,
     output logic [15:0] S);

     always_comb begin
          S = V << by;
     end

endmodule : BarrelShifter

module Multiplexer
    (input logic [7:0] I,
     input logic [2:0] S,
     output logic Y);

    always_comb begin
        Y = I[S];
    end

endmodule : Multiplexer

module Mux2to1
    (input logic [7:0] I0,
     input logic [7:0] I1,
     input logic        S,
     output logic [7:0] Y);

        assign Y = (S) ? I1 : I0;

endmodule : Mux2to1

module MagComp
    (input logic [7:0] A,
     input logic [7:0] B,
     output logic AltB,
     output logic AeqB,
     output logic AgtB);

    always_comb begin
        AeqB = (A === B);
        AltB = (A < B);
        AgtB = (A > B);

    end

endmodule : MagComp

module Comparator
    (input logic [3:0] A,
     input logic [3:0] B,
     output logic AeqB);

    assign AeqB = (A === B);

endmodule : Comparator

module Adder
    (output logic cout,
     input logic cin,
     output logic [7:0] sum,
     input logic [7:0] A,
     input logic [7:0] B);

    assign {cout, sum} = A + B;

endmodule : Adder

module Subtracter
    (output logic bout,
     input logic bin,
     output logic [7:0] diff,
     input logic [7:0] A,
     input logic [7:0] B);

    assign {bout, diff} = A - B;

endmodule : Subtracter
