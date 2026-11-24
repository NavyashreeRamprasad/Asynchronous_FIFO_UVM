vlib work
vmap work work

vlog -cover bcesft list.svh +incdir+C:/Navya/VLSIGURU/UVM/uvm-1.2/src

set tests {empty_test full_test overflow_test reset_test underflow_test concurrent_test}
set ucdb_list {}

foreach t $tests {
    set testname $t
    do run.do
    quit -sim
    lappend ucdb_list ucdb/$t.ucdb
}

vcover merge -out merged.ucdb {*}$ucdb_list
vcover report -html -htmldir cov_html -details merged.ucdb
vcover report -details merged.ucdb > cov_report.txt
