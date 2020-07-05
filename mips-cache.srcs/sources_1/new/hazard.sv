`timescale 1ns / 1ps
module hazard(
    input [4:0] rsD, rtD, rsE, rtE, writeRegE, writeRegM, writeRegW, 
    input regWriteE, regWriteM, regWriteW,
    input memToRegE, memToRegM, memToRegW,
    input branchD, jrD,
    output forwardAD, forwardBD,
    output reg [1:0] forwardAE, forwardBE,
    output stallF, stallD, flushE
    );
    
    wire lwstall, bstall, jrstall;
    
    assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memToRegE ? 1 : 0;
    assign bstall = branchD & (
        (regWriteE & ((writeRegE == rsD || writeRegE == rtD) && writeRegE != 0))|  
        (memToRegM & ((writeRegM == rsD || writeRegM == rtD) && writeRegM != 0)));
    assign jrstall = jrD & ((regWriteE & (writeRegE == rsD && writeRegE !=0)) |
        (memToRegM & (writeRegM == rsD && writeRegM != 0)));
    assign #1 stallF = lwstall | bstall | jrstall;
    assign #1 stallD = lwstall | bstall | jrstall;
    assign #1 flushE = lwstall | bstall | jrstall; 
    
    assign #1 forwardAD = (rsD != 0) && (rsD == writeRegM) && regWriteM ? 1 : 0;
    assign #1 forwardBD = (rtD != 0) && (rtD == writeRegM) && regWriteM ? 1 : 0;
    
    always@(*) begin
        if((rsE != 0) && (rsE == writeRegM) && regWriteM) forwardAE <= 2'b10;
        else if((rsE != 0) && (rsE == writeRegW) && regWriteW) forwardAE <= 2'b01;
        else forwardAE <= 2'b00;
    end
    
    always@(*) begin
        if((rtE != 0) && (rtE == writeRegM) && regWriteM) forwardBE <= 2'b10;
        else if((rtE != 0) && (rtE == writeRegW) && regWriteW) forwardBE <= 2'b01;
        else forwardBE <= 2'b00;        
    end
    
    
endmodule
