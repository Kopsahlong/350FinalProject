module CP4_processor_netid(clock, reset, /*ps2_key_pressed, ps2_out, lcd_write, lcd_data,*/ dmem_data_in, dmem_address, dmem_out);
	input clock, reset/*, ps2_key_pressed*/;
	//input 	[7:0]	ps2_out;
	
	//output 			lcd_write;
	//output 	[31:0] 	lcd_data;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	dmem_data_in, dmem_out;
	output	[11:0]	dmem_address;
		
	// your processor here
	//
	
	//////////////////////////////////////
	////// THIS IS REQUIRED FOR GRADING
	// CHANGE THIS TO ASSIGN YOUR DMEM WRITE ADDRESS ALSO TO debug_addr
	assign debug_addr = dmem_address;
	// CHANGE THIS TO ASSIGN YOUR DMEM DATA INPUT (TO BE WRITTEN) ALSO TO debug_data
	assign debug_data = dmem_data_in;
	////////////////////////////////////////////////////////////
		
	wire dmem_we; // TODO: implement this
	wire multdiv_status, just_started;
	wire multdiv_ready;
	wire multdiv_in_use;
	wire enable_latch_writes;
	or multdiv_in_use_or(multdiv_in_use, just_started, multdiv_status);
	or latch_values(enable_latch_writes, ~multdiv_in_use, multdiv_ready);
	// -- Set up registers and latches -- //		
	
	// PC register
	wire PC_we; // TODO: mux this for stall later
	assign PC_we = enable_latch_writes; // TODO: remove this
	wire [31:0] next_PC, curr_PC;
	register_32 PC(clock, next_PC, PC_we, reset, curr_PC);

	// F/D latch
	wire FD_we;
	assign FD_we = enable_latch_writes;
	wire [31:0] FD_F_pc, FD_D_pc,FD_F_ir,FD_D_ir;
	register_32 FD_pc(clock, FD_F_pc, FD_we, reset, FD_D_pc);
	register_32 FD_ir(clock, FD_F_ir, FD_we, reset, FD_D_ir);
	
	// D/X latch
	wire DX_we;
	assign DX_we = enable_latch_writes;
	wire [31:0] DX_D_pc, DX_X_pc,DX_D_readA,DX_X_readA,DX_D_readB,DX_X_readB,DX_D_ir,DX_X_ir,DX_D_rstatus,DX_X_rstatus;
	register_32 DX_pc(clock, DX_D_pc, DX_we, reset, DX_X_pc);
	register_32 DX_readA(clock, DX_D_readA, DX_we, reset, DX_X_readA);
	register_32 DX_readB(clock, DX_D_readB, DX_we, reset, DX_X_readB);
	register_32 DX_rstatus(clock, DX_D_rstatus, DX_we, reset, DX_X_rstatus);
	register_32 DX_ir(clock, DX_D_ir, DX_we, reset, DX_X_ir);

	// X/M latch
	wire XM_we;
	assign XM_we = enable_latch_writes;
	wire XM_X_take_branch, XM_M_take_branch;
	wire [31:0] XM_X_op_result, XM_M_op_result,XM_X_readB,XM_M_readB,XM_X_ir,XM_M_ir,XM_X_pc,XM_M_pc,XM_X_rstatus,XM_M_rstatus;
	register_32 XM_op_result(clock, XM_X_op_result, XM_we, reset, XM_M_op_result);
	register_32 XM_readB(clock, XM_X_readB, XM_we, reset, XM_M_readB);
	register_32 XM_ir(clock, XM_X_ir, XM_we, reset, XM_M_ir);
	register_32 XM_pc(clock, XM_X_pc, XM_we, reset, XM_M_pc);
	register_32 XM_rstatus(clock, XM_X_rstatus, XM_we, reset, XM_M_rstatus);
	dffe XM_take_branch(.d(XM_X_take_branch), .clk(clock), .clrn(1'd1), .prn(1'd1),.ena(XM_we), .q(XM_M_take_branch));
	
	// M/W latch
	wire MW_we;
	assign MW_we = enable_latch_writes;
	wire [31:0] MW_M_op_result,MW_W_op_result,MW_M_data_out,MW_W_data_out,MW_M_ir,MW_W_ir,MW_M_pc_plus_one,MW_W_pc_plus_one;
	register_32 MW_op_result(clock, MW_M_op_result, MW_we, reset, MW_W_op_result);
	register_32 MW_data_out(clock, MW_M_data_out, MW_we, reset, MW_W_data_out);
	register_32 MW_pc_plus_one(clock, MW_M_pc_plus_one, MW_we, reset, MW_W_pc_plus_one);
	register_32 MW_ir(clock, MW_M_ir, MW_we, reset, MW_W_ir);
	
	dmem mydmem(	.address	(dmem_address),
					.clock		(~clock),
					.data		(dmem_data_in),
					.wren		(dmem_we), 
					.q			(MW_M_data_out) // change where output q goes...
	);
	
	assign dmem_out = MW_M_data_out;
	
	// -- parse out all instructions -- //
	
	wire [4:0] F_op, F_rd, F_rs, F_rt, F_shamt, F_aluop;
	wire [16:0] F_immediate;
	wire [26:0] F_target;
	wire F_add,F_addi,F_sub,F_and_op,F_or_op, F_sll, F_sra, F_mul, F_div, F_sw, F_lw, F_j, F_bne, F_jal, F_jr, F_blt, F_bex, F_setx, F_custom_r, F_custom;
	ir_decoder F_decoder(FD_F_ir, F_op, F_rd, F_rs, F_rt, F_shamt, F_aluop, F_immediate, F_target);
	control_decoder F_control(F_op,F_aluop, F_add,F_addi,F_sub,F_and_op,F_or_op, F_sll, F_sra, F_mul, F_div, F_sw, F_lw, F_j, F_bne, F_jal, F_jr, F_blt, F_bex, F_setx, F_custom_r, F_custom);

	wire [4:0] D_op, D_rd, D_rs, D_rt, D_shamt, D_aluop;
	wire [16:0] D_immediate;
	wire [26:0] D_target;
	wire D_add,D_addi,D_sub,D_and,D_or, D_sll, D_sra, D_mul, D_div, D_sw, D_lw, D_j, D_bne, D_jal, D_jr, D_blt, D_bex, D_setx, D_custom_r, D_custom;
	ir_decoder D_decoder(FD_D_ir, D_op, D_rd, D_rs, D_rt, D_shamt, D_aluop, D_immediate, D_target);
	control_decoder D_control(D_op,D_aluop, D_add,D_addi,D_sub,D_and,D_or, D_sll, D_sra, D_mul, D_div, D_sw, D_lw, D_j, D_bne, D_jal, D_jr, D_blt, D_bex, D_setx, D_custom_r, D_custom);
	
	wire [4:0] X_op, X_rd, X_rs, X_rt, X_shamt, X_aluop;
	wire [16:0] X_immediate;
	wire [26:0] X_target;
	wire X_add,X_addi,X_sub,X_and,X_or, X_sll, X_sra, X_mul, X_div, X_sw, X_lw, X_j, X_bne, X_jal, X_jr, X_blt, X_bex, X_setx, X_custom_r, X_custom;
	ir_decoder X_decoder(DX_X_ir, X_op, X_rd, X_rs, X_rt, X_shamt, X_aluop, X_immediate, X_target);
	control_decoder X_control(X_op,X_aluop, X_add,X_addi,X_sub,X_and,X_or, X_sll, X_sra, X_mul, X_div, X_sw, X_lw, X_j, X_bne, X_jal, X_jr, X_blt, X_bex, X_setx, X_custom_r, X_custom);
	
	wire [4:0] M_op, M_rd, M_rs, M_rt, M_shamt, M_aluop;
	wire [16:0] M_immediate;
	wire [26:0] M_target;
	wire M_add,M_addi,M_sub,M_and,M_or, M_sll, M_sra, M_mul, M_div, M_sw, M_lw, M_j, M_bne, M_jal, M_jr, M_blt, M_bex, M_setx, M_custom_r, M_custom;
	ir_decoder M_decoder(XM_M_ir, M_op, M_rd, M_rs, M_rt, M_shamt, M_aluop, M_immediate, M_target);
	control_decoder M_control(M_op,M_aluop, M_add,M_addi,M_sub,M_and,M_or, M_sll, M_sra, M_mul, M_div, M_sw, M_lw, M_j, M_bne, M_jal, M_jr, M_blt, M_bex, M_setx, M_custom_r, M_custom);

	wire [4:0] W_op, W_rd, W_rs, W_rt, W_shamt, W_aluop;
	wire [16:0] W_immediate;
	wire [26:0] W_target;
	wire W_add,W_addi,W_sub,W_and,W_or, W_sll, W_sra, W_mul, W_div, W_sw, W_lw, W_j, W_bne, W_jal, W_jr, W_blt, W_bex, W_setx, W_custom_r, W_custom;
	ir_decoder W_decoder(MW_W_ir, W_op, W_rd, W_rs, W_rt, W_shamt, W_aluop, W_immediate, W_target);
	control_decoder W_control(W_op,W_aluop, W_add,W_addi,W_sub,W_and,W_or, W_sll, W_sra, W_mul, W_div, W_sw, W_lw, W_j, W_bne, W_jal, W_jr, W_blt, W_bex, W_setx, W_custom_r, W_custom);
	
	// FETCH
	
	// -- Fetch new instruction with curr PC --/
	
	// find a way to initialize curr pc to zero if it is not already
	
	// if no bit of the pc is 1, initialize it to 0
	wire [11:0] imem_address;
	wire [31:0] PC_decided_0, PC_decided_1, PC_decided_2;
	wire initialize_pc, at_least_one_1;
	or at_least_one_1_or(at_least_one_1, curr_PC[11], curr_PC[10], curr_PC[9], curr_PC[8], curr_PC[7], curr_PC[6], curr_PC[5], curr_PC[4], curr_PC[3], curr_PC[2], curr_PC[1], curr_PC[0]);
	not initialize_pc_gate(initialize_pc, at_least_one_1);
	MUX_2_1_32bit choose_pc(PC_decided_0, curr_PC, 32'd0, initialize_pc); 
	
		//-- PC = T (aka jump) --//
	wire PC_jump;
	//assign PC_jump = 1'b0;
	wire [31:0] jump_target;
	MUX_2_1_32bit decide_jump(PC_decided_1, PC_decided_0 , jump_target , PC_jump);
	
	//-- PC = PC + N + 1 (aka branch)--//
	wire PC_branch;
	wire [31:0] branch_target;
	//assign PC_branch = 1'b0;
	//wire [31:0] PC_plus_N, SE_M_immediate;
	//adder PC_branch_adder(PC_plus_N, PC_overflow_0, SE_M_immediate, curr_PC); 
	MUX_2_1_32bit decide_branch(PC_decided_2, PC_decided_1, branch_target, PC_branch);
	
	assign imem_address = PC_decided_2[11:0];
	
	wire [31:0] imem_instr;

	imem myimem(	.address 	(imem_address), //
					.clken		(1'b1),
					.clock		(~clock),
					.q			(imem_instr)
	);
	
	// -- Choose next PC --//

	// PC = PC+1
	wire PC_overflow_1;
	adder PC_adder_0(next_PC, PC_overflow_1, 32'b1, PC_decided_2); 
	
	// -- latch everything -- //
	
	assign FD_F_pc = imem_address;
	assign FD_F_ir = imem_instr;
	// TODO: implement stalling here
	// insert nop if needed (if branch)
	//MUX_2_1_32bit noop_0(FD_F_ir, imem_instr, 32'd0, branchPC);
	
	wire branch_or_jump_stall;
	or stall_or(branch_or_jump_stall, PC_branch, PC_jump);
	
	// *****************************************************************************//
	// DECODE

	// -- read data -- //
	
	// choose regReadA and regReadB using opcode
	
	wire [4:0] regReadA, regReadB, regWrite;
	
	assign regReadA = D_rs;
	identify_readRegB identify_D_readRegB(regReadB, D_op , D_rd, D_rt, D_addi);	
	
	wire reg_we, rstatus_we; 
	wire [31:0] regWrite_data, regReadA_data, regReadB_data, next_rstatus_value, curr_rstatus_value;
	regfile my_regfile(~clock, reg_we, reset, regWrite, regReadA, regReadB, regWrite_data, regReadA_data, regReadB_data, rstatus_we, next_rstatus_value, curr_rstatus_value);

	
	// if regWrite == regReadA or regReadB, then set the regReadA_data to be writedata TODO: check if you even need this any more w negatively clocking your reg file (probs can't hurt to keep tho)
	wire writereadA_bypass, writereadB_bypass, writereadA, writereadB;
	comparator_5bit writereadA_comp(less_than4, writereadA, regWrite, regReadA);
	comparator_5bit writereadB_comp(less_than5, writereadB, regWrite, regReadB);
	and writereadA_and(writereadA_bypass,writereadA,reg_we);
	and writereadB_and(writereadB_bypass,writereadB,reg_we);
	
	MUX_2_1_32bit choose_readA_data(DX_D_readA,regReadA_data,regWrite_data,writereadA_bypass);
	MUX_2_1_32bit choose_readB_data(DX_D_readB,regReadB_data,regWrite_data,writereadB_bypass);
	
	// -- latch everything -- //

	// write readA and readB data to DX latch
	assign DX_D_pc = FD_D_pc;
	//assign DX_D_readA = regReadA_data;
	//assign DX_D_readB = regReadB_data;
	assign DX_D_rstatus = curr_rstatus_value;
	// insert nop if needed (if branch)
	MUX_2_1_32bit noop_0(DX_D_ir, FD_D_ir, 32'd0, branch_or_jump_stall);
	
	// *****************************************************************************//
	// EXECUTE

	// decide data_operandA and data_operandB
	wire [31:0] data_operandA, data_operandB;

	// TODO: implement bypassing here later
	
	// if X_readA == M_writeReg && M_we || X_readB == M_writeReg && M_we (aka RAW)  --> data_operandA/B = operation
	wire readAmemWrite, readBmemWrite, Amemequal, Bmemequal;
	wire M_reg_we;
	wire [4:0] M_writeReg, X_readA, X_readB;
	assign X_readA = X_rs;
	identify_readRegB find_X_readReg_B(X_readB, X_op, X_rd, X_rt, X_addi);
	identify_writeReg find_writeReg_0(XM_M_ir, M_writeReg, M_rd, M_reg_we, M_add, M_addi, M_sub, M_and, M_or, M_sll, M_sra, M_mul, M_div, M_lw, M_jal);
   comparator_5bit readAMwrite(less_than0, Amemequal, X_readA, M_writeReg);
   comparator_5bit readBMwrite(less_than1, Bmemequal, X_readB, M_writeReg);
	
	// make sure that you're not just writing to reg0
	wire A_equalto_r0, B_equalto_r0;
	comparator_5bit compare_to_r0_0(A_lessthan_r0, A_equalto_r0, X_readA, 5'd0);
	comparator_5bit compare_to_r0_1(B_lessthan_r0, B_equalto_r0, X_readB, 5'd0);
	
	and and_0(readAmemWrite, Amemequal, M_reg_we, ~A_equalto_r0);
	and and_1(readBmemWrite, Bmemequal, M_reg_we, ~B_equalto_r0);
	
	// if X_readA == W_writeReg && W_we || X_readB == W_writeReg && W_we	(aka load word or RAW) --> data_operandA = data out writeback	
	wire readAwbWrite, readBwbWrite, Awbequal, Bwbequal;
   comparator_5bit readAwbwrite(less_than2, Awbequal, X_readA, regWrite);
   comparator_5bit readBwbrite(less_than3, Bwbequal, X_readB, regWrite);
	and and_2(readAwbWrite, Awbequal, reg_we);
	and and_3(readBwbWrite, Bwbequal, reg_we);
	
	// mux for Mem bypass
	wire [31:0] temp_operandA_0,temp_operandA_1,temp_operandB_0,temp_operandB_1;
	MUX_2_1_32bit raw_0(temp_operandA_0, DX_X_readA, XM_M_op_result, readAmemWrite);
	MUX_2_1_32bit raw_1(temp_operandB_0, DX_X_readB, XM_M_op_result, readBmemWrite);
	
	// mux for WB bypass
	MUX_2_1_32bit lw_0(data_operandA, temp_operandA_0, regWrite_data, readAwbWrite);
	MUX_2_1_32bit lw_1(temp_operandB_1, temp_operandB_0, regWrite_data, readBwbWrite);

	// for the case that readB is not being used in this step but needs to be updated for later (aka sw)
	assign XM_X_readB = temp_operandB_1;
	
	// for data_operandB, if it's an N operation, still use that anyways		
	wire use_immediate;
	or select_imm_or(use_immediate, X_addi, X_lw, X_sw);
	
	// sign extend immediate 
	wire [31:0] SE_X_immediate;
	assign SE_X_immediate[16:0] = X_immediate;
	
	genvar i;
	generate
		for(i=17; i<32; i=i+1) begin: Sign_Extend 
			assign SE_X_immediate[i] = X_immediate[16];
		end
	endgenerate
	
	MUX_2_1_32bit select_data_opB(data_operandB, temp_operandB_1, SE_X_immediate, use_immediate);
	
	wire X_isLessThan, X_isNotEqual, alu_overflow;
	wire [31:0] X_data_result, X_alu_result, X_multdiv_result;
	
	// -- Execute using ALU or MultDiv -- //
	wire [4:0] alu_op,alu_op_0,alu_op_1;
	
	// choose add opcode if addi, sw, lw
	wire use_add;
	or choose_add(use_add, X_addi, X_sw, X_lw);
	MUX_2_1_5bit choose_alu_op_mux_0(alu_op_0, X_aluop, 5'd0, use_add);
	
	// choose sub opcode if bne, blt
	wire bne_or_blt;
	or choose_sub(bne_or_blt, X_bne, X_blt);
	MUX_2_1_5bit choose_alu_op_mux_1(alu_op, alu_op_0, 5'd1, bne_or_blt);

	// operate with ALU
	alu my_alu(data_operandA, data_operandB, alu_op, X_shamt, X_alu_result, X_isNotEqual, X_isLessThan, alu_overflow);
	
	// ctrl_mul and ctrl_div should only be high when it's your first time inputting a new instruction & that insrs is a mult/div 
	wire clrn, prn, we;
	assign clrn = 1'b1;
	assign prn = 1'b1;
	assign we = 1'b1;
	wire next_multdiv_status, toggle_multdiv_status;
	dffe a_dffe(.d(next_multdiv_status), .clk(clock), .clrn(clrn), .prn(prn),.ena(we), .q(multdiv_status));
	//Toggle_FF multdiv_toggle(toggle_multdiv_status, clock, 1'b0, multdiv_status); //set reset as 0
	//do some sort of logic where you initialize the dff maybe??? TODO
	
	// multdiv_status = 0 means available, multdiv_status = 1 means NOT available
	
	// choose whether or not to start a mul or div
	wire start_mul, start_div;
	and mul_start_and(start_mul, X_mul, ~multdiv_status);
	and div_start_and(start_div, X_div, ~multdiv_status);
	
	or mul_or_div_started(just_started, start_mul, start_div);	
	
	// operate with multiplier TODO: confused about this part bc it needs 32 clock cycles...
	wire multdiv_exception, multdiv_ready_probably; // TODO: fill these in 
	multdiv my_multdiv(data_operandA, data_operandB, start_mul, start_div, clock, X_multdiv_result, multdiv_exception, multdiv_ready_probably);
	
	// if just started should set to 1, or if it's 1 should keep it that way unless your multdiv_result was 1
	// 0: if multdiv_result==1&current_status==1 if X_mul==0&&X_div==0&current status= 

	// ensure that multdiv ready isn't just showing high after 32 cycles
	wire mul_or_div;
	or mul_or_div_gate(mul_or_div, X_mul, X_div);	 
	and multdiv_ready_and(multdiv_ready, multdiv_ready_probably, mul_or_div);

	// if the mult div is ready or a new instruction just started, status should be toggled
	or toggle_or(toggle_multdiv_status, multdiv_ready, just_started);
	
	MUX_2_1_1bit toggle_status(next_multdiv_status, multdiv_status,~multdiv_status,toggle_multdiv_status);
	
	// choose whether data result should come from alu or mult
	wire select_multdiv;
	or select_multdiv_or(select_multdiv, X_mul, X_div);
	MUX_2_1_32bit select_multdiv_mux(X_data_result, X_alu_result, X_multdiv_result, select_multdiv);
	
	//-- Check if blt or bne and if the branch was actually taken --//
	wire take_branch, branchPC_c1, branchPC_c2;
	and blt_and_lessthan(branchPC_c1, X_blt, X_isLessThan);
	and bne_and_notequal(branchPC_c2, X_bne, X_isNotEqual);
	or choose_branch_or(take_branch, branchPC_c1, branchPC_c2);
	
	//-- Write to rstatus if anything went wrong --//
	
	// check if something actually did go wrong
	wire add_overflow, addi_overflow, sub_overflow, mul_overflow, div_exception;
	and and_add_o(add_overflow,X_add, alu_overflow);
	and and_addi_o(addi_overflow, X_addi, alu_overflow);
	and and_sub_o(sub_overflow, X_sub, alu_overflow);
	and and_mul_o(mul_overflow, X_mul, multdiv_exception, multdiv_ready);
	and and_div_o(div_exception, X_div, multdiv_exception, multdiv_ready);
	
	or set_rstatus_we(rstatus_we, add_overflow, addi_overflow, sub_overflow, mul_overflow, div_exception, X_setx);
	
	//sign extend Target for x_setx
	wire [31:0] E_X_target;
	assign E_X_target[16:0] = X_target;
	assign E_X_target[31:17] = 15'd0;
	assign XM_X_rstatus = DX_X_rstatus;
	//set what rstatus should actually be
	wire [31:0] rstatus_0, rstatus_1, rstatus_2, rstatus_3, rstatus_4;
	MUX_2_1_32bit choose_rs0(rstatus_0, 32'd15, 32'd1, add_overflow);	// 15 is just for debugging purposes since it should never be hit
	MUX_2_1_32bit choose_rs1(rstatus_1, rstatus_0, 32'd2, addi_overflow);
	MUX_2_1_32bit choose_rs2(rstatus_2, rstatus_1, 32'd3, sub_overflow);
	MUX_2_1_32bit choose_rs3(rstatus_3, rstatus_2, 32'd4, mul_overflow);
	MUX_2_1_32bit choose_rs4(rstatus_4, rstatus_3, 32'd5, div_exception);
	MUX_2_1_32bit choose_rs5(next_rstatus_value, rstatus_4, E_X_target, X_setx);
	
	
	// -- Latch everything -- //
	
	assign XM_X_op_result = X_data_result;
	//assign XM_X_readB = DX_X_readB;
	assign XM_X_pc = DX_X_pc; //TODO input stall stuff here later
	assign XM_X_take_branch = take_branch;
	
	MUX_2_1_32bit noop_1(XM_X_ir, DX_X_ir, 32'd0, branch_or_jump_stall);
	// *****************************************************************************//
	// MEMORYs

	// -- Choose Address w Operation result and Data with readB -- //

	assign dmem_address = XM_M_op_result[11:0];
	assign dmem_data_in = XM_M_readB;
	
	assign dmem_we = M_sw;
	
	// -- Check if you should activate branch or jump --/
	
	// jump (<-- includes bex)
	
	// for bex, compare rstatus output to 0
	wire rstatus_equal_to;
	comparator compare_rstatus(rstatus_less_than, rstatus_equal_to, XM_M_rstatus, 32'd0);
	wire M_bex_taken;
	and take_bex(M_bex_taken, ~rstatus_equal_to, M_bex);
	
	// decide if you should jump
	or calc_jump(PC_jump, M_jal, M_j, M_jr, M_bex_taken);
	
	// calculate target
	wire [31:0] E_M_target;
	assign E_M_target[16:0] = M_target;
	assign E_M_target[31:17] = 15'd0;
	
	MUX_2_1_32bit choose_jump_target(jump_target, E_M_target, XM_M_readB, M_jr); //TODO: check to be sure this is right w the readB stuff
	
	// branch

	// decide if you should jump
	wire branch_instruction;
	wire branch_taken;
	or calc_branch(branch_instruction, M_bne, M_blt); //TODO: figure bex case
	and is_branch(PC_branch, branch_instruction, XM_M_take_branch);
	
	// calculate sign extended immediate 
	wire [31:0] SE_M_immediate;
	assign SE_M_immediate[16:0] = M_immediate;
	
	genvar j;
	generate
		for(i=17; i<32; i=i+1) begin: Sign_Extend_Memory 
			assign SE_M_immediate[i] = M_immediate[16];
		end
	endgenerate
	
	// add to branch's PC + 1 + SE_M_immediate
	wire [31:0] branch_PC_plus_1;
	adder PC_adder_1(branch_PC_plus_1, PC_overflow_2, XM_M_pc, 32'b1); 	
	adder PC_adder_2(branch_target, PC_overflow_3, SE_M_immediate, branch_PC_plus_1); 
	
	// -- Latch everything -- //
	
	assign MW_M_op_result = XM_M_op_result;
	// assign MW_M_data_out already occurs in dmem 	
	assign MW_M_ir = XM_M_ir;
	assign MW_M_pc_plus_one = branch_PC_plus_1;
	
	
	// *****************************************************************************//
	// WRITEBACK
	
	// muxing occurs over in reg file accd to this implementation
	// -- write data -- //
	
	identify_writeReg identify_writeReg_0(MW_W_ir, regWrite, W_rd, reg_we, W_add, W_addi, W_sub, W_and, W_or, W_sll, W_sra, W_mul, W_div, W_lw, W_jal);
	
	// decide what to write: assign with either O (operation result) or D (data) from writeback
	wire [31:0] regWrite_data_interm;
	MUX_2_1_32bit select_write_data_0(regWrite_data_interm, MW_W_op_result, MW_W_data_out, W_lw);
	MUX_2_1_32bit select_write_data_1(regWrite_data, regWrite_data_interm, MW_W_pc_plus_one, W_jal);
	
endmodule

module identify_writeReg(full_instruction, regWrite, rd, reg_we, add, addi, sub, and_op, or_op, sll, sra, mul, div, lw, jal);
	output reg_we;
	output [4:0] regWrite, rd;
	input [31:0] full_instruction;
	input add, addi, sub, and_op, or_op, sll, sra, mul, div, lw, jal;
	
	// decide if you should write
	wire write_instr;
	or select_we_or(write_instr, add, addi, sub, and_op, or_op, sll, sra, mul, div, lw, jal);
	
	// make sure it's not a noop 
	wire less_than, is_noop;
	comparator check_noop(less_than, is_noop, full_instruction, 32'd0);
	
	and reg_we_and(reg_we, write_instr,~is_noop);
	
	// decide where to write	
	MUX_2_1_5bit regWrite_mux(regWrite, rd, 5'd31, jal);
	
endmodule

module identify_readRegB(regReadB, op, rd, rt, addi);

	input [4:0] op, rd, rt;
	input addi;
	output [4:0] regReadB;
	
	wire first_00000;
	and c_00000_and(first_00000, ~op[4],~op[3],~op[2],~op[1],~op[0]); //TODO: minimize later 
	
	wire use_rtA_anrdW;
	or select_regs_or(use_rtA_anrdW, first_00000, addi);
	
	MUX_2_1_5bit regReadB_mux(regReadB, rd, rt, use_rtA_anrdW);
	
endmodule

module control_decoder(op, aluop ,add, addi, sub, and_op,or_op, sll, sra, mul, div, sw, lw, j, bne, jal, jr, blt, bex, setx, custom_r, custom);
	input [4:0] op, aluop;
	output add,addi,sub,and_op,or_op, sll, sra, mul, div, sw, lw, j, bne, jal, jr, blt, bex, setx, custom_r, custom;
	
	and and_0(add, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], ~aluop[2], ~aluop[1], ~aluop[0]);
	and and_1(addi, ~op[4], ~op[3], op[2], ~op[1], op[0]);
	and and_2(sub, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], ~aluop[2], ~aluop[1], aluop[0]);
	and and_3(and_op, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], ~aluop[2], aluop[1], ~aluop[0]);
	and and_4(or_op, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], ~aluop[2], aluop[1], aluop[0]);
	and and_5(sll, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], aluop[2], ~aluop[1], ~aluop[0]);
	and and_6(sra, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], aluop[2], ~aluop[1], aluop[0]);
	and and_7(mul, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], aluop[2], aluop[1], ~aluop[0]);
	and and_8(div, ~op[4], ~op[3], ~op[2], ~op[1], ~op[0], ~aluop[4], ~aluop[3], aluop[2], aluop[1], aluop[0]);
	and and_9(sw, ~op[4], ~op[3], op[2], op[1], op[0]);
	and and_10(lw, ~op[4], op[3], ~op[2], ~op[1], ~op[0]);
	and and_11(j, ~op[4], ~op[3], ~op[2], ~op[1], op[0]);
	and and_12(bne, ~op[4], ~op[3], ~op[2], op[1], ~op[0]);
	and and_13(jal, ~op[4], ~op[3], ~op[2], op[1], op[0]);
	and and_14(jr, ~op[4], ~op[3], op[2], ~op[1], ~op[0]);
	and and_15(blt, ~op[4], ~op[3], op[2], op[1], ~op[0]);
	and and_16(bex, op[4], ~op[3], op[2], op[1], ~op[0]);
	and and_17(setx, op[4], ~op[3], op[2], ~op[1], op[0]);
	//and and_0(custom_r, ~op[9], ~op[8], ~op[7], ~op[6], ~op[5]);
	//and and_0(custom, ~op[9], ~op[8], ~op[7], ~op[6], ~op[5]);
endmodule

module ir_decoder(instruction, opcode, rd, rs, rt, shamt, aluop, immediate, target);
	input [31:0] instruction;
	output [4:0] opcode, rd, rs, rt, shamt, aluop;
	output [16:0] immediate;
	output [26:0] target;
	
   assign opcode = instruction[31:27]; // 5 
	assign rd = instruction[26:22];		// 5
	assign rs = instruction[21:17];		// 5
	assign rt = instruction[16:12];		// 5
	assign shamt = instruction[11:7];	// 5
	assign aluop = instruction[6:2];		// 5
	//assign zeroesR = instruction[1:0]; // may or may not actually be used
	assign immediate = instruction[16:0]; // TODO: SE to 32 bits
	assign target = instruction[26:0]; // TODO: SE to 32 bits using upper bits from current PC+1
	//assign zeroesJII = instruction[21:0]; // may or may not actually be used
	
endmodule	

/** REGFILE **/

module regfile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB, rstatus_writeEnable, next_rstatus_value, curr_rstatus_value);
 
 input clock, ctrl_writeEnable, ctrl_reset, rstatus_writeEnable;
 input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
 input [31:0] data_writeReg, next_rstatus_value;
 output [31:0] data_readRegA, data_readRegB, curr_rstatus_value;
 
	wire [31:0] decoded_writeReg,decoded_readRegA, decoded_readRegB;
	wire [31:0] registeroutputdata [31:0];
	
	// decode values 
	DECODER5_32 decoder_write(decoded_writeReg, ctrl_writeReg, ctrl_writeEnable);
	DECODER5_32 decoder_readA(decoded_readRegA, ctrl_readRegA, 1'b1);
	DECODER5_32 decoder_readB(decoded_readRegB, ctrl_readRegB, 1'b1);
	
	genvar i;
	
	// this represents register 0
	assign registeroutputdata[0] = 32'd0;
	
	// choose what data to write to register30
	wire [31:0] data_writeReg_30;
	MUX_2_1_32bit choose_r30(data_writeReg_30, data_writeReg, next_rstatus_value, rstatus_writeEnable);
	
	// say whether or not r30 should be enabled
	wire r30_we;
	MUX_2_1_1bit choose_r30_we(r30_we, decoded_writeReg[30], rstatus_writeEnable, rstatus_writeEnable);
	
	// 31 registers to read and write from
	register_32 register1(clock, data_writeReg, decoded_writeReg[1], ctrl_reset, registeroutputdata[1]);
	register_32 register2(clock, data_writeReg, decoded_writeReg[2], ctrl_reset, registeroutputdata[2]);
	register_32 register3(clock, data_writeReg, decoded_writeReg[3], ctrl_reset, registeroutputdata[3]);
	register_32 register4(clock, data_writeReg, decoded_writeReg[4], ctrl_reset, registeroutputdata[4]);
	register_32 register5(clock, data_writeReg, decoded_writeReg[5], ctrl_reset, registeroutputdata[5]);
	register_32 register6(clock, data_writeReg, decoded_writeReg[6], ctrl_reset, registeroutputdata[6]);
	register_32 register7(clock, data_writeReg, decoded_writeReg[7], ctrl_reset, registeroutputdata[7]);
	register_32 register8(clock, data_writeReg, decoded_writeReg[8], ctrl_reset, registeroutputdata[8]);
	register_32 register9(clock, data_writeReg, decoded_writeReg[9], ctrl_reset, registeroutputdata[9]);
	register_32 register10(clock, data_writeReg, decoded_writeReg[10], ctrl_reset, registeroutputdata[10]);
	register_32 register11(clock, data_writeReg, decoded_writeReg[11], ctrl_reset, registeroutputdata[11]);
	register_32 register12(clock, data_writeReg, decoded_writeReg[12], ctrl_reset, registeroutputdata[12]);
	register_32 register13(clock, data_writeReg, decoded_writeReg[13], ctrl_reset, registeroutputdata[13]);
	register_32 register14(clock, data_writeReg, decoded_writeReg[14], ctrl_reset, registeroutputdata[14]);
	register_32 register15(clock, data_writeReg, decoded_writeReg[15], ctrl_reset, registeroutputdata[15]);
	register_32 register16(clock, data_writeReg, decoded_writeReg[16], ctrl_reset, registeroutputdata[16]);
	register_32 register17(clock, data_writeReg, decoded_writeReg[17], ctrl_reset, registeroutputdata[17]);
	register_32 register18(clock, data_writeReg, decoded_writeReg[18], ctrl_reset, registeroutputdata[18]);
	register_32 register19(clock, data_writeReg, decoded_writeReg[19], ctrl_reset, registeroutputdata[19]);
	register_32 register20(clock, data_writeReg, decoded_writeReg[20], ctrl_reset, registeroutputdata[20]);
	register_32 register21(clock, data_writeReg, decoded_writeReg[21], ctrl_reset, registeroutputdata[21]);
	register_32 register22(clock, data_writeReg, decoded_writeReg[22], ctrl_reset, registeroutputdata[22]);
	register_32 register23(clock, data_writeReg, decoded_writeReg[23], ctrl_reset, registeroutputdata[23]);
	register_32 register24(clock, data_writeReg, decoded_writeReg[24], ctrl_reset, registeroutputdata[24]);
	register_32 register25(clock, data_writeReg, decoded_writeReg[25], ctrl_reset, registeroutputdata[25]);
	register_32 register26(clock, data_writeReg, decoded_writeReg[26], ctrl_reset, registeroutputdata[26]);
	register_32 register27(clock, data_writeReg, decoded_writeReg[27], ctrl_reset, registeroutputdata[27]);
	register_32 register28(clock, data_writeReg, decoded_writeReg[28], ctrl_reset, registeroutputdata[28]);
	register_32 register29(clock, data_writeReg, decoded_writeReg[29], ctrl_reset, registeroutputdata[29]);
	register_32 register30(clock, data_writeReg_30, r30_we, ctrl_reset, registeroutputdata[30]);
	register_32 register31(clock, data_writeReg, decoded_writeReg[31], ctrl_reset, registeroutputdata[31]);
	
	assign curr_rstatus_value = registeroutputdata[30];
	
	// tri states for ReadA
	generate
		for(i=0; i<32; i=i+1) begin: tri_stateA_loop 
			TRISTATE a_tri_stateA(registeroutputdata[i], decoded_readRegA[i], data_readRegA);
		end
	endgenerate
	
	// tri states for ReadB
	generate
		for(i=0; i<32; i=i+1) begin: tri_stateB_loop 
			TRISTATE a_tri_stateB(registeroutputdata[i], decoded_readRegB[i], data_readRegB);
		end
	endgenerate
	
endmodule

module TRISTATE(in, oe, out);
	input [31:0] in; 
	input oe;
	output [31:0] out;
	
	assign out = oe ? in : 32'bz;
	
endmodule	

module register_32(clock, writedata, we, reset, outputdata);
	input [31:0] writedata;
	input clock, we, reset;
	output [31:0] outputdata;
	
	wire preset, clrn, prn;
	assign preset = 0; // preset always off

	assign clrn = ~reset;
	assign prn = ~preset;

	// Generate 32 dffe's
	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin: loop 
			dffe a_dffe(.d(writedata[i]), .clk(clock), .clrn(clrn), .prn(prn),.ena(we), .q(outputdata[i]));
		end
	endgenerate
	
endmodule	

/** ALU **/

module alu(data_operandA, data_operandB, ctrl_ALUopcode,
ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
	input [31:0] data_operandA, data_operandB;
	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	output [31:0] data_result;
	output isNotEqual, isLessThan, overflow;
  
	wire [31:0] operation_output [5:0]; // check to be sure you have these in right order
	wire [31:0] decoded_opcode;
	
	// decode your opcode so that you can choose your result with tri states later
	wire enable;
	assign enable = 1;
	DECODER5_32 decoder(decoded_opcode, ctrl_ALUopcode, enable);
	
	// if subtract opcode is valid, invert your B
	wire neg_overflow;
	wire [31:0] flipped_data_operandB, negated_data_operandB, updated_data_operandB, one_32b;
	
	assign one_32b = 32'b1;
	not32 not_gate_32(flipped_data_operandB,data_operandB);
	adder my_neg_adder(negated_data_operandB, neg_overflow, flipped_data_operandB, one_32b); // add 1 to B
	
	MUX_2_1 choose_operandB(updated_data_operandB, data_operandB, negated_data_operandB, decoded_opcode[1]);
	
	// add them, place in the add and subtract outputs
	wire sum_overflow; // <-- Q: do we ever use this?
	
	adder my_adder(operation_output[0],sum_overflow, data_operandA, updated_data_operandB);
	assign operation_output[1] = operation_output[0]; 
	
	// calculate overflow
	wire adder_overflow,notAnotBS,ABnotS,AnotBnotS, notABS, notA,notB,notS,added,subtracted;
	
	not nA(notA, data_operandA[31]);
	not nB(notB, data_operandB[31]);
	not nS(notS, operation_output[0][31]);
	assign subtracted = ctrl_ALUopcode[0];
	not nSub(added, subtracted);
	
	and case1(notAnotBS, notA, notB, operation_output[0][31], added);
	and case2(ABnotS, data_operandA[31], updated_data_operandB[31], notS, added);
	and case3(AnotBnotS, data_operandA[31], notB, notS, subtracted);
	and case4(notABS, notA, data_operandB[31], operation_output[0][31], subtracted);
	
	or overflow_calc(overflow, notAnotBS, ABnotS, AnotBnotS, notABS);
	
	// and
	and32 and_gate_32(operation_output[2], data_operandA, data_operandB);
	// Q: is it okay to hard code values like this?
	
	// or 
	or32 or_gate_32(operation_output[3], data_operandA, data_operandB);
	
	// sll
	n_bit_shifter_left left_shifter(operation_output[4], data_operandA, ctrl_shiftamt);
	
	// sra 
	n_bit_shifter_right right_shifter(operation_output[5], data_operandA, ctrl_shiftamt);
	
	// isnotequal
	or or_equal(isNotEqual, operation_output[1][31],operation_output[1][30],operation_output[1][29],operation_output[1][28],
	operation_output[1][27],operation_output[1][26],operation_output[1][25],operation_output[1][24],operation_output[1][23],
	operation_output[1][22],operation_output[1][21],operation_output[1][20],operation_output[1][19],operation_output[1][18],
	operation_output[1][17],operation_output[1][16],operation_output[1][15],operation_output[1][14],operation_output[1][13],
	operation_output[1][12],operation_output[1][11],operation_output[1][10],operation_output[1][9],operation_output[1][8],
	operation_output[1][7],operation_output[1][6],operation_output[1][5],operation_output[1][4],operation_output[1][3],
	operation_output[1][2],operation_output[1][1],operation_output[1][0]);
	
	// islessthan
	wire AnegBpos, AposBpos, AnegBneg, notOriginalA, notOriginalB, AposBposAsubBneg, AnegBnegAsubBneg;
	
	not not_lt_0(notOriginalB, data_operandB[31]);
	not not_lt_1(notOriginalA, data_operandA[31]);
	
	and and_lt_0(AnegBpos,data_operandA[31],notOriginalB);
	and and_lt_1(AposBpos, notOriginalA, notOriginalB);
	and and_lt_2(AnegBneg, data_operandA[31], data_operandB[31]);
	
	and and_lt_3(AposBposAsubBneg, AposBpos, operation_output[1][31]);
	and and_lt_4(AnegBnegAsubBneg, AnegBneg, operation_output[1][31]);
	
	or or_lt_0(isLessThan,AnegBpos, AposBposAsubBneg,AnegBnegAsubBneg );
	
	
	// tri states to choose operation
	genvar i;
	generate
		for(i=0; i<6; i=i+1) begin: tri_state_loop 
			TRISTATE a_tri_state(operation_output[i], decoded_opcode[i], data_result);
		end
	endgenerate
 
endmodule

// FULL NEGATE
module not32(negated, in);
	input [31:0] in;
	output [31:0] negated;
	
	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin: negate_loop 
			not a_not(negated[i], in[i]);
		end
	endgenerate

endmodule

// FULL OR 
module or32(out, A, B);
	input [31:0] A, B;
	output [31:0] out;
	
	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin: or_loop 
			or a_or(out[i], A[i], B[i]);
		end
	endgenerate

endmodule

// FULL AND 
module and32(out, A, B);
	input [31:0] A, B;
	output [31:0] out;
	
	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin: negate_loop 
			and a_and(out[i], A[i], B[i]);
		end
	endgenerate

endmodule 

// FULL ADDER SECTION
module adder(sum, overflow, data_operandA, data_operandB);
	input [31:0] data_operandA;
	input [31:0] data_operandB;
	output [31:0] sum;
	output overflow;
	
	wire carry0, carry1, carry2;
	wire unneeded_carry0,unneeded_carry1,unneeded_carry2;
	wire default_c;
	
	assign default_c = 0;
	
	ripple_carry_8_bit add0(sum[7:0], unneeded_carry0, data_operandA[7:0], data_operandB[7:0], default_c);
	
	predicted_carry p_carry0(carry0, data_operandA[7:0], data_operandB[7:0], default_c);
	ripple_carry_8_bit add1(sum[15:8], unneeded_carry1, data_operandA[15:8], data_operandB[15:8], carry0);
	
	predicted_carry p_carry1(carry1, data_operandA[15:8], data_operandB[15:8],carry0);
	ripple_carry_8_bit add2(sum[23:16], unneeded_carry2, data_operandA[23:16], data_operandB[23:16], carry1);
	
	predicted_carry p_carry2(carry2, data_operandA[23:16], data_operandB[23:16],carry1);
	ripple_carry_8_bit add3(sum[31:24], overflow, data_operandA[31:24], data_operandB[31:24], carry2);

endmodule

module predicted_carry(c, dataA, dataB, cin);
	
	input [7:0] dataA, dataB;
	input cin;
	output c;
	
	wire G;
	wire [7:0] Gbits;
	wire [7:0] Gcoeffs;
	wire P;
	wire [7:0] Pbits;
		
	// calculate Propagate
	genvar i;
	generate
		for(i=0; i<8; i=i+1) begin: propagate_loop
			or my_or(Pbits[i], dataA[i],dataB[i]);
		end
	endgenerate
	
	and andP(P,Pbits[0],Pbits[1],Pbits[2],Pbits[3],Pbits[4],Pbits[5],Pbits[6],Pbits[7]);
		
	// calculate Generate
	generate
		for(i=0; i<8; i=i+1) begin: generate_loop1
			and my_and(Gbits[i], dataA[i],dataB[i]);
		end
	endgenerate
	
	and and0(Gcoeffs[7], 1'b1, Gbits[7]);
	and and1(Gcoeffs[6], Pbits[7], Gbits[6]);
	and and2(Gcoeffs[5], Pbits[7], Pbits[6], Gbits[5]);
	and and3(Gcoeffs[4], Pbits[7], Pbits[6], Pbits[5], Gbits[4]);
	and and4(Gcoeffs[3], Pbits[7], Pbits[6], Pbits[5], Pbits[4], Gbits[3]);
	and and5(Gcoeffs[2], Pbits[7], Pbits[6], Pbits[5], Pbits[4], Pbits[3], Gbits[2]);
	and and6(Gcoeffs[1], Pbits[7], Pbits[6], Pbits[5], Pbits[4], Pbits[3], Pbits[2], Gbits[1]);
	and and7(Gcoeffs[0], Pbits[7], Pbits[6], Pbits[5], Pbits[4], Pbits[3], Pbits[2], Pbits[1], Gbits[0]);

	or orG(G,Gcoeffs[0],Gcoeffs[1],Gcoeffs[2],Gcoeffs[3],Gcoeffs[4],Gcoeffs[5],Gcoeffs[6],Gcoeffs[7]);

	wire PandC;
	
	and and8(PandC, P, cin);
	or or1(c, G, PandC);

endmodule


module ripple_carry_8_bit(sum, carry, dataA, dataB, carryin);
	input [7:0] dataA, dataB;
	input carryin;
	output [7:0] sum;
	output carry;
	
	wire carry0, carry1, carry2, carry3, carry4, carry5, carry6, carry7;
	
	full_adder full_adder0(sum[0], carry0, dataA[0], dataB[0], carryin);
	full_adder full_adder1(sum[1], carry1, dataA[1], dataB[1], carry0);
	full_adder full_adder2(sum[2], carry2, dataA[2], dataB[2], carry1);
	full_adder full_adder3(sum[3], carry3, dataA[3], dataB[3], carry2);
	full_adder full_adder4(sum[4], carry4, dataA[4], dataB[4], carry3);
	full_adder full_adder5(sum[5], carry5, dataA[5], dataB[5], carry4);
	full_adder full_adder6(sum[6], carry6, dataA[6], dataB[6], carry5);
	full_adder full_adder7(sum[7], carry7, dataA[7], dataB[7], carry6);

	assign carry = carry7;
	
endmodule

module full_adder(sum, carry, dataA, dataB, carryin);
	input dataA, dataB, carryin;
	output sum, carry;
	
	xor my_xor(sum, dataA, dataB, carryin);
	
	wire AandB;
	and and_1(AandB, dataA, dataB);
	
	wire AorB;
	or or_1(AorB, dataA, dataB);
	
	wire AorBandCin;
	and and_2(AorBandCin, AorB, carryin);
	
	or or_2(carry, AandB, AorBandCin);
	
endmodule

// LEFT SHIFT SECTION

module n_bit_shifter_left(shifted_data,data_operandA, ctrl_shiftamt);
	input [31:0] data_operandA;	
	input [4:0] ctrl_shiftamt;

	output [31:0] shifted_data;
	
	wire [31:0] selected_16, selected_8, selected_4, selected_2, selected_1;
	wire [31:0] shifted_16, shifted_8, shifted_4, shifted_2, shifted_1;

	
	shift_16 my_shift_16(shifted_16, data_operandA);	
	MUX_2_1 select16(selected_16, data_operandA, shifted_16, ctrl_shiftamt[4]);
	
	shift_8	my_shift_8(shifted_8, selected_16);
	MUX_2_1 select8(selected_8, selected_16 ,shifted_8, ctrl_shiftamt[3]);

	shift_4	my_shift_4(shifted_4, selected_8);
	MUX_2_1 select4(selected_4, selected_8 ,shifted_4, ctrl_shiftamt[2]);

	shift_2	my_shift_2(shifted_2, selected_4);
	MUX_2_1 select2(selected_2, selected_4 ,shifted_2, ctrl_shiftamt[1]);
	
	shift_1	my_shift_1(shifted_1, selected_2);
	MUX_2_1 select1(selected_1, selected_2 ,shifted_1, ctrl_shiftamt[0]);
	assign shifted_data = selected_1;

	
endmodule

module MUX_2_1(out, inputA, inputB, select_bit); //TEST THIS OUT MAYBE
	input [31:0] inputA, inputB;
	input select_bit;
	output [31:0] out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule

module shift_16(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 16;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=(31-n); i>=0; i=i-1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i+n] = in[i];
		end
	endgenerate
	
	generate
		for(i=0; i<n; i=i+1) begin: fill_zeros_loop 
			assign out[i] = 0;
		end
	endgenerate

endmodule

module shift_8(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 8;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=(31-n); i>=0; i=i-1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i+n] = in[i];
		end
	endgenerate
	generate
		for(i=0; i<n; i=i+1) begin: fill_zeros_loop 
			assign out[i] = 0;
		end
	endgenerate

endmodule

module shift_4(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 4;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=(31-n); i>=0; i=i-1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i+n] = in[i];
		end
	endgenerate
	
	generate
		for(i=0; i<n; i=i+1) begin: fill_zeros_loop 
			assign out[i] = 0;
		end
	endgenerate
endmodule

module shift_2(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 2;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=(31-n); i>=0; i=i-1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i+n] = in[i];
		end
	endgenerate
	
	generate
		for(i=0; i<n; i=i+1) begin: fill_zeros_loop 
			assign out[i] = 0;
		end
	endgenerate
	
endmodule

module shift_1(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 1;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=(31-n); i>=0; i=i-1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i+n] = in[i];
		end
	endgenerate
	
	generate
		for(i=0; i<n; i=i+1) begin: fill_zeros_loop 
			assign out[i] = 0;
		end
	endgenerate

endmodule

// RIGHT SHIFT SECTION

module n_bit_shifter_right(shifted_data,data_operandA, ctrl_shiftamt);
	input [31:0] data_operandA;	
	input [4:0] ctrl_shiftamt;

	output [31:0] shifted_data;
	
	wire [31:0] selected_16, selected_8, selected_4, selected_2, selected_1;
	wire [31:0] shifted_16, shifted_8, shifted_4, shifted_2, shifted_1;

	
	shift_16_r my_shift_16(shifted_16, data_operandA);	
	MUX_2_1 select16(selected_16, data_operandA, shifted_16, ctrl_shiftamt[4]);
	
	shift_8_r	my_shift_8(shifted_8, selected_16);
	MUX_2_1 select8(selected_8, selected_16 ,shifted_8, ctrl_shiftamt[3]);

	shift_4_r	my_shift_4(shifted_4, selected_8);
	MUX_2_1 select4(selected_4, selected_8 ,shifted_4, ctrl_shiftamt[2]);
	
	shift_2_r	my_shift_2(shifted_2, selected_4);
	MUX_2_1 select2(selected_2, selected_4 ,shifted_2, ctrl_shiftamt[1]);
	
	shift_1_r	my_shift_1(shifted_1, selected_2);
	MUX_2_1 select1(selected_1, selected_2 ,shifted_1, ctrl_shiftamt[0]);
	
	assign shifted_data = selected_1;

endmodule

module shift_16_r(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 16;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=0; i<31-n; i=i+1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i] = in[i+n];
		end
	endgenerate
	
	generate
		for(i=0; i<=n; i=i+1) begin: fill_MSB_loop 
			assign out[31-i] = in[31]; // set everything equal to the MSB
		end
	endgenerate

endmodule

module shift_8_r(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 8;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=0; i<31-n; i=i+1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i] = in[i+n];
		end
	endgenerate
	
	generate
		for(i=0; i<=n; i=i+1) begin: fill_MSB_loop 
			assign out[31-i] = in[31]; // set everything equal to the MSB
		end
	endgenerate

endmodule

module shift_4_r(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 4;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=0; i<31-n; i=i+1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i] = in[i+n];
		end
	endgenerate
	
	generate
		for(i=0; i<=n; i=i+1) begin: fill_MSB_loop 
			assign out[31-i] = in[31]; // set everything equal to the MSB
		end
	endgenerate
endmodule

module shift_2_r(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 2;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=0; i<31-n; i=i+1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i] = in[i+n];
		end
	endgenerate
	
	generate
		for(i=0; i<=n; i=i+1) begin: fill_MSB_loop 
			assign out[31-i] = in[31]; // set everything equal to the MSB
		end
	endgenerate
	
endmodule

module shift_1_r(out, in);
	input [31:0] in;
	output [31:0] out;
	
	parameter n = 1;
	
	genvar i;
	generate
	// do highest index - n times
		for(i=0; i<31-n; i=i+1) begin: shift_loop 
			// start at highest index, and assign it to equal highest index - n
			assign out[i] = in[i+n];
		end
	endgenerate
	
	generate
		for(i=0; i<=n; i=i+1) begin: fill_MSB_loop 
			assign out[31-i] = in[31]; // set everything equal to the MSB
		end
	endgenerate

endmodule

module DECODER5_32(out, select, enable);
	input [4:0] select;  //select = which register you're using
	input enable;
	output [31:0] out;   //out = 32 bits of output, with only one 1
	
	wire [2:0] decoder3_8_select;
	assign decoder3_8_select = select[2:0];
	
	wire enable0, enable1, enable2, enable3;
	
	and and0(enable0,~select[3],~select[4],enable);
	and and1(enable1,select[3],~select[4],enable);
	and and2(enable2,~select[3],select[4],enable);
	and and3(enable3,select[3],select[4],enable);
	
	DECODER3_8 decoder0(out[7:0],decoder3_8_select, enable0);
	DECODER3_8 decoder1(out[15:8],decoder3_8_select, enable1);
	DECODER3_8 decoder2(out[23:16],decoder3_8_select, enable2);
	DECODER3_8 decoder3(out[31:24],decoder3_8_select, enable3);
	
endmodule

module DECODER3_8(out, select, enable);
	input [2:0] select;
	input enable;
	output [7:0] out;
	
	and and0(out[0],~select[0], ~select[1], ~select[2], enable);
	and and1(out[1],select[0], ~select[1], ~select[2], enable);
	and and2(out[2],~select[0], select[1], ~select[2], enable);
	and and3(out[3],select[0], select[1], ~select[2], enable);
	and and4(out[4],~select[0], ~select[1], select[2], enable);
	and and5(out[5],select[0], ~select[1], select[2], enable);
	and and6(out[6],~select[0], select[1], select[2], enable);
	and and7(out[7],select[0], select[1], select[2], enable);

endmodule

/** MULTDIV **/

module multdiv(data_operandA, data_operandB, ctrl_MULT,
ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
	input [31:0] data_operandA, data_operandB;
	input ctrl_MULT, ctrl_DIV, clock;
	output [31:0] data_result;
	output data_exception, data_resultRDY;
	
	wire updated_optype, old_optype, updated_optype_mult;
	
	// 0 represents multiply, 1 represents divide
	wire reset;
	assign reset = 1'b0;
	wire preset;
	assign preset = 1'b0;
	dff store_optype(.d(updated_optype), .clk(clock), .q(old_optype), .clrn(~reset), .prn(~preset));
	
	// set up count
	wire[4:0] count;
	wire ctrl_asserted;
	or or0 (ctrl_asserted, ctrl_MULT, ctrl_DIV);
	counter32 myCounter(clock, ctrl_asserted, count);
	
	// if ctrl_MULT or ctrl_DIV was asserted, set the new_optype in the DFF
	assign updated_optype_mult = ctrl_MULT ? 1'b0 : old_optype ;
	assign updated_optype = ctrl_DIV ? 1'b1 : updated_optype_mult;
	
	// Call multiplier
	wire [31:0] product;
	wire data_exception_MULT, data_resultRDY_MULT;
	Multiplier multiply(data_operandA, data_operandB, ctrl_MULT, clock, product, data_exception_MULT, data_resultRDY_MULT, count);
	
	// Call divider
	wire [31:0] quotient;
	wire data_exception_DIV, data_resultRDY_DIV;
	Divider divide(data_operandA, data_operandB, ctrl_DIV, clock, quotient, data_exception_DIV, data_resultRDY_DIV, count);
	
	// for now just assign 0 to data exceptions	
	assign data_exception = updated_optype ? data_exception_DIV : data_exception_MULT;
	
	// Choose which you want to return (only matters when data_resultRDY)
	MUX_2_1_32bit choose_result(data_result, product, quotient, updated_optype);
	assign data_resultRDY = updated_optype ? data_resultRDY_DIV : data_resultRDY_MULT;

endmodule

module Multiplier(original_multiplicand, original_multiplier, ctrl_MULT, clock, data_result, data_exception, data_resultRDY, count);
	input clock, ctrl_MULT;
	input [4:0] count;
	input [31:0] original_multiplicand, original_multiplier;
	output data_resultRDY, data_exception;
	output [31:0] data_result;
	
	// set multiplicand and multiplier properly
	wire [31:0] multiplicand, multiplier;
	wire [31:0] n_multiplicand, n_multiplier;
	
	// negate multiplicand 
	NEGATER neg1(n_multiplicand, original_multiplicand);
	
	// negate multiplier
	NEGATER neg2(n_multiplier, original_multiplier);
	
	// switch multiplier if it's negative
	MUX_2_1_32bit switch_if_neg1( multiplier, original_multiplier, n_multiplier, original_multiplier[31]);
	
	// switch multiplicand if multiplier is negative
	MUX_2_1_32bit switch_if_neg2( multiplicand, original_multiplicand, n_multiplicand, original_multiplier[31]);
	
	// set whether or not assert ready has been called in this cycle
	wire RDY_called, RDY_called_prev;
	wire preset;
	assign preset = 1'b0;
	dff store_optype(.d(RDY_called), .clk(clock), .q(RDY_called_prev), .clrn(~ctrl_MULT), .prn(~preset));

	
	// set initial value
	wire [63:0] initial_value;
	assign initial_value[63:32] = 32'b0;
	assign initial_value[31:0] = multiplier;
	
	// get prev value from reg
	wire [63:0] reg_writedata;
	wire [63:0] reg_outputdata;	
	REGISTER_64 myReg(clock, reg_writedata, 1'b1, 1'b0 , reg_outputdata);
	
	// get updated MSB 32 bits by summing multicplicand with current 32 bits
	wire [31:0] sum_with_multiplicand;
	wire count_is_not_zero;
	wire count_is_zero;
	or(count_is_not_zero, count[0], count[1], count[2], count[3], count[4]);
	not(count_is_zero, count_is_not_zero);
	MUX_2_1_32bit sum_mux_32bit(sum_with_multiplicand, reg_outputdata[63:32], initial_value[63:32], count_is_zero);
	
	wire [31:0] sum_32;
	wire overflow;
	adder adder_sum32(sum_32, overflow, sum_with_multiplicand, multiplicand);
	
	// choose which product you want to add the new sum to
	wire [63:0] last_full_product;
	MUX_2_1_64bit sum_mux_64bit(last_full_product, reg_outputdata, initial_value, count_is_zero);
	
	// attain full sum finally
	wire [63:0] sum_64;
	assign sum_64[63:32] = sum_32[31:0];
	assign sum_64[31:0] = last_full_product[31:0];
	
	// if LSB of last full product was 1, then choose the summed versus previous output to shift 
	wire LSB;
	assign LSB = last_full_product[0];
	
	wire [63:0] selected_to_shift;
	MUX_2_1_64bit select_to_shift(selected_to_shift, last_full_product, sum_64, LSB);
	
	// shift the final version to the right by 1
	wire [63:0] shifted;
	//assign shifted = selected_to_shift >>> 1; 
	assign shifted[62:0] = selected_to_shift[63:1];
	assign shifted[63] = selected_to_shift[63];
	
	//assign the shifted output to the writedata of your register	
	assign reg_writedata = shifted;
		
	// update the data result to the 32 LSB's of output
	assign data_result = shifted[31:0];
	
	// update the resultRDY bit if applicable
	wire count_is_32, RDY_not_yet_called, set_result_RDY;
	and(count_is_32, count[0], count[1], count[2], count[3], count[4]);
	not(RDY_not_yet_called, RDY_called_prev);
	and set_result_RDY_and(set_result_RDY, RDY_not_yet_called, count_is_32);
	assign data_resultRDY = set_result_RDY ? 1'b1 : 1'b0;
	assign RDY_called = RDY_called_prev ? 1'b1 : set_result_RDY;
	
	// do exception handling
	
	// and on first 33 bits
	wire all_one;
	andbits33 and33_1(all_one, reg_writedata[63:31]);
	
	wire all_zero;
	wire [32:0] flipped_33;
	not33 not33gate(flipped_33, reg_writedata[63:31]);
	andbits33 and33_2(all_zero, flipped_33);

	// and on first 33 bits flipped
	wire no_data_exception;
	or either_one_or_zero(no_data_exception, all_one, all_zero);
	not not_gate(data_exception, no_data_exception);
	
endmodule

module NEGATER(outputdata, inputdata);
	input [31:0] inputdata;
	output [31:0] outputdata;

	wire [31:0] n_inputdata;
	not32 not_gate(n_inputdata, inputdata);
	
	wire overflow;
	adder my_adder(outputdata, overflow, n_inputdata, 32'd1);
	
endmodule

module REGISTER_64(clock, writedata, we, reset, outputdata);
	input [63:0] writedata;
	input clock, we, reset;
	output [63:0] outputdata;
		
	wire preset, clrn, prn;
	assign preset = 0; // preset always off
	assign clrn = ~reset;
	assign prn = ~preset;

	// Generate 64 dffe's
	genvar i;
	generate
		for(i=0; i<64; i=i+1) begin: loop 
			dffe a_dffe(.d(writedata[i]), .clk(clock), .clrn(clrn), .prn(prn),.ena(we), .q(outputdata[i]));
		end
	endgenerate
	
endmodule

module Divider(original_dividend, original_divisor, ctrl_DIV, clock, quotient, data_exception, data_resultRDY, count);
	input clock, ctrl_DIV;
	input [4:0] count;
	input [31:0] original_dividend, original_divisor;
	output data_resultRDY, data_exception;
	output [31:0] quotient;
	
	// set up registers
	wire [31:0] reg_writedata_RQB, reg_outputdata_RQB;
	wire [31:0] reg_writedata_quotient, reg_outputdata_quotient;
	
	// register you will write the new RQB from and read the old RQB from
	REGISTER_32 myReg_RQB(clock, reg_writedata_RQB, 1'b1, 1'b0 , reg_outputdata_RQB);
	REGISTER_32 myReg_quotient(clock, reg_writedata_quotient, 1'b1, 1'b0 , reg_outputdata_quotient);
	
	// change sign if needed
	wire [31:0] reverse_sign_dividend, reverse_sign_divisor;
	NEGATER negate_dividend(reverse_sign_dividend, original_dividend);
	NEGATER negate_divisor(reverse_sign_divisor, original_divisor);
	
	wire [31:0] dividend, divisor;
	MUX_2_1_32bit choose_dividend(dividend, original_dividend, reverse_sign_dividend, original_dividend[31]);
	MUX_2_1_32bit choose_divisor(divisor, original_divisor, reverse_sign_divisor, original_divisor[31]);
	
	// look for exception right away
	wire divisor_zero;
	is_zero div_zero(divisor_zero, divisor);
	assign data_exception = divisor_zero ? 1'b1 : 1'b0;
	
	// set whether or not assert ready has been called in this cycle
	wire RDY_called, RDY_called_prev;
	wire preset;
	assign preset = 1'b0;
	dff store_optype(.d(RDY_called), .clk(clock), .q(RDY_called_prev), .clrn(~ctrl_DIV), .prn(~preset));
	
	// keep count to determine how much to shift / subtract by, etc
	wire [31:0] SE_count, SE_n;
	
	assign SE_count[4:0] = count;
	assign SE_count[31:5] = 27'b0; 
	
	wire n_overflow;
	
	subtracter n_calc(SE_n, n_overflow, 32'd31, SE_count);

	wire [4:0] n;
	assign n = SE_n[4:0];
	
	wire [31:0] RQB;
	wire [31:0] prev_quotient;

	// if it's the first iteration (n=31), set RQB to be the dividend, otherwise choose reg output (aka prev RQB)
	wire is_first_iteration;
	and first_iteration(is_first_iteration, n[4], n[3], n[2], n[1], n[0]);
	
	MUX_2_1_32bit select_RQB(RQB, reg_outputdata_RQB, dividend, is_first_iteration);
	MUX_2_1_32bit select_quotient(prev_quotient, reg_outputdata_quotient, 32'd0 , is_first_iteration); // set quotient to be zero intially
	
	// shift RQB by n
	
	wire [31:0] shifted_RQB;
	n_bit_shifter_right shift_RQB(shifted_RQB, RQB, n);
	
	// compare divisor w/ shifted RQB -> if divisor is less than or equal to the shifted RQB, assign 1 to the wire
	wire divisor_LT_or_EQ_to_RQB, unused_comp_overflow;
	wire less_than, equal_to;
	wire [31:0] unused_sub_output;
	comparator compare_div_and_shiftedRQB(less_than, equal_to, divisor, shifted_RQB);
	
	or less_than_or_equal_to(divisor_LT_or_EQ_to_RQB, less_than, equal_to);

	//if divisor_LT_or_EQ_to_RQB == 1, set bit n of quotient to be 1, otherwise set it to be 0, aka add 32'b1 shifted by n to quotient
	
	// shift 32'b1 by n
	wire [31:0] quotient_with_bit_one;
	n_bit_shifter_left shift_one(quotient_with_bit_one, 32'b1, n);
	//assign quotient_with_bit_one = 32'b1 << n;
	
	wire sum_overflow;
	wire [31:0] quotient_with_bit_one_added;
	adder add_to_quotient(quotient_with_bit_one_added, sum_overflow, quotient_with_bit_one, prev_quotient);

	//MUX_2_1_32bit choose_quotient(reg_writedata_quotient, prev_quotient, quotient_with_bit_one_added, divisor_LT_or_EQ_to_RQB);
	
	// make sure you have the correct sign for the quotient
	wire negate_quotient;
	xor xor1(negate_quotient, original_dividend[31], original_divisor[31]);
	wire [31:0] reverse_sign_quotient;
	NEGATER negate_quotient_gate(reverse_sign_quotient, reg_writedata_quotient);
	MUX_2_1_32bit choose_sign(quotient, reg_writedata_quotient, reverse_sign_quotient, negate_quotient);
	
	//if divisor_LT_or_EQ_to_RQB == 1, subtract divisor << n from the RQB
	wire [31:0] shifted_divisor;
	n_bit_shifter_left shift_divisor(shifted_divisor, divisor, n);
	//n_bit_shifter_right shift_divisor(shifted_divisor, divisor, count);
	
	wire sub_shiftedRQB_overflow;
	wire [31:0] RQB_subtracted;
	
	subtracter subtract_shiftedRQB(RQB_subtracted, sub_shiftedRQB_overflow, RQB, shifted_divisor);
	
	MUX_2_1_32bit choose_RQB(reg_writedata_RQB, RQB, RQB_subtracted, divisor_LT_or_EQ_to_RQB);
	
	// just a little experiment
	MUX_2_1_32bit choose_quotient(reg_writedata_quotient, prev_quotient, quotient_with_bit_one_added, divisor_LT_or_EQ_to_RQB);

	// update data_resultRDY
	wire n_is_0, neg_n_is_0, RDY_not_yet_called, set_result_RDY;
	or(neg_n_is_0,n[0], n[1], n[2], n[3], n[4]);
	not(n_is_0, neg_n_is_0);
	not(RDY_not_yet_called, RDY_called_prev);
	and set_result_RDY_and(set_result_RDY, RDY_not_yet_called, n_is_0);
	assign data_resultRDY = set_result_RDY ? 1'b1 : 1'b0;
	assign RDY_called = RDY_called_prev ? 1'b1 : set_result_RDY;
	
endmodule

module is_zero(out, in);
	input [31:0] in;
	output out;
	
	wire not_zero;
	or or_equal(not_zero, in[31],in[30],in[29],in[28],
	in[27],in[26],in[25],in[24],in[23],
	in[22],in[21],in[20],in[19],in[18],
	in[17],in[16],in[15],in[14],in[13],
	in[12],in[11],in[10],in[9],in[8],
	in[7],in[6],in[5],in[4],in[3],
	in[2],in[1],in[0]);
	
	not(out, not_zero);
	
endmodule

module REGISTER_32(clock, writedata, we, reset, outputdata);
	input [31:0] writedata;
	input clock, we, reset;
	output [31:0] outputdata;
		
	wire preset, clrn, prn;
	assign preset = 0; // preset always off
	assign clrn = ~reset;
	assign prn = ~preset;

	// Generate 32 dffe's
	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin: loop 
			dffe a_dffe(.d(writedata[i]), .clk(clock), .clrn(clrn), .prn(prn),.ena(we), .q(outputdata[i]));
		end
	endgenerate
	
endmodule

module counter32(clock, reset, out);
	input clock, reset;
	output [4:0] out;
	
	reg [4:0] next;
	
	wire preset;
	assign preset = 1'b0;
	
	dff dff0(.d(next[0]), .clk(clock), .q(out[0]), .clrn(~reset), .prn(~preset));
	dff dff1(.d(next[1]), .clk(clock), .q(out[1]), .clrn(~reset), .prn(~preset));
	dff dff2(.d(next[2]), .clk(clock), .q(out[2]), .clrn(~reset), .prn(~preset));
	dff dff3(.d(next[3]), .clk(clock), .q(out[3]), .clrn(~reset), .prn(~preset));
	dff dff4(.d(next[4]), .clk(clock), .q(out[4]), .clrn(~reset), .prn(~preset));
	
	always@(*) begin
		casex({reset, out})
			6'b1xxxxx: next = 0;
			6'd0: next = 1;
			6'd1: next = 2;
			6'd2: next = 3;
			6'd3: next = 4;
			6'd4: next = 5;
			6'd5: next = 6;
			6'd6: next = 7;
			6'd7: next = 8;
			6'd8: next = 9;
			6'd9: next = 10;
			6'd10: next = 11;
			6'd11: next = 12;
			6'd12: next = 13;
			6'd13: next = 14;
			6'd14: next = 15;
			6'd15: next = 16;
			6'd16: next = 17;
			6'd17: next = 18;
			6'd18: next = 19;
			6'd19: next = 20;
			6'd20: next = 21;
			6'd21: next = 22;
			6'd22: next = 23;
			6'd23: next = 24;
			6'd24: next = 25;
			6'd25: next = 26;
			6'd26: next = 27;
			6'd27: next = 28;
			6'd28: next = 29;
			6'd29: next = 30;
			6'd30: next = 31;
			6'd31: next = 31;
			default: next = 0;
		endcase
	end
	
endmodule

module MUX_2_1_64bit(out, inputA, inputB, select_bit);
	input [63:0] inputA, inputB;
	input select_bit;
	output [63:0] out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule

module comparator(less_than, equal_to, data_operandA, data_operandB);
	input [31:0] data_operandA, data_operandB;
	output less_than, equal_to;
	
	// find difference
	wire [31:0] difference;
	wire overflow;
	subtracter sub(difference, overflow, data_operandA, data_operandB);
	
	// equal_to
	wire n_equal_to;
	or or_equal(n_equal_to, difference[31],difference[30],difference[29],difference[28],
	difference[27],difference[26],difference[25],difference[24],difference[23],
	difference[22],difference[21],difference[20],difference[19],difference[18],
	difference[17],difference[16],difference[15],difference[14],difference[13],
	difference[12],difference[11],difference[10],difference[9],difference[8],
	difference[7],difference[6],difference[5],difference[4],difference[3],
	difference[2],difference[1],difference[0]);
	
	not not_eq(equal_to, n_equal_to);
	
	// less than
	wire AnegBpos, AposBpos, AnegBneg, notOriginalA, notOriginalB, AposBposAsubBneg, AnegBnegAsubBneg;
	
	not not_lt_0(notOriginalB, data_operandB[31]);
	not not_lt_1(notOriginalA, data_operandA[31]);
	
	and and_lt_0(AnegBpos,data_operandA[31],notOriginalB);
	and and_lt_1(AposBpos, notOriginalA, notOriginalB);
	and and_lt_2(AnegBneg, data_operandA[31], data_operandB[31]);
	
	and and_lt_3(AposBposAsubBneg, AposBpos, difference[31]);
	and and_lt_4(AnegBnegAsubBneg, AnegBneg, difference[31]);
	
	or or_lt_0(less_than, AnegBpos, AposBposAsubBneg,AnegBnegAsubBneg);
	
endmodule

module comparator_5bit(less_than, equal_to, data_operandA, data_operandB);
	input [4:0] data_operandA, data_operandB;
	output less_than, equal_to;
	
	// extend operand A and B
	wire [31:0] data_operandA_extended, data_operandB_extended;
	assign data_operandA_extended[31:5] = 27'd0;
	assign data_operandA_extended[4:0] = data_operandA;
	assign data_operandB_extended[31:5] = 27'd0;
	assign data_operandB_extended[4:0] = data_operandB;
	
	// find difference
	wire [31:0] difference;
	wire overflow;
	subtracter sub(difference, overflow, data_operandA_extended, data_operandB_extended);
	
	// equal_to
	wire n_equal_to;
	or or_equal(n_equal_to, difference[31],difference[30],difference[29],difference[28],
	difference[27],difference[26],difference[25],difference[24],difference[23],
	difference[22],difference[21],difference[20],difference[19],difference[18],
	difference[17],difference[16],difference[15],difference[14],difference[13],
	difference[12],difference[11],difference[10],difference[9],difference[8],
	difference[7],difference[6],difference[5],difference[4],difference[3],
	difference[2],difference[1],difference[0]);
	
	not not_eq(equal_to, n_equal_to);
	
	// less than
	wire AnegBpos, AposBpos, AnegBneg, notOriginalA, notOriginalB, AposBposAsubBneg, AnegBnegAsubBneg;
	
	not not_lt_0(notOriginalB, data_operandB_extended[31]);
	not not_lt_1(notOriginalA, data_operandA_extended[31]);
	
	and and_lt_0(AnegBpos,data_operandA_extended[31],notOriginalB);
	and and_lt_1(AposBpos, notOriginalA, notOriginalB);
	and and_lt_2(AnegBneg, data_operandA_extended[31], data_operandB_extended[31]);
	
	and and_lt_3(AposBposAsubBneg, AposBpos, difference[31]);
	and and_lt_4(AnegBnegAsubBneg, AnegBneg, difference[31]);
	
	or or_lt_0(less_than, AnegBpos, AposBposAsubBneg,AnegBnegAsubBneg);
	
endmodule

module subtracter(difference, overflow, data_operandA, data_operandB);
	input [31:0] data_operandA, data_operandB;
	output [31:0] difference;
	output overflow;
	
	// negate operandB
	wire [31:0] negated_operandB;
	NEGATER negate(negated_operandB, data_operandB);
	
	// add the two
	adder add(difference, overflow, data_operandA, negated_operandB);
	
endmodule

module andbits33(out, in);
	input [32:0] in;
	output out;
	
	and my_and(out, in[32], in[31], in[30], in[29],
	in[28],in[27],in[26],in[25],in[24],
	in[23],in[22],in[21],in[20],in[19],
	in[18],in[17],in[16],in[15],in[14],
	in[13],in[12],in[11],in[10],in[9],
	in[8],in[7],in[6],in[5],in[4],
	in[3],in[2],in[1],in[0]);
	

endmodule

// FULL NEGATE 33 BITS
module not33(negated, in);
	input [32:0] in;
	output [32:0] negated;
	
	genvar i;
	generate
		for(i=0; i<33; i=i+1) begin: negate_loop 
			not a_not(negated[i], in[i]);
		end
	endgenerate

endmodule

/** MUXES **/

module MUX_2_1_32bit(out, inputA, inputB, select_bit);
	input [31:0] inputA, inputB;
	input select_bit;
	output [31:0] out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule

module MUX_2_1_5bit(out, inputA, inputB, select_bit);
	input [4:0] inputA, inputB;
	input select_bit;
	output [4:0] out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule

module MUX_2_1_4bit(out, inputA, inputB, select_bit);
	input [3:0] inputA, inputB;
	input select_bit;
	output [3:0] out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule

module MUX_2_1_1bit(out, inputA, inputB, select_bit);
	input inputA, inputB;
	input select_bit;
	output out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule

module MUX_2_1_12bit(out, inputA, inputB, select_bit);
	input [11:0] inputA, inputB;
	input select_bit;
	output [11:0] out;	
	
	assign out = select_bit ? inputB : inputA ;

endmodule