class rd_base_seq extends uvm_sequence#(rd_tx);
uvm_phase phase;
`uvm_object_utils(rd_base_seq)
`NEW_OBJ

task pre_body();
phase = get_starting_phase();
if(phase != null) begin
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,15000);
end
endtask

task post_body();
if(phase != null) begin
phase.drop_objection(this);
end
endtask
endclass

class rd_empty_seq extends rd_base_seq;
`uvm_object_utils(rd_empty_seq)
`NEW_OBJ

task body();
repeat(`DEPTH) begin
  `uvm_do_with(req,{req.rd_en_i ==1;});
end
endtask
endclass

class rd_underflow_seq extends rd_base_seq;
`uvm_object_utils(rd_underflow_seq)
`NEW_OBJ

task body();
repeat(`DEPTH+1) begin
  `uvm_do_with(req,{req.rd_en_i ==1;});
end
endtask
endclass


class rd_concurrent_seq extends rd_base_seq;
`uvm_object_utils(rd_concurrent_seq)
`NEW_OBJ

task body();
wait(common::wr_drv_count>0);
repeat(common::N) begin
  `uvm_do_with(req,{req.rd_en_i ==1;});
end
endtask
endclass

