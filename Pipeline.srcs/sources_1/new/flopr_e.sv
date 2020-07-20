`timescale 1ns / 1ps
module flopre #(parameter W = 8)(
    input clk, reset, enable,
    input [W - 1 : 0] d,
    output reg [W - 1 : 0] y
    );
    always@(posedge clk) begin
        if(reset) y <= 0;
        else if(enable) y <= d;
    end
endmodule
