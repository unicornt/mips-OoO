`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/18 16:16:17
// Design Name: 
// Module Name: mux4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux4 #(parameter W = 8) (
    input [2 : 0] s,
    input [W - 1: 0] d0, d1, d2, d3, d4,
    output [W - 1: 0] y
    );
    assign #1 y = s[2] ? (s[1] ? d4 : d3) : (s[1] ? d2 : (s[0] ? d1 : d0));
endmodule
