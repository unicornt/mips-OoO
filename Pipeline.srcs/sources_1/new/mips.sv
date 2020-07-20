`timescale 1ns / 1ps
module mips(
    input clk, reset,
    output [31:0] pc_u, pc_v,
    input [31:0] instr_u, instr_v,//instrF
    output memwrite_u, memwrite_v,
    output [31:0] aluout_u, aluout_v, writedata_u, writedata_v, 
    input [31:0] readdata_u, readdata_v
    );
    
    wire [31:0] insD_u, insD_v;
    wire memToReg_u, memToReg_v;
    wire branch_u, branch_v, aluSrcA_u, aluSrcA_v, aluSrcB_u, aluSrcB_v, regWrite_u, regWrite_v, 
          regDst_u, regDst_v, regDst2_u, regDst2_v;
    wire [2:0] aluCt_u, aluCt_v;
    wire pcSrc_u, pcSrc_v, jump_u, jump_v, jr_u, jr_v, equalD_u, equalD_v, bool_u, bool_v;
    wire memWriteD_u, memWriteD_v;
    
    ctUnit cu_u(insD_u[31:26], insD_u[5:0], 
        memToReg_u, memWriteD_u, branch_u, 
        aluSrcA_u, aluSrcB_u, 
        regWrite_u, aluCt_u, regDst_u, regDst2_u, jump_u, pcSrc_u, equalD_u, jr_u, bool_u);
    ctUnit cu_v(insD_v[31:26], insD_v[5:0], 
        memToReg_v, memWriteD_v, branch_v, 
        aluSrcA_v, aluSrcB_v, 
        regWrite_v, aluCt_v, regDst_v, regDst2_v, jump_v, pcSrc_v, equalD_v, jr_v, bool_v);
    dataPath dp(clk, reset, pc_u, pc_v, instr_u, instr_v, 
        regWrite_u, regWrite_v, aluSrcA_u, aluSrcA_v, aluSrcB_u, aluSrcB_v, aluCt_u, aluCt_v, 
        regDst_u, regDst_v, regDst2_u, regDst2_v, memWriteD_u, memWriteD_v, memToReg_u, memToReg_v, 
        branch_u, branch_v, jump_u, jump_v, jr_u, jr_v, 
        readdata_u, readdata_v,
        writedata_u, writedata_v, aluout_u, aluout_v,
        pcSrc_u, pcSrc_v, equalD_u, equalD_v, memwrite_u, memwrite_v, 
        insD_u, insD_v, bool_u, bool_v);
    
endmodule
