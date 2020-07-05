`timescale 1ns / 1ps
module mux3 #(parameter W = 8) (
    input [1 : 0] s,
    input [W - 1: 0] d0, d1, d2,
    output [W - 1: 0] y
    );
    assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule
