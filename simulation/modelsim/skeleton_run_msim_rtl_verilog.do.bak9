transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14 {C:/altera_lite/16.0/Projects/CP4_processor_klo14/skeleton.v}
vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14 {C:/altera_lite/16.0/Projects/CP4_processor_klo14/pll.v}
vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14 {C:/altera_lite/16.0/Projects/CP4_processor_klo14/imem.v}
vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14 {C:/altera_lite/16.0/Projects/CP4_processor_klo14/dmem.v}
vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14 {C:/altera_lite/16.0/Projects/CP4_processor_klo14/CP4_processor_netid.v}
vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14/db {C:/altera_lite/16.0/Projects/CP4_processor_klo14/db/pll_altpll.v}

vlog -vlog01compat -work work +incdir+C:/altera_lite/16.0/Projects/CP4_processor_klo14 {C:/altera_lite/16.0/Projects/CP4_processor_klo14/CP4_processor_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  CP4_processor_tb

add wave *
view structure
view signals
run -all
