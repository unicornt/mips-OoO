`timescale 1ns / 1ps
module regFiles(
    input clk, we1, we2,
    input [31:0] wd1, wd2,
    input [4:0] a1, a2, a3,
    input [4:0] b1, b2, b3,
    output [31:0] rd1, rd2,
    output [31:0] rd3, rd4
    );
    reg [31:0] r [31:0];

 
    initial begin
        for(int i = 0; i < 32; i++)
            r[i] = 0;
    end
    always_ff@(negedge clk) begin
        if(we1) r[a3] <= wd1;
        if(we2) r[b3] <= wd2;
    end
    
    assign #1 rd1 = r[a1];
    assign #1 rd2 = r[a2];
    assign #1 rd3 = r[b1];
    assign #1 rd4 = r[b2];
    
endmodule
