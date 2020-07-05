`timescale 1ns / 1ps
module imem(
    input [5:0] a, 
    output [31:0] rd
    );
    logic [31:0] RAM[63:0];
//    initial
//        begin
//            $readmemh("memfile.dat", RAM);
//        end
    assign #1 rd = RAM[a];
endmodule
