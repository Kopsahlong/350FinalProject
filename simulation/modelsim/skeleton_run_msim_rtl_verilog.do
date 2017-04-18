transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/VGA_Audio_PLL.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/Reset_Delay.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/skeleton.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/PS2_Interface.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/PS2_Controller.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/processor.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/pll.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/imem.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/dmem.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/Altera_UP_PS2_Data_In.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/Altera_UP_PS2_Command_Out.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/vga_controller.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/video_sync_generator.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/img_index.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/img_data.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/db {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/db/pll_altpll.v}
vlog -vlog01compat -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/binary_to_seven_segment_converter.v}
vlog -sv -work work +incdir+Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject {Z:/Addison/Documents/SCHOOL/Duke-Junior/ECE350/350FinalProject/lcd.sv}

