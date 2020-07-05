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
    wire stall;
    
    mips mips(.clk(cpu_clk), .reset(reset), .pc(pc), .instr(instr), .memwrite(cpu_mem_write), .aluout(cpu_data_addr), 
        .writedata(write_data), .readdata(read_data)); 

// dmem cache
    wire input_ready, hit, m_wen;
    wire [31:0] mread_data, maddr, mwrite_data;
    
    cache dcache(cpu_clk, reset, stall,
	// interface with CPU
	input_ready, cpu_data_addr, write_data, cpu_mem_write,//input
	hit, read_data,
	// interface with memory
	maddr, mwrite_data, m_wen,
	mread_data);
    cache icache(cpu_clk, reset, stall,
    1'b1, pc, cpu_write_data, cpu_mem_write,
    ihit, cpu_instr,
    pc, 32'b0, 1'b0, instr);
    
    dmem dmem(.clk(cpu_clk), .we(m_wen), .a(maddr), .wd(mwrite_data), .rd(mread_data));
    imem imem(.a(pc[7:2]), .rd(instr));
    
endmodule
