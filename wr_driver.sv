class wr_driver extends uvm_driver#(wr_tx);
virtual intf vif;
`uvm_component_utils(wr_driver)
`NEW_COMP

function void build_phase(uvm_phase phase);
super.build_phase(phase);
uvm_config_db#(virtual intf) :: get(this,"","vif",vif);
endfunction

task run_phase(uvm_phase phase);
  vif.wr_en_i = 0;
  vif.wdata_i = 0;
wait (vif.rst_i === 1'b1);
forever begin
seq_item_port.get_next_item(req);
drive_tx(req);
`uvm_info("WR_DRV",$sformatf("Got item:\n%s",req.sprint()),UVM_LOW);
seq_item_port.item_done();
end
endtask

task drive_tx(wr_tx tx);
    @(posedge vif.wr_clk_i);
    vif.wr_en_i = tx.wr_en_i;
    if (tx.wr_en_i == 1)
      vif.wdata_i = tx.wdata_i;
    @(posedge vif.wr_clk_i);
    common::wr_drv_count++;
    vif.wr_en_i = 0;
endtask
endclass
