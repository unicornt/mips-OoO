`timescale 1ns / 1ps
module floprc #(parameter W = 8) (
    input clk, reset, clear,
    input [W - 1: 0] d,
    output reg [W - 1: 0] y
    );
    always@(posedge clk, posedge reset) begin
        if(reset) y <= #1 0;
        else if(clear) y <= #1 0;
        else y <= #1 d;
    end
endmodule
