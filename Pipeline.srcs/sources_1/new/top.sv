`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/06 15:56:27
// Design Name: 
// Module Name: top
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

module top(
    input cpu_clk, reset,
    output [31:0] cpu_write_data, cpu_data_addr,
    output cpu_mem_write
    );
    wire [31:0] pc, instr, read_data, write_data;
    
    mips mips(.clk(cpu_clk), .reset(reset), .pc(pc), .instr(instr), .memwrite(cpu_mem_write), .aluout(cpu_data_addr), 
        .writedata(write_data), .readdata(read_data)); 
    imem imem(.a(pc[7:2]), .rd(instr));
    dmem dmem(.clk(cpu_clk), .we(cpu_mem_write), .a(cpu_data_addr), .wd(write_data), .rd(read_data));
    
    
endmodule
