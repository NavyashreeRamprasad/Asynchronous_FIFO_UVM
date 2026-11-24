class wr_coverage extends uvm_subscriber#(wr_tx);
wr_tx tx;
`uvm_component_utils(wr_coverage)
 
  covergroup cg1;
  
		WRITE: coverpoint tx.wr_en_i{
		bins WR_EN = {1'b1};}
    
    FULL: coverpoint tx.full_o{
    bins FU ={1'b1};} 
  
    OVERFLOW: coverpoint tx.overflow_o{
    bins OF ={1'b1};}
  
  endgroup

  function new(input string name, uvm_component parent=null);
	super.new(name, parent);
	cg1 = new();
endfunction

function void write(wr_tx t);
$cast(tx,t);
cg1.sample();
endfunction

endclass
