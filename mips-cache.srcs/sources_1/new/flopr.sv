`timescale 1ns / 1ps
module flopr #(parameter W = 32)(
    input clk, reset,
    input [W - 1:0] d,
    output reg [W - 1:0] y
    );
    always@(posedge clk, posedge reset) 
        if(reset) y <= #1 0;
        else y <= #1 d;
endmodule

