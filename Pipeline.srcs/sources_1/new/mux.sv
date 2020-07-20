`timescale 1ns / 1ps
module mux #(parameter W = 8) (
    input s,
    input [W - 1 : 0] d0, d1,
    output [W - 1 : 0] y
    );
    assign #1 y = s ? d1 : d0;
endmodule
