`define NEW_COMP \
function new(string name="", uvm_component parent); \
super.new(name,parent); \
endfunction

`define NEW_OBJ \
function new(string name=""); \
super.new(name); \
endfunction

class common;
     static int N = 100;
     static int wr_drv_count =0;
     static int rd_drv_count =0;
     static int matching =0;
     static int mismatch =0;
     static int scb_count =0;
endclass

