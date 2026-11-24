class rd_driver extends uvm_driver#(rd_tx);
virtual intf vif;
`uvm_component_utils(rd_driver)
`NEW_COMP

function void build_phase(uvm_phase phase);
super.build_phase(phase);
uvm_config_db#(virtual intf) :: get(this,"","vif",vif);
endfunction

task run_phase(uvm_phase phase);
vif.rd_en_i = 0;
wait (vif.rst_i == 1'b1);
forever begin
seq_item_port.get_next_item(req);
drive_tx(req);
`uvm_info("RD_DRV",$sformatf("Got item:\n%s",req.sprint()),UVM_LOW);
seq_item_port.item_done();
end
endtask

task drive_tx(rd_tx tx);
    @(posedge vif.rd_clk_i);
    vif.rd_en_i = tx.rd_en_i;
    if (tx.rd_en_i == 1) begin
      @(posedge vif.rd_clk_i);
      tx.rdata_o = vif.rdata_o;
      common::rd_drv_count++;
    end
    vif.rd_en_i = 0;
endtask
endclass
