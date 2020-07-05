`include "bpb.vh"

/**
 * ENTRIES          : number of entries in the branch predictor buffer
 * TAG_WIDTH        : index bits
 * instr_adr        : if this address has been recorded, then CPU can go as the BPB directs
 * isbranch         : in order to register the branch when first meeted
 * real_taken       : whether this branch should be taken according to the semantics of the instructions
 * real_adr         : where should this branch jumps to
 * predict_taken    : whether this branch should be taken according to the prediction of our BPB
 * predict_adr      : where should this branch jumps to if it's taken
 */
module bpb #(
    parameter ENTRIES = `BPB_E,
    parameter TAG_WIDTH = `BPB_T
) (
    input                   clk, reset,// stall, flush,
    input [TAG_WIDTH-1:0]   instr_adr,
    
    input                   isbranch,
    // reality
    input                   need_update,
    input [TAG_WIDTH-1:0]   update_adr,
    input                   real_taken,
    //input [31:0]            real_adr,
    // prediction
    output                  predict_taken
    //output reg [31:0]       predict_adr
);
//    reg state [ENTRIES - 1:0];
    reg [1:0] state [ENTRIES - 1:0];
    reg [TAG_WIDTH - 1:0] tag[ENTRIES - 1:0];
    reg [ENTRIES - 1:0] is_taken;
    reg [ENTRIES - 1:0] hit;
    genvar i;
    generate
        for(i = 0; i < ENTRIES; i = i + 1) begin
            always@(negedge clk, posedge reset) begin
                if(reset) begin
                    tag[i] <= 0;
                    state[i] <= 0;
                    is_taken[i] <= 0;
                end
                else begin
                    if(~isbranch) hit[i] <= 0;
                    else if(tag[i] == instr_adr) begin
                        is_taken[i] <= state[i];
                        hit[i] <= 1;
                    end
                    else begin
                        is_taken[i] <= 0;
                        hit[i] <= 0;
                    end
                end
            end
            always@(posedge clk, posedge reset) begin
                if(reset);
                else if(need_update) begin
                    if(tag[i] == update_adr) begin
                        if(real_taken) begin
                            if(state[i] < 2'h3) state[i] <= state[i] + 1;
//                            if(~state[i]) state[i] <= state[i] + 1;
                        end
                        else if(state[i] > 2'h0) state[i] <= state[i] - 1;
//                        else if(state[i]) state[i] <= state[i] - 1;
                    end
                end
            end
        end
    endgenerate
    
    wire thit;
    assign predict_taken = isbranch & (| is_taken);
    assign thit = | hit;
        
    reg [31:0] cnt;
    always@(posedge isbranch, posedge reset) begin
        if(reset) cnt <= 0;
        else begin
            if(cnt < ENTRIES - 1) cnt <= cnt + 1;
            else cnt <= 0;
        end
    end
    
    always@(negedge clk) begin
        if(~thit & isbranch) begin
            tag[cnt] <= instr_adr;
            state[cnt] <= 2'b01;
//            state[cnt] <= 0;
        end
    end
    
endmodule