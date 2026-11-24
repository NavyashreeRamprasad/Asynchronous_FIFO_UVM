if {![info exists testname]} { set testname full_test }

file mkdir ucdb

vsim -coverage -voptargs=+acc -assertdebug -onfinish stop -suppress 12110 top +UVM_TESTNAME=$testname \
     -sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi

coverage save -onexit -testname $testname ucdb/$testname.ucdb


add wave /top/dut/u_fifo_checks/a_full
add wave /top/dut/u_fifo_checks/a_overflow
add wave /top/dut/u_fifo_checks/a_empty
add wave /top/dut/u_fifo_checks/a_underflow
add wave /top/dut/u_fifo_checks/wr_en_a
add wave /top/dut/u_fifo_checks/rd_en_a
add wave /top/dut/u_fifo_checks/wdata_a
add wave /top/dut/u_fifo_checks/rdata_a

run -all



#vlog -cover bcesft list.svh +incdir+C:/Navya/VLSIGURU/UVM/uvm-1.2/src
#
#vsim -coverage -novopt -suppress 12110 top +UVM_TESTNAME=concurrent_test -sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi
#
#view wave
#add wave -divider WRITE
#add wave -position insertpoint sim:/top/wr_clk sim:/top/rst
#add wave -position insertpoint sim:/top/pif/wr_en_i sim:/top/pif/wdata_i sim:/top/pif/full_o sim:/top/pif/overflow_o
#add wave -divider READ
#add wave -position insertpoint sim:/top/rd_clk
#add wave -position insertpoint sim:/top/pif/rd_en_i sim:/top/pif/rdata_o sim:/top/pif/empty_o sim:/top/pif/underflow_o
#add wave -divider DUT_INTERNAL
#add wave -position insertpoint sim:/top/dut/wr_pntr sim:/top/dut/rd_pntr sim:/top/dut/wr_toggle sim:/top/dut/rd_toggle
#
#run -all
#wave zoom full



