`timescale 1ns / 1ps
module sl2(
    input [31:0] p,
    output [31:0] q
    );
    assign #1 q = {p[29:0], 2'b00};

endmodule
