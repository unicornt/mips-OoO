`timescale 1ns / 1ps
module mips(
    input clk, reset,
    output [31:0] pc, 
    input [31:0] instr,//instrF
    output memwrite,
    output [31:0] aluout, writedata, 
    input [31:0] readdata,
    input ihit, dhit,
    output dcen
    );
    
    wire [31:0] insD;
    wire memToReg;
    wire branch, aluSrcA, aluSrcB, regWrite, regDst, regDst2;
    wire [2:0] aluCt;
    wire pcSrc, jump, jr, equalD, bool;
    wire memWriteD;
    wire dcenD;
    
    ctUnit cu(insD[31:26], insD[5:0], 
        memToReg, memWriteD, branch, 
        aluSrcA, aluSrcB, 
        regWrite, aluCt, regDst, regDst2, jump, pcSrc, equalD, jr, bool, dcenD);
    dataPath dp(clk, reset, pc, instr, 
        regWrite, aluSrcA, aluSrcB, aluCt, 
        regDst, regDst2, memWriteD, memToReg, branch, jump, jr, 
        readdata,
        writedata, aluout,
        pcSrc, equalD, memwrite, 
        insD, bool, dcenD, dcen);
     
    
endmodule
