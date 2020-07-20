`define PATH_PREFIX "../../../../"
`define NAME "benchtest/"

module cpu_tb();

logic mem_write1, mem_write2, cpu_clk, finish, cpu_mem_write1, cpu_mem_write2;
wire [31:0] pc1, pc2, instr1, instr2, read_data1, read_data2, write_data1, write_data2, cpu_data_addr1, cpu_data_addr2;

reg clk, reset;
reg [31:0] tb_data_addr, tb_dmem_data, pc_finished;

//parameter ISIZE = 32, DSIZE = 32;
string summary;
// test variables
integer fans, frun, fimem, fdmem, error_count, imem_counter, dmem_counter;
integer cycle = 0, instr_count = 0;

`ifdef checking
    integer error_test = 0;
`endif

// module instances
mips mips(.clk(cpu_clk), .reset(reset), .pc_u(pc1), .pc_v(pc2), .instr_u(instr1), .instr_v(instr2), .memwrite_u(cpu_mem_write1),
          .memwrite_v(cpu_mem_write2), .aluout_u(cpu_data_addr1), .aluout_v(cpu_data_addr2), .writedata_u(write_data1), .writedata_v(write_data2), .readdata_u(read_data1), .readdata_v(read_data2));
imem imem(.a(pc1[7:2]), .rd1(instr1), .b(pc2[7:2]), .rd2(instr2));
dmem dmem(.clk(clk), .we1(mem_write1), .we2(mem_write2), .a1(cpu_data_addr1), .wd1(write_data1), .a2(cpu_data_addr2), .wd2(write_data2), .rd1(read_data1), .rd2(read_data2));

// clock and reset
always #20 clk = ~clk;

assign finish = ~|((pc1 ^ pc_finished) && (pc2 ^ pc_finished));
always_ff @( posedge clk, negedge clk ) begin 
    cpu_clk <= clk & ~finish;
end
assign mem_write1 = (cpu_mem_write1 & ~finish);
assign mem_write2 = (cpu_mem_write2 & ~finish);

task judge(
    input integer pc,
    input integer frun,
    input integer cycle,
    input string out
);
    
    string ans;
    ans = "";
    //$display("%x %0s", pc, out);
    $fscanf(frun, "%s\n", ans);
    if (ans != out)
        begin
            `ifdef checking
		      error_count = error_count + 1;
		    `else
		      begin
		          $display("[Error] PC: 0x%x Cycle: %0d\tExpected: %0s, Got: %0s", pc, cycle, ans, out);
		          $stop;
              end
		    `endif
        end
endtask

// judge memory
task judge_memory(
	input integer fans
);
    $display("========== In memory judge ==========");
    begin
        wait(finish == 1'b1);
        while(!$feof(fans))
            begin
                tb_dmem_data = 32'h0000_0000;
                $fscanf(fans, "%h", tb_dmem_data);
                //$display("%x", tb_data_addr);
                if (tb_dmem_data != dmem.RAM[tb_data_addr/4])
                    begin
                        $display("FAILURE: dmem 0x%0h expect 0x%0h but get 0x%0h",
                            tb_data_addr, tb_dmem_data, dmem.RAM[tb_data_addr/4]);
                        error_count = error_count + 1;
                    end
                tb_data_addr = tb_data_addr + 4;
            end
        `ifndef checking
            $display("successfully pass memory judge");
        `endif
    end
endtask

// check runtime
task runtime_checker(
    input integer frun
);
    string out;
    $display("========== In runtime checker ==========");
    while(!$feof(frun))
        begin@(negedge clk)
            cycle = cycle + 1;
            
            if (~mips.dp.flushD_u & ~mips.dp.haz.stallD_u)
                instr_count = instr_count + 1;
            if (~mips.dp.flushD_v & ~mips.dp.haz.stallD_v)
                instr_count = instr_count + 1;
            if (mem_write1)
                begin
                    $sformat(out, "[0x%x]=0x%x", cpu_data_addr1, write_data1);
//                    $display("out: %0s", out);
                    judge(pc1, frun, cycle, out);
                end
            if (mem_write2)
                begin
                    $sformat(out, "[0x%x]=0x%x", cpu_data_addr2, write_data2);
//                    $display("out: %0s", out);
                    judge(pc2, frun, cycle, out);
                end
        end
    `ifndef checking
        $display("successfully pass runtime checker");
    `endif
endtask

initial 
begin
	// ddl to finish simulation
	#1000000 $display("FAILURE: Testbench Failed to finish before ddl!");
	error_count = error_count + 1;
	$finish;
end

// init memory
task init(input string name);
    imem.RAM = '{ default: '0 };
    dmem.RAM = '{ default: '0 };
    fimem = $fopen({ `PATH_PREFIX, `NAME, name, "/", name, ".mem"}, "r");
    fdmem = $fopen({ `PATH_PREFIX, `NAME, name, "/", name, ".data"}, "r");
    if (fdmem != 0) 
        begin
            dmem_counter = 0;
                while(!$feof(fdmem))
                    begin
                        dmem.RAM[dmem_counter] = 32'h0000_0000;
                        $fscanf(fdmem, "%x", dmem.RAM[dmem_counter]);
                        dmem_counter = dmem_counter + 1;
                    end
            $fclose(fdmem);
        end
    imem_counter = 0;
    $display("========== In init ==========");
    while(!$feof(fimem))
        begin
            imem.RAM[imem_counter] = 32'h0000_0000;
            $fscanf(fimem, "%x", imem.RAM[imem_counter]);
            imem_counter = imem_counter + 1;
        end
    $display("%0d instructions in total", imem_counter);
    $fclose(fimem);
endtask

task grader(input string name);
    $display("========== Test: %0s ==========", name);
    begin
        reset = 1'b1;
        tb_dmem_data = 32'h0000_0000;
        tb_data_addr = 32'h0000_0000;
        pc_finished = 32'hffff_ffff;
        #50 reset = 1'b0;   
    end
    init(name);
    fans = $fopen({ `PATH_PREFIX, `NAME, name, "/", name, ".ans"}, "r");
    $fscanf(fans, "%h", pc_finished);
    frun = $fopen({ `PATH_PREFIX, `NAME, name, "/", name, ".run"}, "r");
    error_count = 0;
    runtime_checker(frun);
    $fclose(frun);
	judge_memory(fans);
    $fclose(fans);
    if (error_count != 0)
        begin
            $display("Find %0d error(s)", error_count);
            `ifdef checking
                error_test = error_test + 1;
                $display("[ERROR] %0s\n", name);
            `endif
        end
    else
        $display("[OK] %0s\n", name);
endtask

// start test
initial
begin
    clk = 1'b0;
    grader("ad hoc");
    grader("factorial");
    grader("bubble sort");
    grader("gcd");
    grader("quick multiply");
    grader("bisection");
    grader("en & clear");//fail
    grader("i-type");//right
    grader("mutual recursion");//right
    grader("testjr");//wrong
    grader("random write");
	$display("[Done]\n");
    $display("CPI = %0f\n", $bitstoreal(cycle) / $bitstoreal(instr_count));
	`ifdef checking
	   $display("Error test: %0d\n", error_test);
	`endif
    $finish;
end

endmodule
