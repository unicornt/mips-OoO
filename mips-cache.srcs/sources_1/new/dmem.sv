`timescale 1ns / 1ps
module dmem(
    input clk, we,
    input [31:0] a, wd,
    output logic [31:0] rd
    );
    logic [31:0] RAM[127:0];
    always_ff@(negedge clk)
        if(we) RAM[a[31:2]] <= wd;
    assign #1 rd = RAM[a[31:2]];
endmodule
