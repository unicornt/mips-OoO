`timescale 1ns / 1ps
module dmem(
    input clk, we1, we2,
    input [31:0] a1, wd1,
    input [31:0] a2, wd2,
    output logic [31:0] rd1, rd2
    );
    logic [31:0] RAM[63:0];
    reg [31:0] tmp;
    always_ff@(posedge clk) begin
        if(we1) RAM[a1[31:2]] <= wd1;
        if(we2) begin
        	tmp <= RAM[a2[31:2]];
        	RAM[a2[31:2]] <= wd2;
       	end
    end
    assign #1 rd1 = (we2 && a1 == a2) ? tmp : RAM[a1[31:2]];
    assign #1 rd2 = RAM[a2[31:2]];

endmodule
