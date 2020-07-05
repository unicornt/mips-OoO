`include "cache.vh"
/**
 * ctls       : control signals from cache_controller
 * addr       : cache read/write address from processor
 * write_data : cache write data from processor
 * mread_data : data read from memory
 * 
 * hit        : whether cache set hits
 * dirty      : from the cache line selected by addr (cache line's tag is equal to addr's tag)
 */
module set #(
	parameter TAG_WIDTH    = `CACHE_T,
		      OFFSET_WIDTH = `CACHE_B,
		      LINES        = `CACHE_E
)(
	input                         clk, reset, rep_en,
	input [1:0]                   sid,
	input  [4 + OFFSET_WIDTH - 3:0] ctls,
	input  [31:0]                 addr, wd,
	output reg [TAG_WIDTH - 1:0]  rep_tag,
	output                        hit,
	output reg                    dirty,
	output reg [31:0]             read_data
);

wire w_en, set_valid, set_dirty, used;
wire [OFFSET_WIDTH - 3:0] offset;

// control signals will be assigned to the target line instance.
    assign {w_en, set_valid, set_dirty, offset} = ctls;

    wire [3:0] valid, ldirty, lhit;
    reg [3:0] rep; // which line to replace
    
    wire [31:0] readd [3:0];
    wire [TAG_WIDTH - 1:0] ltag [3:0];
    wire [TAG_WIDTH - 1:0] set_tag;
    
    assign used = sid == addr[5:4];

    assign hit = |lhit;
    assign set_tag = addr[31:6];
    
    reg [15:0] cnt [3:0];
// which line to write
    always@(*) begin
        if(rep_en);
        else if(~valid[0]) rep <= 4'b0001;
        else if(~valid[1]) rep <= 4'b0010;
        else if(~valid[2]) rep <= 4'b0100;
        else if(~valid[3]) rep <= 4'b1000;
        else if(cnt[0] > cnt[1] && cnt[0] > cnt[2] && cnt[0] > cnt[3]) rep <= 4'b0001;
        else if(cnt[1] > cnt[0] && cnt[1] > cnt[2] && cnt[1] > cnt[3]) rep <= 4'b0010;
        else if(cnt[2] > cnt[0] && cnt[2] > cnt[1] && cnt[2] > cnt[3]) rep <= 4'b0100;
        else if(cnt[3] > cnt[0] && cnt[3] > cnt[1] && cnt[3] > cnt[2]) rep <= 4'b1000;
        else rep <= 4'b0001;//
    end
//counter
    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin
            always@(negedge rep_en, posedge reset) begin
                if(reset) cnt[i] <= 0;
//                else if(rep_en);
                else if(~used);
                else if(lhit[i]) cnt[i] <= 0;
                else cnt[i] <= cnt[i] + 1;
            end
        end
    endgenerate
//line 
    generate
        for (i = 0; i < 4; i = i + 1) begin : l
            line i_l(clk, reset, offset, used & (lhit[i] | (rep[i] & rep_en)) & w_en, 
                set_valid, set_dirty, set_tag, wd, valid[i], ldirty[i], ltag[i], readd[i]); 
        end
    endgenerate
    
    generate
        for(i = 0; i < 4; i = i + 1) begin
            assign lhit[i] = (ltag[i] == addr[31:6]) & valid[i];
        end
    endgenerate
    
    always@(*) begin
        if(lhit[0]) begin
            read_data <= readd[0];
            rep_tag <= ltag[0];
            dirty <= ldirty[0];
        end
        else if(lhit[1]) begin
            read_data <= readd[1];
            rep_tag <= ltag[1];
            dirty <= ldirty[1];
        end
        else if(lhit[2]) begin
            read_data <= readd[2];
            rep_tag <= ltag[2];
            dirty <= ldirty[2];
        end
        else if(lhit[3]) begin
            read_data <= readd[3];
            rep_tag <= ltag[3];
            dirty <= ldirty[3];
        end
        else if(rep[0]) begin
            read_data <= readd[0];
            rep_tag <= ltag[0];
            dirty <= ldirty[0];
        end
        else if(rep[1]) begin
            read_data <= readd[1];
            rep_tag <= ltag[1];
            dirty <= ldirty[1];
        end
        else if(rep[2]) begin
            read_data <= readd[2];
            rep_tag <= ltag[2];
            dirty <= ldirty[2];
        end
        else if(rep[3]) begin
            read_data <= readd[3];
            rep_tag <= ltag[3];
            dirty <= ldirty[3];
        end
        
    end

endmodule
