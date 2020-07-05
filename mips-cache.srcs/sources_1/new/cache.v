`include "cache.vh"

/**
 * NOTE: The sum of TAG_WIDTH, SET_WIDTH and OFFSET_WIDTH should be 32
 *
 * TAG_WIDTH    : (t) tag bits
 * SET_WIDTH    : (s) set index bits, the number of sets is 2**SET_WIDTH
 * OFFSET_WIDTH : (b) block offset bits
 * LINES        : number of lines per set
 *
 * stall        : in order to synchronize instruction memory cache and data memory cache, you may need this so that two caches will write data at most once per instruction respectively.
 *
 * input_ready  : whether input data from processor are ready
 * addr         : cache read/write address from processor
 * write_data   : cache write data from processor
 * w_en         : cache write enable
 * hit          : whether cache hits
 * read_data    : data read from cache
 *
 * maddr        : memory address 
 * mwrite_data  : data written to memory
 * m_wen        : memory write enable
 * mread_data   : data read from memory
 */
module cache #(
	parameter TAG_WIDTH    = `CACHE_T,
		      SET_WIDTH    = `CACHE_S,
		      OFFSET_WIDTH = `CACHE_B,
		      LINES        = `CACHE_E
)(
	input         clk, reset, stall,

	// interface with CPU
	input input_ready,
	input [31:0]  addr, write_data,
	input         w_en,
	output        hit,
	output [31:0] read_data,

	// interface with memory
	output reg [31:0] maddr, mwrite_data,
	output        m_wen,
	input [31:0]  mread_data
);
    wire dirty;
    reg set_valid, set_dirty, offset_sel;
    reg [OFFSET_WIDTH - 3 :0] block_offset;
    
    wire [31:0] srd [3:0];
    wire [TAG_WIDTH - 1:0] srep_tag[3:0], rep_tag;
    wire [3:0] shit, sdirty;
	
    
	wire [OFFSET_WIDTH:0] ctls;
	wire [1:0] sid;
	wire rep_en, cache_clk;
	wire abnormal;
	
    reg [3:0] state;  //state of fst
    
	assign #1 cache_clk = clk & input_ready;
	
	assign sid = addr[5:4];
	assign ctls = {(w_en & (state == 4'h0)) | rep_en, set_valid, set_dirty, block_offset};
	wire [31:0] wd, ad;
	assign wd = offset_sel ? mread_data : write_data;
	assign ad = rep_en ? maddr : addr;
	
	generate
	   genvar i;
	   for(i = 0; i < 4; i = i + 1) begin : s
	       set i_s(cache_clk, reset, abnormal, i, ctls, ad, wd, 
	           srep_tag[i], shit[i], sdirty[i], srd[i]);
	   end
    endgenerate
    
    assign hit = shit[sid] & (state == 4'h0); //while replace the data in cache, the cpu should be stalled
    assign dirty = sdirty[sid];
    assign read_data = srd[sid];
    assign rep_tag = srep_tag[sid];
    assign abnormal = state != 4'h0;
//fst
    always@(posedge cache_clk, posedge reset) begin
        if(reset) begin
            state <= 4'h0;
        end
        //else if((~input_ready) || stall);
        else if(state == 4'h0) begin
            if(shit[sid]) state <= 4'h0;
            else begin
                if(dirty) state <= 4'h1;
                else state <= 4'h5;
            end
        end
        else if(state < 4'h8) state <= state + 1;
        else state <= 4'h0;
    end
    
    assign m_wen = (state < 4'h5) & (state > 4'h0); // write dirty data back to the mem
    assign rep_en = state > 4'h4; // load data from memory
    
    always@(*) begin
        if(state == 4'h0) begin //hit
//set_valid, set_dirty, block_offset, strategy_en, offset_sel
            if(w_en) begin // load data from CPU
                offset_sel <= 0;
                set_valid <= 1;
                set_dirty <= 1;
            end
            block_offset <= addr[3:2];
            //maddr <= addr;
        end
        else if(state > 4'h0 && state < 4'h5) begin // send data back to the memory
            block_offset <= state - 1;
            mwrite_data <= read_data;
            maddr <= {rep_tag, sid, block_offset, 2'b00};
        end
        else begin // load data from memory
            offset_sel <= 1;
            block_offset <= state - 5;
            maddr <= {addr[31:4], block_offset, 2'b00};
            set_valid <= 1;
            set_dirty <= 0;
        end
    end
    
endmodule
