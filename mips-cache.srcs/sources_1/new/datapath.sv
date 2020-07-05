`timescale 1ns / 1ps
`include "bpb.vh"
module dataPath #(
    parameter TAG_WIDTH = `BPB_T
) (
    input clk, reset,
    output [31:0] pcF,
    input [31:0] insF,
    input regWriteD, aluSrcAD, aluSrcBD,
    input [2:0] aluCtD,
    input regDstD, regDst2D, memWriteD, memToRegD, branchD, jumpD, jrD,
    input [31:0] readDataM,
    output [31:0] writeDataM, aluOutM,
    input pcSrcD,
    output equalD, memWriteM,
    output [31:0] insD,
    input boolD, dcenD,
    output dcenM
    );
    wire jalD;
    wire regWriteE, memToRegE, memWriteE, branchE, aluSrcAE, aluSrcBE, regDstE, regDst2E, jalE, boolE, dcenE;
    wire regWriteM, memToRegM, branchM;
    wire regWriteW, memToRegW;
    
    wire stallF, stallD, flushD, flushE;

    wire [31:0] pcBranchD, pcJumpD;
    wire [1:0] forwardAE, forwardBE;
    wire forwardAD, forwardBD;
    
    wire [31:0] esrcAD, esrcBD;
    wire [31:0] pcPlus4F, pcPlus4D;
    wire [31:0] pcAF, pcBF, pcCF, pcNextF, pcD, labelSl2D, pcRealD;
    
    wire [4:0] writeRegE, writeRegM, writeRegW;

//pc update
    wire pcSrcPredictedF, pcSrcPredictedD, pcSrcRealD;
    
    assign flushD = (pcSrcRealD & ~stallD) | jumpD | (jrD & ~stallD);
    flopre #(32) pcupdate(clk, reset, !stallF, pcNextF, pcF);
//fetch --------------------------------------------------------------------------------------- To be finished
    wire branchF;
    wire [31:0] signImmF, signImmSl2F, pcBranchF;
    
    mux #(32) pcAF_mux(jrD, pcPlus4F, esrcAD, pcAF);
    mux #(32) pcBF_mux(jumpD, pcAF, pcJumpD, pcBF);
    mux #(32) pcCF_mux(pcSrcPredictedF, pcBF, pcBranchF, pcCF);//
    mux #(32) pcNextF_mux(pcSrcRealD, pcCF, pcRealD, pcNextF);
    assign #1 pcBranchF = signImmSl2F + pcPlus4F;
    
    assign #1 branchF = insF[31:28] == 4'b0001;
    bpb bpb(clk, reset, pcF[TAG_WIDTH + 1:2], branchF, branchD, pcD[TAG_WIDTH + 1:2], pcSrcD, pcSrcPredictedF);
    
    signExt seF(insF[15:0], insF[15:15], signImmF);
    sl2 sl2F(signImmF, signImmSl2F);
    
    assign #1 pcPlus4F = pcF + 4;
    floprec #(32) pcPlus4FD(clk, reset, !stallD, flushD, pcPlus4F, pcPlus4D);
    floprec #(32) insFD(clk, reset, !stallD, flushD, insF, insD);
    floprec #(1) pcSrcPredictedFD(clk, reset, !stallD, flushD, pcSrcPredictedF, pcSrcPredictedD);
    floprec #(32) pcFD(clk, reset, !stallD, flushD, pcF, pcD);
//decode -------------------------------------------------------------------------------------- To be finished
    wire [31:0] rd1D, rd2D, rd1E, rd2E;
    wire [4:0] a3D;
    wire [2:0] aluCtE;
    wire [31:0] signImmD, signImmSl2D, signImmE, zeroImmD, zeroImmE;
    wire [31:0] resultW, pcPlus4E;
    
    regFiles rf(clk, regWriteW, resultW, insD[25:21], insD[20:16], writeRegW, rd1D, rd2D);
    
    mux #(32) esrcAD_mux(forwardAD, rd1D, aluOutM, esrcAD);
    mux #(32) esrcBD_mux(forwardBD, rd2D, aluOutM, esrcBD);
    assign #1 equalD = esrcAD == esrcBD;
    
    wire [4:0] rsD, rtD, rdD, rsE, rtE, rdE;
    assign rsD = insD[25:21];
    assign rtD = insD[20:16];
    assign rdD = insD[15:11];
    
    signExt seD(insD[15:0], insD[15:15], signImmD);
    signExt zeD(insD[15:0], 1'b0, zeroImmD);
    
    sl2 sl2D(signImmD, signImmSl2D);

    assign #1 pcBranchD = signImmSl2D + pcPlus4D;
    
    sl2 label_sl2({6'b000000, insD[25:0]}, labelSl2D);
    assign #1 pcJumpD = {pcPlus4F[31:28], labelSl2D[27:0]};
    
    assign #1 jalD = regDst2D;
    
    assign #1 pcSrcRealD = branchD & (pcSrcPredictedD != pcSrcD);
    mux #(32) pcBranchD_mux(pcSrcD, pcPlus4D, pcBranchD, pcRealD);
    
    
    floprc #(64) rdDE(clk, reset, flushE, {rd1D, rd2D}, {rd1E, rd2E});
    floprc #(15) rDE(clk, reset, flushE, {rsD, rtD, rdD}, {rsE, rtE, rdE});
    floprc #(32) signImmDE(clk, reset, flushE, signImmD, signImmE);
    floprc #(32) zeroImmDE(clk, reset, flushE, zeroImmD, zeroImmE);
    floprc #(3) aluDE(clk, reset, flushE, aluCtD, aluCtE);
    floprc #(10) DE(clk, reset, flushE,
        {regWriteD, memToRegD, memWriteD, branchD, aluSrcAD, aluSrcBD, regDstD, regDst2D, jalD, boolD}, 
        {regWriteE, memToRegE, memWriteE, branchE, aluSrcAE, aluSrcBE, regDstE, regDst2E, jalE, boolE});
    floprc #(32) pcPlus4DE(clk, reset, flushE, pcPlus4D, pcPlus4E);
    floprc #(1) dcenDE(clk, reset, flushE, dcenD, dcenE);
//execute ------------------------------------------------------------------------------------- To be finished
    wire [31:0] srcAPreE, srcBPreE, srcAE, srcBE, aluOutE;
    wire [31:0] writeDataE, aluOut, immE;

    wire [4:0] writeRegPreE;
    
    
    mux3 #(32) srcAPre_mux3(forwardAE, rd1E, resultW, aluOutM, srcAPreE);
    mux3 #(32) srcBPre_mux3(forwardBE, rd2E, resultW, aluOutM, srcBPreE);
    
    mux #(32) immE_mux(boolE, signImmE, zeroImmE, immE);
    
    mux #(32) srcA_mux(aluSrcAE, srcAPreE, {{27{1'b0}}, signImmE[10:6]}, srcAE);
    mux #(32) srcB_mux(aluSrcBE, srcBPreE, immE, srcBE);
    
    assign writeDataE = srcBPreE;
    
    alu alu(srcAE, srcBE, aluCtE, aluOut);
    
    mux #(32) jalE_mux(jalE, aluOut, pcPlus4E, aluOutE);
    
    mux #(5) writeRegPre_mux(regDstE, rtE, rdE, writeRegPreE);
    mux #(5) writeReg_mux(regDst2E, writeRegPreE, 5'b11111, writeRegE);
    
    flopr #(32) aluOutEM(clk, reset, aluOutE, aluOutM);
    flopr #(32) writeDataEM(clk, reset, writeDataE, writeDataM);
    flopr #(5) writeRegEM(clk, reset, writeRegE, writeRegM);
    
    flopr #(4) EM(clk, reset, 
        {regWriteE, memToRegE, memWriteE, branchE}, 
        {regWriteM, memToRegM, memWriteM, branchM});
    flopr #(1) dcenEM(clk, reset, dcenE, dcenM);
//memory -------------------------------------------------------------------------------------- OK
    
    wire [31:0] aluOutW, readDataW;
    
    flopr #(32) readDataMW(clk, reset, readDataM, readDataW);
    flopr #(32) aluOUtMW(clk, reset, aluOutM, aluOutW);
    flopr #(5) writeRegMW(clk, reset, writeRegM, writeRegW);
    
    flopr #(2) MW(clk, reset, 
        {regWriteM, memToRegM}, 
        {regWriteW, memToRegW});
//writeback -----------------------------------------------------------------------------------
    mux #(32) resultW_mux(memToRegW, aluOutW, readDataW, resultW);
    
//hazard
    hazard haz(rsD, rtD, rsE, rtE, writeRegE, writeRegM, writeRegW, 
        regWriteE, regWriteM, regWriteW,
        memToRegE, memToRegM, memToRegW,
        branchD, jrD, 
        forwardAD, forwardBD, forwardAE, forwardBE,
        stallF, stallD, flushE);
    
endmodule
