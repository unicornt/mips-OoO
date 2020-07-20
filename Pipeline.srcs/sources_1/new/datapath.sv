`timescale 1ns / 1ps
module dataPath(
    input clk, reset,
    output [31:0] pcF_u, pcF_v,
    input [31:0] insF_u, insF_v,
    input regWriteD_u, regWriteD_v, aluSrcAD_u, aluSrcAD_v, aluSrcBD_u, aluSrcBD_v,
    input [2:0] aluCtD_u, aluCtD_v,
    input regDstD_u, regDstD_v, regDst2D_u, regDst2D_v, memWriteD_u, memWriteD_v, 
    input memToRegD_u, memToRegD_v, branchD_u, branchD_v, jumpD_u, jumpD_v, jrD_u, jrD_v,
    input [31:0] readDataM_u, readDataM_v,
    output [31:0] writeDataM_u, writeDataM_v, aluOutM_u, aluOutM_v,
    input pcSrcD_u, pcSrcD_v,
    output equalD_u, equalD_v, memWriteM_u, memWriteM_v,
    output [31:0] insD_u, insD_v,
    input boolD_u, boolD_v
    );
    wire jalD_u;
    wire regWriteE_u, memToRegE_u, memWriteE_u, branchE_u, aluSrcAE_u, 
          aluSrcBE_u, regDstE_u, regDst2E_u, jalE_u, boolE_u;
    wire regWriteM_u, memToRegM_u, branchM_u;
    wire regWriteW_u, memToRegW_u;
    
    wire stallF_u, stallD_u, flushD_u, flushE_u;

    wire [31:0] pcBranchD_u, pcJumpD_u;
    wire [2:0] forwardAE_u, forwardBE_u;
    wire [1:0] forwardAD_u, forwardBD_u;
    
    wire [31:0] esrcAD_u, esrcBD_u;
    wire [31:0] pcPlus4F_u, pcPlus4D_u;
    wire [31:0] pcAF_u, pcBF_u, pcNextF_u, labelSl2D_u;
    
    wire [4:0] writeRegE_u, writeRegM_u, writeRegW_u;
    ////
    ////
    wire jalD_v;
    wire regWriteE_v, memToRegE_v, memWriteE_v, branchE_v, aluSrcAE_v, aluSrcBE_v, 
          regDstE_v, regDst2E_v, jalE_v, boolE_v;
    wire regWriteM_v, memToRegM_v, branchM_v;
    wire regWriteW_v, memToRegW_v;
    
    wire stallF_v, stallD_v, flushD_v, flushE_v, flushE_v1;

    wire [31:0] pcBranchD_v, pcJumpD_v;
    wire [2:0] forwardAE_v, forwardBE_v;
    wire [1:0] forwardAD_v, forwardBD_v;
    
    wire [31:0] esrcAD_v, esrcBD_v;
    wire [31:0] pcPlus4F_v, pcPlus4D_v;
    wire [31:0] pcAF_v, pcBF_v, pcNextF_v1, pcNextF_v, labelSl2D_v;
    
    wire [4:0] writeRegE_v, writeRegM_v, writeRegW_v;
    wire ustallbrj_v;

//pc update u line
    assign flushD_u = (ustallbrj_v & ~ stallD_u) | (pcSrcD_u & !stallD_u) | jumpD_u | (jrD_u & ! stallD_u) | (pcSrcD_v & !stallD_v) | jumpD_v | (jrD_v & ! stallD_v);

    flopre #(32) pcupdate_u(clk, reset, !stallF_u, pcNextF_u, pcF_u);
//fetch u line
    mux #(32) jr_mux_u(jrD_u, pcNextF_v, esrcAD_u, pcAF_u);
    mux #(32) jump_mux_u(jumpD_u, pcAF_u, pcJumpD_u, pcBF_u); 
    mux #(32) pcSrc_mux_u(pcSrcD_u, pcBF_u, pcBranchD_u, pcNextF_u);
    
    assign #1 pcPlus4F_u = pcF_u + 4;
    floprec #(32) pcPlus4FD_u(clk, reset, !stallD_u, flushD_u, pcPlus4F_u, pcPlus4D_u);
    floprec #(32) insFD_u(clk, reset, !stallD_u, flushD_u, insF_u, insD_u); 
//pc update v line to u 
    assign pcF_v = pcF_u + 4;
    assign flushD_v = (ustallbrj_v & ~ stallD_v) | (pcSrcD_u & !stallD_u) | jumpD_u | (jrD_u & ! stallD_u) | (pcSrcD_v & !stallD_v) | jumpD_v | (jrD_v & ! stallD_v);
//fetch v line to v 
    mux #(32) jr_mux_v(jrD_v, pcPlus4F_v, esrcAD_v, pcAF_v);
    mux #(32) jump_mux_v(jumpD_v, pcAF_v, pcJumpD_v, pcBF_v); 
    mux #(32) pcSrc_mux_v(pcSrcD_v, pcBF_v, pcBranchD_v, pcNextF_v1);    
    mux #(32) pcflushv_mux_v(ustallbrj_v, pcNextF_v1, pcPlus4D_u, pcNextF_v);    
    
    assign #1 pcPlus4F_v = pcF_v + 4;
    floprec #(32) pcPlus4FD_v(clk, reset, !stallD_v, flushD_v, pcPlus4F_v, pcPlus4D_v);
    floprec #(32) insFD_v(clk, reset, !stallD_v, flushD_v, insF_v, insD_v); 

//decode
    wire [31:0] rd1D_u, rd2D_u, rd1E_u, rd2E_u;
    wire [4:0] a3D_u;
    wire [2:0] aluCtE_u;
    wire [31:0] signImmD_u, signImmSl2D_u, signImmE_u, zeroImmD_u, zeroImmE_u;
    wire [31:0] resultW_u, pcPlus4E_u;
    
    wire [31:0] rd1D_v, rd2D_v, rd1E_v, rd2E_v;
    wire [4:0] a3D_v;
    wire [2:0] aluCtE_v;
    wire [31:0] signImmD_v, signImmSl2D_v, signImmE_v, zeroImmD_v, zeroImmE_v;
    wire [31:0] resultW_v, pcPlus4E_v;
    
    regFiles rf(clk, regWriteW_u, regWriteW_v, resultW_u, resultW_v, insD_u[25:21], insD_u[20:16], 
                writeRegW_u, insD_v[25:21], insD_v[20:16], writeRegW_v, rd1D_u, rd2D_u, rd1D_v, rd2D_v);
    
    mux3 #(32) esrcAD_mux_u(forwardAD_u, rd1D_u, aluOutM_u, aluOutM_v, esrcAD_u);
    mux3 #(32) esrcAD_mux_v(forwardAD_v, rd1D_v, aluOutM_u, aluOutM_v, esrcAD_v);
    mux3 #(32) esrcBD_mux_u(forwardBD_u, rd2D_u, aluOutM_u, aluOutM_v, esrcBD_u);
    mux3 #(32) esrcBD_mux_v(forwardBD_v, rd2D_v, aluOutM_u, aluOutM_v, esrcBD_v);
    assign #1 equalD_u = esrcAD_u == esrcBD_u;
    assign #1 equalD_v = esrcAD_v == esrcBD_v;
    
    wire[4:0] writeRegPreD_u, writeRegD_u;
        
    wire [4:0] rsD_u, rtD_u, rdD_u, rsE_u, rtE_u, rdE_u;
    wire [4:0] rsD_v, rtD_v, rdD_v, rsE_v, rtE_v, rdE_v;
    
    mux #(5) writeRegPre_muxD_u(regDstD_u, rtD_u, rdD_u, writeRegPreD_u);
    mux #(5) writeReg_muxD_u(regDst2D_u, writeRegPreD_u, 5'b11111, writeRegD_u);
    
    wire [5:0]op, func;
    assign op = insD_u[31:26];
    assign func = insD_v[5:0];
    
    assign ustallbrj_v = (regWriteD_u && 
                         ((branchD_v && (writeRegD_u == insD_v[25:21] || writeRegD_u == insD_v[20:16])) ||
                         (jrD_v && (writeRegD_u == insD_v[25:21])))) || (op == 6'b100011);

    assign rsD_u = insD_u[25:21];
    assign rsD_v = insD_v[25:21];
    assign rtD_u = insD_u[20:16];
    assign rtD_v = insD_v[20:16];
    assign rdD_u = insD_u[15:11];
    assign rdD_v = insD_v[15:11];
    
    signExt se_u(insD_u[15:0], insD_u[15:15], signImmD_u);
    signExt se_v(insD_v[15:0], insD_v[15:15], signImmD_v);
    signExt ze_u(insD_u[15:0], 1'b0, zeroImmD_u);
    signExt ze_v(insD_v[15:0], 1'b0, zeroImmD_v);
    
    sl2 sigimm_u(signImmD_u, signImmSl2D_u);
    sl2 sigimm_v(signImmD_v, signImmSl2D_v);

    assign #1 pcBranchD_u = signImmSl2D_u + pcPlus4D_u;
    assign #1 pcBranchD_v = signImmSl2D_v + pcPlus4D_v;
    
    sl2 label_sl2_u({6'b000000, insD_u[25:0]}, labelSl2D_u);
    sl2 label_sl2_v({6'b000000, insD_v[25:0]}, labelSl2D_v);
    assign #1 pcJumpD_u = {pcPlus4F_u[31:28], labelSl2D_u[27:0]};
    assign #1 pcJumpD_v = {pcPlus4F_v[31:28], labelSl2D_v[27:0]};
    
    assign #1 jalD_u = regDst2D_u;
    assign #1 jalD_v = regDst2D_v;
    
    assign flushE_v = flushE_v1 | (pcSrcD_u & ~stallD_u) | ustallbrj_v | jrD_u | jumpD_u;
    
    floprc #(64) rdDE_u(clk, reset, flushE_u, {rd1D_u, rd2D_u}, {rd1E_u, rd2E_u});
    floprc #(64) rdDE_v(clk, reset, flushE_v, {rd1D_v, rd2D_v}, {rd1E_v, rd2E_v});
    floprc #(15) rDE_u(clk, reset, flushE_u, {rsD_u, rtD_u, rdD_u}, {rsE_u, rtE_u, rdE_u});
    floprc #(15) rDE_v(clk, reset, flushE_v, {rsD_v, rtD_v, rdD_v}, {rsE_v, rtE_v, rdE_v});
    floprc #(32) signImmDE_u(clk, reset, flushE_u, signImmD_u, signImmE_u);
    floprc #(32) signImmDE_v(clk, reset, flushE_v, signImmD_v, signImmE_v);
    floprc #(32) zeroImmDE_u(clk, reset, flushE_u, zeroImmD_u, zeroImmE_u);
    floprc #(32) zeroImmDE_v(clk, reset, flushE_v, zeroImmD_v, zeroImmE_v);
    floprc #(3) aluDE_u(clk, reset, flushE_u, aluCtD_u, aluCtE_u);
    floprc #(3) aluDE_v(clk, reset, flushE_v, aluCtD_v, aluCtE_v);
    floprc #(10) DE_u(clk, reset, flushE_u,
        {regWriteD_u, memToRegD_u, memWriteD_u, branchD_u, aluSrcAD_u,
         aluSrcBD_u, regDstD_u, regDst2D_u, jalD_u, boolD_u}, 
        {regWriteE_u, memToRegE_u, memWriteE_u, branchE_u, aluSrcAE_u,
         aluSrcBE_u, regDstE_u, regDst2E_u, jalE_u, boolE_u});
    floprc #(10) DE_v(clk, reset, flushE_v,
        {regWriteD_v, memToRegD_v, memWriteD_v, branchD_v, aluSrcAD_v,
         aluSrcBD_v, regDstD_v, regDst2D_v, jalD_v, boolD_v}, 
        {regWriteE_v, memToRegE_v, memWriteE_v, branchE_v, aluSrcAE_v,
         aluSrcBE_v, regDstE_v, regDst2E_v, jalE_v, boolE_v});
    floprc #(32) pcPlus4DE_u(clk, reset, flushE_u, pcPlus4D_u, pcPlus4E_u);
    floprc #(32) pcPlus4DE_v(clk, reset, flushE_v, pcPlus4D_v, pcPlus4E_v);
//execute
    wire [31:0] srcAPreE_u, srcBPreE_u, srcAE_u, srcBE_u, aluOutE_u;
    wire [31:0] srcAPreE_v, srcBPreE_v, srcAPreE_v1, srcBPreE_v1, srcAE_v, srcBE_v, aluOutE_v;
    wire [31:0] writeDataE_u, aluOut_u, immE_u;
    wire [31:0] writeDataE_v, aluOut_v, immE_v;

    wire [4:0] writeRegPreE_u;
    wire [4:0] writeRegPreE_v;
    
    
//  mux3 #(32) esrcAD_mux_u(forwardAD_u, rd1D_u, aluOutM_u, aluOutM_v, esrcAD_u);
    mux4 #(32) srcAPre_mux3_u(forwardAE_u, rd1E_u, resultW_u, aluOutM_u, resultW_v, aluOutM_v, srcAPreE_u);
    mux4 #(32) srcAPre_mux3_v(forwardAE_v, rd1E_v, resultW_u, aluOutM_u, resultW_v, aluOutM_v, srcAPreE_v1);
    mux4 #(32) srcBPre_mux3_u(forwardBE_u, rd2E_u, resultW_u, aluOutM_u, resultW_v, aluOutM_v, srcBPreE_u);
    mux4 #(32) srcBPre_mux3_v(forwardBE_v, rd2E_v, resultW_u, aluOutM_u, resultW_v, aluOutM_v, srcBPreE_v1);
    assign srcAPreE_v = ((rsE_v == writeRegE_u) && rsE_v && regWriteE_u) ? aluOutE_u : srcAPreE_v1;
    assign srcBPreE_v = ((rtE_v == writeRegE_u) && rtE_v && regWriteE_u) ? aluOutE_u : srcBPreE_v1;
    
    mux #(32) immE_mux_u(boolE_u, signImmE_u, zeroImmE_u, immE_u);
    mux #(32) immE_mux_v(boolE_v, signImmE_v, zeroImmE_v, immE_v);
    
    mux #(32) srcA_mux_u(aluSrcAE_u, srcAPreE_u, {{27{1'b0}}, signImmE_u[10:6]}, srcAE_u);
    mux #(32) srcA_mux_v(aluSrcAE_v, srcAPreE_v, {{27{1'b0}}, signImmE_v[10:6]}, srcAE_v);
    mux #(32) srcB_mux_u(aluSrcBE_u, srcBPreE_u, immE_u, srcBE_u);
    mux #(32) srcB_mux_v(aluSrcBE_v, srcBPreE_v, immE_v, srcBE_v);
    
    assign writeDataE_u = srcBPreE_u;
    assign writeDataE_v = srcBPreE_v;
    
    alu alu_u(srcAE_u, srcBE_u, aluCtE_u, aluOut_u);
    alu alu_v(srcAE_v, srcBE_v, aluCtE_v, aluOut_v);
    
    mux #(32) jalE_mux_u(jalE_u, aluOut_u, pcPlus4E_u, aluOutE_u);
    mux #(32) jalE_mux_v(jalE_v, aluOut_v, pcPlus4E_v, aluOutE_v);
    
    mux #(5) writeRegPre_mux_u(regDstE_u, rtE_u, rdE_u, writeRegPreE_u);
    mux #(5) writeRegPre_mux_v(regDstE_v, rtE_v, rdE_v, writeRegPreE_v);
    mux #(5) writeReg_mux_u(regDst2E_u, writeRegPreE_u, 5'b11111, writeRegE_u);
    mux #(5) writeReg_mux_v(regDst2E_v, writeRegPreE_v, 5'b11111, writeRegE_v);
    
    flopr #(32) aluOutEM_u(clk, reset, aluOutE_u, aluOutM_u);
    flopr #(32) aluOutEM_v(clk, reset, aluOutE_v, aluOutM_v);
    flopr #(32) writeDataEM_u(clk, reset, writeDataE_u, writeDataM_u);
    flopr #(32) writeDataEM_v(clk, reset, writeDataE_v, writeDataM_v);
    flopr #(5) writeRegEM_u(clk, reset, writeRegE_u, writeRegM_u);
    flopr #(5) writeRegEM_v(clk, reset, writeRegE_v, writeRegM_v);
    
    flopr #(4) EM_u(clk, reset, 
        {regWriteE_u, memToRegE_u, memWriteE_u, branchE_u}, 
        {regWriteM_u, memToRegM_u, memWriteM_u, branchM_u});
    flopr #(4) EM_v(clk, reset, 
        {regWriteE_v, memToRegE_v, memWriteE_v, branchE_v}, 
        {regWriteM_v, memToRegM_v, memWriteM_v, branchM_v});
//memory
    
    wire [31:0] aluOutW_u, readDataW_u;
    wire [31:0] aluOutW_v, readDataW_v;
    
    flopr #(32) readDataMW_u(clk, reset, readDataM_u, readDataW_u);
    flopr #(32) readDataMW_v(clk, reset, readDataM_v, readDataW_v);
    flopr #(32) aluOUtMW_u(clk, reset, aluOutM_u, aluOutW_u);
    flopr #(32) aluOUtMW_v(clk, reset, aluOutM_v, aluOutW_v);
    flopr #(5) writeRegMW_u(clk, reset, writeRegM_u, writeRegW_u);
    flopr #(5) writeRegMW_v(clk, reset, writeRegM_v, writeRegW_v);
    
    flopr #(2) MW_u(clk, reset, 
        {regWriteM_u, memToRegM_u}, 
        {regWriteW_u, memToRegW_u});
    flopr #(2) MW_v(clk, reset, 
        {regWriteM_v, memToRegM_v}, 
        {regWriteW_v, memToRegW_v});
//writeback -----------------------------------------------------------------------------------
    mux #(32) resultW_mux_u(memToRegW_u, aluOutW_u, readDataW_u, resultW_u);
    mux #(32) resultW_mux_v(memToRegW_v, aluOutW_v, readDataW_v, resultW_v);
    
//hazard
    hazard haz(rsD_u, rtD_u, rsE_u, rtE_u, writeRegE_u, writeRegM_u, writeRegW_u, 
        rsD_v, rtD_v, rsE_v, rtE_v, writeRegE_v, writeRegM_v, writeRegW_v, 
        regWriteE_u, regWriteM_u, regWriteW_u,
        regWriteE_v, regWriteM_v, regWriteW_v,
        memToRegE_u, memToRegM_u, memToRegW_u,
        memToRegE_v, memToRegM_v, memToRegW_v,
        branchD_u, jrD_u, 
        branchD_v, jrD_v, 
        forwardAD_u, forwardBD_u,
        forwardAD_v, forwardBD_v,
        forwardAE_u, forwardBE_u,
        forwardAE_v, forwardBE_v,
        stallF_u, stallD_u, flushE_u,
        stallF_v, stallD_v, flushE_v1);
    
endmodule
