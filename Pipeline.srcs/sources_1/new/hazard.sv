`timescale 1ns / 1ps
module hazard(
    input [4:0] rsD_u, rtD_u, rsE_u, rtE_u, writeRegE_u, writeRegM_u, writeRegW_u, 
    input [4:0] rsD_v, rtD_v, rsE_v, rtE_v, writeRegE_v, writeRegM_v, writeRegW_v, 
    input regWriteE_u, regWriteM_u, regWriteW_u,
    input regWriteE_v, regWriteM_v, regWriteW_v,
    input memToRegE_u, memToRegM_u, memToRegW_u,
    input memToRegE_v, memToRegM_v, memToRegW_v,
    input branchD_u, jrD_u,
    input branchD_v, jrD_v,
    output logic [1:0] forwardAD_u, forwardBD_u,
    output logic [1:0] forwardAD_v, forwardBD_v,
    output reg [2:0] forwardAE_u, forwardBE_u,
    output reg [2:0] forwardAE_v, forwardBE_v,
    output stallF_u, stallD_u, flushE_u,
    output stallF_v, stallD_v, flushE_v
    );
    
    wire lwstall_u, bstall_u, jrstall_u;
    wire lwstall_v, bstall_v, jrstall_v;
    
    assign lwstall_u = ((((rsD_u == rtE_u) || (rtD_u == rtE_u)) && memToRegE_u)||
                       (((rsD_u == rtE_v) || (rtD_u == rtE_v)) && memToRegE_v)) ? 1 : 0;
    assign lwstall_v = ((((rsD_v == rtE_v) || (rtD_v == rtE_v)) && memToRegE_v)||
                       (((rsD_v == rtE_u) || (rtD_v == rtE_u)) && memToRegE_u)) ? 1 : 0;
    assign bstall_u = branchD_u & (
        (regWriteE_u & ((writeRegE_u == rsD_u || writeRegE_u == rtD_u) && writeRegE_u != 0))|  
        (regWriteE_v & ((writeRegE_v == rsD_u || writeRegE_v == rtD_u) && writeRegE_v != 0))|  
        (memToRegM_u & ((writeRegM_u == rsD_u || writeRegM_u == rtD_u) && writeRegM_u != 0))|
        (memToRegM_v & ((writeRegM_v == rsD_u || writeRegM_v == rtD_u) && writeRegM_v != 0)));
    assign bstall_v = branchD_v & (
        (regWriteE_v & ((writeRegE_v == rsD_v || writeRegE_v == rtD_v) && writeRegE_v != 0))|  
        (regWriteE_u & ((writeRegE_u == rsD_v || writeRegE_u == rtD_v) && writeRegE_u != 0))|  
        (memToRegM_v & ((writeRegM_v == rsD_v || writeRegM_v == rtD_v) && writeRegM_v != 0))|
        (memToRegM_u & ((writeRegM_u == rsD_v || writeRegM_u == rtD_v) && writeRegM_u != 0)));
    assign jrstall_u = jrD_u & ((regWriteE_u & (writeRegE_u == rsD_u && writeRegE_u !=0)) |
        (regWriteE_v & (writeRegE_v == rsD_u && writeRegE_v !=0))|
        (memToRegM_u & (writeRegM_u == rsD_u && writeRegM_u != 0))|
        (memToRegM_v & (writeRegM_v == rsD_u && writeRegM_v != 0)));
    assign jrstall_v = jrD_v & ((regWriteE_v & (writeRegE_v == rsD_v && writeRegE_v !=0)) |
        (regWriteE_u & (writeRegE_u == rsD_v && writeRegE_u !=0))|
        (memToRegM_v & (writeRegM_v == rsD_v && writeRegM_v != 0))|
        (memToRegM_u & (writeRegM_u == rsD_v && writeRegM_u  != 0)));
    assign #1 stallF_u = lwstall_u | bstall_u | jrstall_u | lwstall_v | bstall_v | jrstall_v;
    assign #1 stallF_v = lwstall_u | bstall_u | jrstall_u | lwstall_v | bstall_v | jrstall_v;
    assign #1 stallD_u = lwstall_u | bstall_u | jrstall_u | lwstall_v | bstall_v | jrstall_v;
    assign #1 stallD_v = lwstall_u | bstall_u | jrstall_u | lwstall_v | bstall_v | jrstall_v;
    assign #1 flushE_u = lwstall_u | bstall_u | jrstall_u | lwstall_v | bstall_v | jrstall_v; 
    assign #1 flushE_v = lwstall_u | bstall_u | jrstall_u | lwstall_v | bstall_v | jrstall_v; 
    
//    assign #1 forwardAD_u = (rsD_u != 0) && (rsD_u == writeRegM_u) && regWriteM_u ? 1 : 0;
//    assign #1 forwardAD_v = (rsD_v != 0) && (rsD_v == writeRegM_v) && regWriteM_v ? 1 : 0;
//    assign #1 forwardBD_u = (rtD_u != 0) && (rtD_u == writeRegM_u) && regWriteM_u ? 1 : 0;
//    assign #1 forwardBD_v = (rtD_v != 0) && (rtD_v == writeRegM_v) && regWriteM_v ? 1 : 0;
    always@(*) begin
        if(rsD_u != 0 && (rsD_u == writeRegM_v) && writeRegM_v) forwardAD_u <= 2'b10;
        else if(rsD_u !=0 && (rsD_u == writeRegM_u) && writeRegM_u) forwardAD_u <= 2'b01;
        else forwardAD_u <= 2'b00;
        if(rtD_u != 0 && (rtD_u == writeRegM_v) && writeRegM_v) forwardBD_u <= 2'b10;
        else if(rtD_u !=0 && (rtD_u == writeRegM_u) && writeRegM_u) forwardBD_u <= 2'b01;
        else forwardBD_u <= 2'b00;
        if(rsD_v != 0 && (rsD_v == writeRegM_v) && writeRegM_v) forwardAD_v <= 2'b10;
        else if(rsD_v !=0 && (rsD_v == writeRegM_u) && writeRegM_u) forwardAD_v <= 2'b01;
        else forwardAD_v <= 2'b00;
        if(rtD_v != 0 && (rtD_v == writeRegM_v) && writeRegM_v) forwardBD_v <= 2'b10;
        else if(rtD_v !=0 && (rtD_v == writeRegM_u) && writeRegM_u) forwardBD_v <= 2'b01;
        else forwardBD_v <= 2'b00;
    end
    always@(*) begin
        if((rsE_u != 0) && (rsE_u == writeRegM_v) && regWriteM_v) forwardAE_u <= 3'b110;
        else if((rsE_u != 0) && (rsE_u == writeRegM_u) && regWriteM_u) forwardAE_u <= 3'b010;
        else if((rsE_u != 0) && (rsE_u == writeRegW_v) && regWriteW_v) forwardAE_u <= 3'b101;
        else if((rsE_u != 0) && (rsE_u == writeRegW_u) && regWriteW_u) forwardAE_u <= 3'b001;
        else forwardAE_u <= 3'b000;
        if((rsE_v != 0) && (rsE_v == writeRegM_v) && regWriteM_v) forwardAE_v <= 3'b110;
        else if((rsE_v != 0) && (rsE_v == writeRegM_u) && regWriteM_u) forwardAE_v <= 3'b010;
        else if((rsE_v != 0) && (rsE_v == writeRegW_v) && regWriteW_v) forwardAE_v <= 3'b101;
        else if((rsE_v != 0) && (rsE_v == writeRegW_u) && regWriteW_u) forwardAE_v <= 3'b001;
        else forwardAE_v <= 3'b000;
    end
    
    always@(*) begin
        if((rtE_u != 0) && (rtE_u == writeRegM_v) && regWriteM_v) forwardBE_u <= 3'b110;
        else if((rtE_u != 0) && (rtE_u == writeRegM_u) && regWriteM_u) forwardBE_u <= 3'b010;
        else if((rtE_u != 0) && (rtE_u == writeRegW_v) && regWriteW_v) forwardBE_u <= 3'b101;
        else if((rtE_u != 0) && (rtE_u == writeRegW_u) && regWriteW_u) forwardBE_u <= 3'b001;
        else forwardBE_u <= 3'b000;
        if((rtE_v != 0) && (rtE_v == writeRegM_v) && regWriteM_v) forwardBE_v <= 3'b110;    
        else if((rtE_v != 0) && (rtE_v == writeRegM_u) && regWriteM_u) forwardBE_v <= 3'b010;
        else if((rtE_v != 0) && (rtE_v == writeRegW_v) && regWriteW_v) forwardBE_v <= 3'b101;    
        else if((rtE_v != 0) && (rtE_v == writeRegW_u) && regWriteW_u) forwardBE_v <= 3'b001;
        else forwardBE_v <= 3'b000;        
    end
    
    
endmodule
