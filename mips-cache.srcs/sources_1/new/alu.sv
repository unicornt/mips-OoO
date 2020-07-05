`timescale 1ns / 1ps
module alu(
    input [31:0] srcA, srcB,
    input [2:0] aluCt,
    output logic [31:0] res
    );
    
    wire [31:0] tmp;
    assign tmp = srcA - srcB;
    always@(*) begin
        casez(aluCt)
            3'b000: res <= srcA & srcB;
            3'b001: res <= srcA | srcB;
            3'b010: res <= srcA + srcB;
            3'b011: res <= srcB << srcA;
            3'b100: res <= srcB >> srcA;
            3'b101: res <= srcB >>> srcA;
            3'b110: res <= srcA - srcB;
//            3'b111: res <= srcA < srcB ? 1 : 0;
            3'b111: begin
                if(srcA[31:31] == srcB[31:31]) begin
                    if(tmp[31:31] == 1'b1) res <= 1;
                    else res <= 0;
                end
                else if(srcA[31:31] == 1'b1) res <= 1;
                else res <= 0;
            end
        endcase
    end
endmodule