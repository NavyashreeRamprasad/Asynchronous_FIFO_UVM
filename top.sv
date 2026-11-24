module top;
bit wr_clk,rd_clk;
bit rst;

intf pif(wr_clk,rd_clk,rst);

always #5 wr_clk = ~wr_clk;
always #2.5 rd_clk = ~rd_clk;

async_fifo dut(
    .wr_clk_i(wr_clk),
    .rd_clk_i(rd_clk),
    .rst_i(rst),
    .wr_en_i(pif.wr_en_i),
    .rd_en_i(pif.rd_en_i),
    .wdata_i(pif.wdata_i),
    .rdata_o(pif.rdata_o),
    .full_o(pif.full_o),
    .empty_o(pif.empty_o),
    .overflow_o(pif.overflow_o),
    .underflow_o(pif.underflow_o)
);

initial begin
  wr_clk = 0;
  rd_clk = 0;
  rst = 0;
  repeat (3) @(posedge wr_clk);
  rst = 1;
end

initial begin
uvm_config_db#(virtual intf)::set(null,"*","vif",pif);
run_test();
end

endmodule
