class wr_monitor extends uvm_monitor;
uvm_analysis_port#(wr_tx) ap_port;
virtual intf vif;
wr_tx tx;
`uvm_component_utils(wr_monitor)
`NEW_COMP

function void build_phase(uvm_phase phase);
super.build_phase(phase);
ap_port = new("ap_port",this);
uvm_config_db#(virtual intf) :: get(this,"","vif",vif);
endfunction

task run_phase(uvm_phase phase);
forever begin
@(vif.w_mon_cb);
if(vif.w_mon_cb.wr_en_i) begin
tx = new();
tx.wr_en_i = vif.w_mon_cb.wr_en_i;
tx.wdata_i = vif.w_mon_cb.wdata_i;
@(vif.w_mon_cb);
tx.full_o = vif.w_mon_cb.full_o;
tx.overflow_o = vif.w_mon_cb.overflow_o;
`uvm_info("WR_MON",$sformatf("Observed item:\n%s", tx.sprint()),UVM_LOW);
ap_port.write(tx); 
end
end
endtask

endclass
