`define DEPTH 16 
`define DATA_WIDTH  32
`define PTR_WIDTH  $clog2(`DEPTH) 
`include "async_fifo.v"
module tb;
	reg wr_clk_i,rd_clk_i,rst_i;
	reg wr_en_i,rd_en_i;
	reg [`DATA_WIDTH-1:0] wdata_i;
	wire [`DATA_WIDTH-1:0] rdata_o;
	wire full_o,empty_o,overflow_o,underflow_o;
	integer i,j;
	integer wr_delay, rd_delay; 
	reg [8*10:0] testcase;
	
async_fifo dut(wr_clk_i,rd_clk_i,rst_i,wr_en_i,rd_en_i,wdata_i,rdata_o,full_o,empty_o,overflow_o,underflow_o);

	always #5 wr_clk_i = ~wr_clk_i;
	always #7 rd_clk_i = ~rd_clk_i;

	task reset();
	begin
		wr_en_i = 0;
		rd_en_i = 0;
		wdata_i = 0;
		rst_i = 0;
		repeat(2) @(posedge wr_clk_i);
		rst_i = 1;
	end
	endtask


	task write(input integer num);
	begin
		for(i = 0; i<num;i=i+1) begin
			@(posedge wr_clk_i);
			wdata_i = $random();
			wr_en_i = 1;
			@(posedge wr_clk_i);
			wdata_i = 0;
			wr_en_i = 0;
		end
	end
	endtask

	task read(input integer num);
	begin
		for(j = 0; j<num;j=j+1) begin
			@(posedge rd_clk_i);
			rd_en_i = 1;
			@(posedge rd_clk_i);
			rd_en_i = 0;
		end
	end
	endtask
initial begin
	rd_clk_i = 0;
	wr_clk_i = 0;
	reset();

	if(!$value$plusargs("testcase=%0s",testcase))
		$display("FAILED TO RETRIVE TESTCASE FROM USER");

		$display("testcase = %s",testcase);

	case(testcase)
	//testcase1:	reset -> PASSED
	"RESET": begin reset(); end
	//testcase2:	full  -> PASSED
	"FULL": begin write(`DEPTH); end	
	//testcase3:	empty	-> PASSED
	"EMPTY": begin write(`DEPTH); 
				   read(`DEPTH); end
	//testcase4:	overflow -> PASSED
	"OVERFLOW": begin write(`DEPTH+1);end 
	//testcase5:	underflow	-> PASSED
	"UNDERFLOW": begin
							write(`DEPTH);	
							read(`DEPTH + 1);
				 end
	//testcase6:	concurrent write and read	-> PASSED
	"CONCURRENT": begin fork
					begin
					repeat(10) begin
						write(1); //write task 
						wr_delay = $urandom_range(0,10);
						#wr_delay;
					end
					end
					begin
					repeat(11) begin
						wait(empty_o == 0);
						read(1); //underflow 
						rd_delay = $urandom_range(0,10);
						#rd_delay;
					end
					end
					join
				end
				default: $display("NO TESTCASE PASSED");
	endcase

end
initial begin
	#8000 $finish();
end
endmodule
