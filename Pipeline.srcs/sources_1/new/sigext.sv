`timescale 1ns / 1ps
module signExt(
    input [15:0] num,
    input extbit,
    output [31:0] signimm
    );
    assign #1 signimm = {{16{extbit}}, num};
endmodule
