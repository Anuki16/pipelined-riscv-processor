transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/anuki/OneDrive\ -\ University\ of\ Moratuwa/Documents/Anuki/Campus/Semester\ 5/EN3021\ Digital\ System\ Design/pipelined-riscv-processor {C:/Users/anuki/OneDrive - University of Moratuwa/Documents/Anuki/Campus/Semester 5/EN3021 Digital System Design/pipelined-riscv-processor/data_memory_for_cache.sv}
vlog -sv -work work +incdir+C:/Users/anuki/OneDrive\ -\ University\ of\ Moratuwa/Documents/Anuki/Campus/Semester\ 5/EN3021\ Digital\ System\ Design/pipelined-riscv-processor {C:/Users/anuki/OneDrive - University of Moratuwa/Documents/Anuki/Campus/Semester 5/EN3021 Digital System Design/pipelined-riscv-processor/controls.sv}
vlog -sv -work work +incdir+C:/Users/anuki/OneDrive\ -\ University\ of\ Moratuwa/Documents/Anuki/Campus/Semester\ 5/EN3021\ Digital\ System\ Design/pipelined-riscv-processor {C:/Users/anuki/OneDrive - University of Moratuwa/Documents/Anuki/Campus/Semester 5/EN3021 Digital System Design/pipelined-riscv-processor/set_assc_cache.sv}
vlog -sv -work work +incdir+C:/Users/anuki/OneDrive\ -\ University\ of\ Moratuwa/Documents/Anuki/Campus/Semester\ 5/EN3021\ Digital\ System\ Design/pipelined-riscv-processor {C:/Users/anuki/OneDrive - University of Moratuwa/Documents/Anuki/Campus/Semester 5/EN3021 Digital System Design/pipelined-riscv-processor/data_memory_controller.sv}

