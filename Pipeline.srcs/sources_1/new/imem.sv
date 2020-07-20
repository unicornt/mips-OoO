`timescale 1ns / 1ps
module imem(
    input [5:0] a, 
    output [31:0] rd1,
    input [5:0] b,
    output [31:0] rd2
    );
    logic [31:0] RAM[63:0];
//    initial
//        begin
//            $readmemh("memfile.dat", RAM);
//        end
    assign #1 rd1 = RAM[a];
    assign #1 rd2 = RAM[b];
endmodule
