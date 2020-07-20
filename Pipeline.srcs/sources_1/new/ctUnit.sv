`timescale 1ns / 1ps
module ctUnit(
    input [5:0] op, fun, 
    output memToReg, memWrite,
    output branch, 
    output logic aluSrcA, aluSrcB, regWrite, 
    output logic [2:0] aluCt,
    output logic regDst,
    output regDst2,
    output jump,
    output pcSrc,
    input equalD,
    output jr, bool
    );
    assign #1 memToReg = op == 6'b100011;
    assign #1 memWrite = op == 6'b101011;
    assign #1 regDst2 = op == 6'b000011;
    assign #1 branch = op[5:2] == 4'b0001;
    assign #1 jump = (op[5:1] == 6'b00001);
    assign #1 jr = (op == 6'b000000) && (fun == 6'b001000);
    assign #1 pcSrc = (op[5:2] == 4'b0001) & (equalD ^ op[0]); 
    assign #1 bool = op[5:2] == 4'b0011;
    always@(*) begin
        casez(op)
            6'b000000: begin//R type
                regDst <= #1 1;
                casez(fun) 
                    6'b0000??: begin
                        aluSrcA <= #1 1;
                        aluSrcB <= #1 0;
                        regWrite <= #1 1;
                        casez(fun) //sll srl sra
                            6'b000000: aluCt <= #1 3'b011; //sll rd, rt, shamt
                            6'b000010: aluCt <= #1 3'b100; //srl rd, rt, shamt
                            6'b000011: aluCt <= #1 3'b101; //sra rd, rt, shamt
                        endcase
                    end
                    6'b001000: begin //jr rs
                        aluSrcA <= #1 0;
                        aluSrcB <= #1 0;
                        regWrite <= #1 0;
                        aluCt <= #1 3'b010; //rs add 0
                    end
                    6'b1?????: begin
                        aluSrcA <= #1 0;
                        aluSrcB <= #1 0;
                        regWrite <= #1 1;
                        casez(fun) //add sub and or slt
                            6'b100000: aluCt <= #1 3'b010; //add
                            6'b100010: aluCt <= #1 3'b110; //sub
                            6'b100100: aluCt <= #1 3'b000; //and
                            6'b100101: aluCt <= #1 3'b001; //or
                            6'b101010: aluCt <= #1 3'b111; //slt
                        endcase
                    end
                endcase
            end
            6'b00001?: begin //j(0)/jal(1) label
                aluSrcA <= #1 1'bx;
                aluSrcB <= #1 1'bx;
                regDst <= #1 1'bx;
                regWrite <= #1 op[0];
                aluCt = #1 3'bxxx;
            end
            6'b0001??: begin //beq(00)/bne(01) rs, rt, label
                aluSrcA <= #1 0;
                aluSrcB <= #1 0;
                regDst <= #1 1'bx;
                regWrite <= #1 0;
                aluCt <= #1 3'b110;
            end
            6'b001???: begin //I type
                aluSrcA <= #1 0;
                aluSrcB <= #1 1;
                regDst <= #1 0; 
                regWrite <= #1 1;
                casez(op[2:0])
                    3'b000: aluCt <= #1 3'b010;//addi rt, rs, imm
                    3'b010: aluCt <= #1 3'b111;//slti rt, rs, imm
                    3'b100: aluCt <= #1 3'b000; //andi rt, rs, imm
                    3'b101: aluCt <= #1 3'b001;//ori rt, rs, imm
                endcase
            end
            6'b100011: begin//lw rt, imm(rs)
                aluSrcA <= #1 0;
                aluSrcB <= #1 1;
                regDst <= #1 0;
                regWrite <= #1 1;
                aluCt <= #1 3'b010;
            end
            6'b101011: begin//sw rt, imm(rs)
                aluSrcA <= #1 0;
                aluSrcB <= #1 1;
                regDst <= #1 1'bx;
                regWrite <= #1 0;
                aluCt <= #1 3'b010;
            end
        endcase
    end
    
endmodule
