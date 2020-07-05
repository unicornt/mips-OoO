`timescale 1ns / 1ps
module regFiles(
    input clk, we,
    input [31:0] wd,
    input [4:0] a1, a2, a3,
    output [31:0] rd1, rd2
    );
    reg [31:0] r [31:0];

    initial r[0] = 0;
    always@(negedge clk) begin
        if(we) r[a3] <= wd;
    end
    
    assign #1 rd1 = r[a1];
    assign #1 rd2 = r[a2];
    
endmodule
