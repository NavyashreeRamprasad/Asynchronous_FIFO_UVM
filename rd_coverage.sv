class rd_coverage extends uvm_subscriber#(rd_tx);
rd_tx tx;
`uvm_component_utils(rd_coverage)
 
  covergroup cgr;

  READ: coverpoint tx.rd_en_i{
  bins RD_EN = {1'b1};}

  EMPTY: coverpoint tx.empty_o{
  bins EM ={1'b1};} 

  UNDERFLOW: coverpoint tx.underflow_o{
  bins UF ={1'b1};}

  endgroup
 

  function new(input string name, uvm_component parent=null);
	super.new(name, parent);
	cgr = new();
endfunction

function void write(rd_tx t);
$cast(tx,t);
cgr.sample();
endfunction

endclass
