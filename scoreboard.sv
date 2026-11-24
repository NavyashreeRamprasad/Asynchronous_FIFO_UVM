`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp_wr #(wr_tx, scoreboard) wr_imp;
  uvm_analysis_imp_rd #(rd_tx, scoreboard) rd_imp;

  bit [`DATA_WIDTH-1:0] fifo_scb[$];
  bit [`DATA_WIDTH-1:0] rdata_temp;

  `NEW_COMP

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  endfunction

  function void write_wr(wr_tx tx);
  if (tx.overflow_o) 
      return; 
  if (tx.wr_en_i == 1)
      fifo_scb.push_front(tx.wdata_i);
  endfunction

  function void write_rd(rd_tx tx);
  if (tx.underflow_o)
      return; 
  if (tx.rd_en_i == 1) begin
      if (fifo_scb.size() == 0)
        `uvm_error("SCB", "Read with empty reference FIFO")
      else begin
        rdata_temp = fifo_scb.pop_back();
        common::scb_count++;
        if (rdata_temp == tx.rdata_o) common::matching++;
        else                          common::mismatch++;
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if (common::mismatch > 0 )
      `uvm_error("SCB", $sformatf("FAILED match=%0d mismatch=%0d", common::matching, common::mismatch))
    else
      `uvm_info("SCB", $sformatf("PASSED match=%0d mismatch=%0d", common::matching, common::mismatch), UVM_LOW)
  endfunction
endclass
