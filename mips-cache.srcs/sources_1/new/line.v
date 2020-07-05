`include "cache.vh"
/**
 * w_en: write enable
 */
module line #(
	parameter TAG_WIDTH    = `CACHE_T,
		      OFFSET_WIDTH = `CACHE_B
)(
	input                        clk, reset,
	input  [OFFSET_WIDTH - 3:0]  offset,
	input                        w_en, set_valid, set_dirty,
	input  [TAG_WIDTH - 1:0]     set_tag,
	input  [31:0]                write_data,
	output reg                   valid,
	output reg                   dirty,
	output reg [TAG_WIDTH - 1:0] tag,
	output [31:0]                read_data
);
    reg [31:0] word [3:0];
    
    always@(negedge clk, posedge reset) begin
        if(reset) begin
            valid <= 0;
            dirty <= 0;
        end
        else if(w_en) begin
            valid <= set_valid;
            dirty <= set_dirty;
            tag <= set_tag;
            word[offset] <= write_data;
        end
    end
    
    assign read_data = valid ? word[offset] : 32'bx;

endmodule
