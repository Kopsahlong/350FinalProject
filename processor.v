module processor(clock, reset, ps2_key_pressed, ps2_out, score, dmem_data_in, dmem_address, dmem_out, good_bad,
	index0,  index1,  index2,  index3,  index4,  index5,  index6,  index7,  index8,  index9,
	index10, index11, index12, index13, index14, index15, index16, index17, index18, index19,
	index20, index21, index22, index23, index24, index25, index26, index27, index28, index29);

	input clock, reset, ps2_key_pressed;
	input [7:0] ps2_out;

	output [3:0] index0,  index1,  index2,  index3,  index4,  index5,  index6,  index7,  index8,  index9;
	output [3:0] index10, index11, index12, index13, index14, index15, index16, index17, index18, index19;
	output [3:0] index20, index21, index22, index23, index24, index25, index26, index27, index28, index29;
	
	output [9:0] score;
	output [1:0] good_bad;
	output [31:0] dmem_data_in, dmem_out;
	output [11:0] dmem_address;

	// - - -  WIRES  - - - //
		// GLOBAL WIRES
		wire [4:0]rstatus, ra;
		assign rstatus = 5'd30;
		assign ra = 5'd31;
		wire [31:0] noop_instruction;
		assign noop_instruction = 32'b0;
		// LOGIC WIRES
		wire stall, flush;
		// INSTRUCTION WIRES _FS
		wire [31:0] instruction_FS;
		wire [4:0] opcode_FS, rd_FS, rs_FS, rt_FS, shamt_FS, ALU_op_FS;
		wire [31:0] immediate_FS, target_FS;
		wire add_isa_FS, addi_isa_FS, sub_isa_FS, and_isa_FS, or_isa_FS, sll_isa_FS, sra_isa_FS, mul_isa_FS, div_isa_FS, sw_isa_FS, lw_isa_FS, j_isa_FS, bne_isa_FS, jal_isa_FS, jr_isa_FS, blt_isa_FS, bex_isa_FS, setx_isa_FS;
		// INSTRUCTION WIRES _DS
		wire [31:0] instruction_DS;
		wire [4:0] opcode_DS, rd_DS, rs_DS, rt_DS, shamt_DS, ALU_op_DS;
		wire [31:0] immediate_DS, target_DS;
		wire add_isa_DS, addi_isa_DS, sub_isa_DS, and_isa_DS, or_isa_DS, sll_isa_DS, sra_isa_DS, mul_isa_DS, div_isa_DS, sw_isa_DS, lw_isa_DS, j_isa_DS, bne_isa_DS, jal_isa_DS, jr_isa_DS, blt_isa_DS, bex_isa_DS, setx_isa_DS;
		// INSTRUCTION WIRES _XS
		wire [31:0] instruction_XS;
		wire [4:0] opcode_XS, rd_XS, rs_XS, rt_XS, shamt_XS, ALU_op_XS;
		wire [31:0] immediate_XS, target_XS;
		wire add_isa_XS, addi_isa_XS, sub_isa_XS, and_isa_XS, or_isa_XS, sll_isa_XS, sra_isa_XS, mul_isa_XS, div_isa_XS, sw_isa_XS, lw_isa_XS, j_isa_XS, bne_isa_XS, jal_isa_XS, jr_isa_XS, blt_isa_XS, bex_isa_XS, setx_isa_XS;
		// INSTRUCTION WIRES _MS
		wire [31:0] instruction_MS;
		wire [4:0] opcode_MS, rd_MS, rs_MS, rt_MS, shamt_MS, ALU_op_MS;
		wire [31:0] immediate_MS, target_MS;
		wire add_isa_MS, addi_isa_MS, sub_isa_MS, and_isa_MS, or_isa_MS, sll_isa_MS, sra_isa_MS, mul_isa_MS, div_isa_MS, sw_isa_MS, lw_isa_MS, j_isa_MS, bne_isa_MS, jal_isa_MS, jr_isa_MS, blt_isa_MS, bex_isa_MS, setx_isa_MS;
		// INSTRUCTION WIRES _WS
		wire [31:0] instruction_WS;
		wire [4:0] opcode_WS, rd_WS, rs_WS, rt_WS, shamt_WS, ALU_op_WS;
		wire [31:0] immediate_WS, target_WS;
		wire add_isa_WS, addi_isa_WS, sub_isa_WS, and_isa_WS, or_isa_WS, sll_isa_WS, sra_isa_WS, mul_isa_WS, div_isa_WS, sw_isa_WS, lw_isa_WS, j_isa_WS, bne_isa_WS, jal_isa_WS, jr_isa_WS, blt_isa_WS, bex_isa_WS, setx_isa_WS;
		// EXCEPTION WIRES
		wire [31:0] exception_flag_XS, exception_flag_MS, exception_flag_WS;
		wire exception_flag_hot_XS, exception_flag_hot_MS, exception_flag_hot_WS;
		// PC wires
		wire [31:0] PC_input, PC_output;
		wire [31:0] PC_plus1_FS, PC_plus1_DS, PC_plus1_XS, PC_plus1_plus_imm_XS, PC_plus1_MS, PC_plus1_WS;
		wire branch_XS, bne_branch_XS, blt_branch_XS, bex_branch_XS, rs_not_lessthan_rd, rd_less_than_rs, bex_jump;
		// REGFILE wires
		wire [31:0] regfile_RS1VAL_DS, regfile_RS1VAL_XS;
		wire [31:0] regfile_RS2VAL_DS, regfile_RS2VAL_XS, regfile_RS2VAL_MS;
		wire [31:0] regfile_DW_WS;
		wire [4:0] regfile_S1, regfile_S2, regfile_RD;
		wire regfile_WE;
		// ALU wires
		wire [31:0] ALU_input_A, ALU_input_B, regfile_RS2VAL_XS_bypassed;
		wire [31:0] ALU_output_XS, ALU_output_MS, ALU_output_WS;
		wire ALU_not_equal, ALU_less_than, ALU_overflow, ALU_mult_div_RDY, ctrl_MULT, ctrl_DIV;
		// GRADER wires
		wire [31:0] dmem_output_MS, dmem_output_WS;
		wire[31:0] debug_data;
		// EQUAL TO CHECKER WIRES
		wire rs_XS_eq_rd_MS, rs_XS_eq_rd_WS, rt_XS_eq_rd_MS, rd_XS_eq_rd_MS, rt_XS_eq_rd_WS, rs_XS_eq_r0, rt_XS_eq_r0, rd_XS_eq_r0, rd_MS_eq_rs_XS, rd_MS_eq_rt_XS;
		equal_to_checker_5b rs_XS_eq_rd_MS_checker(.is_equal(rs_XS_eq_rd_MS), .data_operandA(rs_XS), .data_operandB(rd_MS));
		equal_to_checker_5b rs_XS_eq_rd_WS_checker(.is_equal(rs_XS_eq_rd_WS), .data_operandA(rs_XS), .data_operandB(rd_WS));
		equal_to_checker_5b rt_XS_eq_rd_MS_checker(.is_equal(rt_XS_eq_rd_MS), .data_operandA(rt_XS), .data_operandB(rd_MS));
		equal_to_checker_5b rd_XS_eq_rd_MS_checker(.is_equal(rd_XS_eq_rd_MS), .data_operandA(rd_XS), .data_operandB(rd_MS));
		equal_to_checker_5b rt_XS_eq_rd_WS_checker(.is_equal(rt_XS_eq_rd_WS), .data_operandA(rt_XS), .data_operandB(rd_WS));
		equal_to_checker_5b rd_XS_eq_rd_WS_checker(.is_equal(rd_XS_eq_rd_WS), .data_operandA(rd_XS), .data_operandB(rd_WS));
		equal_to_checker_5b rs_XS_eq_r0_checker(.is_equal(rs_XS_eq_r0), .data_operandA(rs_XS), .data_operandB(5'b0));
		equal_to_checker_5b rt_XS_eq_r0_checker(.is_equal(rt_XS_eq_r0), .data_operandA(rt_XS), .data_operandB(5'b0));
		equal_to_checker_5b rd_XS_eq_r0_checker(.is_equal(rd_XS_eq_r0), .data_operandA(rd_XS), .data_operandB(5'b0));
		equal_to_checker_5b rd_MS_eq_rs_XS_checker(.is_equal(rd_MS_eq_rs_XS), .data_operandA(rd_MS), .data_operandB(rs_XS));
		equal_to_checker_5b rd_MS_eq_rt_XS_checker(.is_equal(rd_MS_eq_rt_XS), .data_operandA(rd_MS), .data_operandB(rt_XS));


	// - - - STAGE NON-SPECIFIC LOGIC - - - //

		assign flush = jr_isa_XS || branch_XS || bex_branch_XS;
		assign stall = lw_isa_MS && (rd_MS_eq_rs_XS || rd_MS_eq_rt_XS || rd_XS_eq_rd_MS);

		wire [31:0] screenIndexReg1, screenIndexReg2, screenIndexReg3;
		assign  index0 = screenIndexReg1[2:0];
		assign  index1 = screenIndexReg1[5:3];
		assign  index2 = screenIndexReg1[8:6];
		assign  index3 = screenIndexReg1[11:9];
		assign  index4 = screenIndexReg1[14:12];
		assign  index5 = screenIndexReg1[17:15];
		assign  index6 = screenIndexReg1[20:18];
		assign  index7 = screenIndexReg1[23:21];
		assign  index8 = screenIndexReg1[26:24];
		assign  index9 = screenIndexReg1[29:27];
		assign index10 = screenIndexReg2[2:0];
		assign index11 = screenIndexReg2[5:3];
		assign index12 = screenIndexReg2[8:6];
		assign index13 = screenIndexReg2[11:9];
		assign index14 = screenIndexReg2[14:12];
		assign index15 = screenIndexReg2[17:15];
		assign index16 = screenIndexReg2[20:18];
		assign index17 = screenIndexReg2[23:21];
		assign index18 = screenIndexReg2[26:24];
		assign index19 = screenIndexReg2[29:27];
		assign index20 = screenIndexReg3[2:0];
		assign index21 = screenIndexReg3[5:3];
		assign index22 = screenIndexReg3[8:6];
		assign index23 = screenIndexReg3[11:9];
		assign index24 = screenIndexReg3[14:12];
		assign index25 = screenIndexReg3[17:15];
		assign index26 = screenIndexReg3[20:18];
		assign index27 = screenIndexReg3[23:21];
		assign index28 = screenIndexReg3[26:24];
		assign index29 = screenIndexReg3[29:27];

	// - - - (F)ETCH (S)TAGE - - - //
		instruction_decoder instruction_decoder_FS(.instruction(instruction_FS), .opcode(opcode_FS), .rd(rd_FS), .rs(rs_FS), .rt(rt_FS), .shamt(shamt_FS), .ALU_op(ALU_op_FS), .immediate(immediate_FS), .target(target_FS), .add_isa(add_isa_FS), .addi_isa(addi_isa_FS), .sub_isa(sub_isa_FS), .and_isa(and_isa_FS), .or_isa(or_isa_FS), .sll_isa(sll_isa_FS), .sra_isa(sra_isa_FS), .mul_isa(mul_isa_FS), .div_isa(div_isa_FS), .sw_isa(sw_isa_FS), .lw_isa(lw_isa_FS), .j_isa(j_isa_FS), .bne_isa(bne_isa_FS), .jal_isa(jal_isa_FS), .jr_isa(jr_isa_FS), .blt_isa(blt_isa_FS), .bex_isa(bex_isa_FS), .setx_isa(setx_isa_FS));

		// - - - PC - - - //
		register_32b program_counter_register(.clock(clock), .ctrl_writeEnable(~(stall)), .ctrl_reset(reset), .data_writeReg_32b(PC_input), .data_readReg_32b(PC_output));
		
		imem myimem(.address(PC_output[11:0]), .clken(1'b1), .clock(~clock), .q(instruction_FS)); 

		wire PC_plus1_overflow_dc;
		carry_select_adder_32b PC1_adder(.data_operandA(PC_output), .data_operandB(32'b1), .sum(PC_plus1_FS), .overflow(PC_plus1_overflow_dc));

		wire set_PC_plus1_plus_imm_XS, set_PC_T_FS, set_PC_regfile_RS2VAL_XS_bypassed, set_PC_T_XS;
		assign set_PC_plus1_plus_imm_XS = branch_XS;
		assign set_PC_T_XS = bex_branch_XS;
		assign set_PC_T_FS = j_isa_FS || jal_isa_FS;
		assign set_PC_regfile_RS2VAL_XS_bypassed = jr_isa_XS;

		wire [31:0] PC_decision_1, PC_decision_2, PC_decision_3;
		assign PC_decision_1 = set_PC_T_FS ? target_FS : PC_plus1_FS;
		assign PC_decision_2 = set_PC_plus1_plus_imm_XS ? PC_plus1_plus_imm_XS : PC_decision_1;
		assign PC_decision_3 = set_PC_T_XS ? target_XS : PC_decision_2;
		assign PC_input = set_PC_regfile_RS2VAL_XS_bypassed ? regfile_RS2VAL_XS_bypassed : PC_decision_3;

		wire [31:0] instruction_FD_input;
		assign instruction_FD_input = flush ? noop_instruction : instruction_FS;


	// FD PIPELINE REGISTER
	wire pipeline_register_FD_reset;
	assign pipeline_register_FD_reset = reset;
	pipeline_register_FD my_pipeline_register_FD(.clock(clock), .stall(stall), .reset(pipeline_register_FD_reset), .PC_input(PC_plus1_FS), .PC_output(PC_plus1_DS), .IR_input(instruction_FD_input), .IR_output(instruction_DS));


	// - - - (D)ECODE (S)TAGE - - - //
		instruction_decoder instruction_decoder_DS(.instruction(instruction_DS), .opcode(opcode_DS), .rd(rd_DS), .rs(rs_DS), .rt(rt_DS), .shamt(shamt_DS), .ALU_op(ALU_op_DS), .immediate(immediate_DS), .target(target_DS), .add_isa(add_isa_DS), .addi_isa(addi_isa_DS), .sub_isa(sub_isa_DS), .and_isa(and_isa_DS), .or_isa(or_isa_DS), .sll_isa(sll_isa_DS), .sra_isa(sra_isa_DS), .mul_isa(mul_isa_DS), .div_isa(div_isa_DS), .sw_isa(sw_isa_DS), .lw_isa(lw_isa_DS), .j_isa(j_isa_DS), .bne_isa(bne_isa_DS), .jal_isa(jal_isa_DS), .jr_isa(jr_isa_DS), .blt_isa(blt_isa_DS), .bex_isa(bex_isa_DS), .setx_isa(setx_isa_DS));

		// - - - REGFILE - - - //
		regfile_32b my_regfile(.clock(~clock), .ctrl_writeEnable(regfile_WE), .ctrl_reset(reset), .ctrl_writeReg(regfile_RD), .ctrl_readRegA(regfile_S1), .ctrl_readRegB(regfile_S2), .read_score_reg(score), .data_writeReg(regfile_DW_WS), .data_readRegA(regfile_RS1VAL_DS), .data_readRegB(regfile_RS2VAL_DS), .exception_flag(exception_flag_WS), .exception_flag_hot(exception_flag_hot_WS), .ps2_key_pressed(ps2_key_pressed), .ps2_out(ps2_out), .screenIndexReg1(screenIndexReg1), .screenIndexReg2(screenIndexReg2), .screenIndexReg3(screenIndexReg3), .goodBad_reg(good_bad));
		
		// regfile S1, S2
		assign regfile_S1 = rs_DS; //S1 will always be rs
		wire regfile_S2_mux_s0, regfile_S2_mux_s1;
		or or_regfile_S2_mux_s0(regfile_S2_mux_s0, sw_isa_DS, bne_isa_DS, jr_isa_DS, blt_isa_DS);
		assign regfile_S2_mux_s1 = bex_isa_DS;
		mux_4_5b regfile_S2_mux(.out(regfile_S2), .in0(rt_DS), .in1(rd_DS), .in2(rstatus), .in3(5'b0), .s0(regfile_S2_mux_s0), .s1(regfile_S2_mux_s1));
		
		wire [31:0] instruction_DX_input;
		assign instruction_DX_input = flush ? noop_instruction : instruction_DS;

	// DX PIPELINE REGISTER
	wire pipeline_register_DX_reset, stall_DX;
	assign pipeline_register_DX_reset = reset;
	assign stall_DX = stall || ((mul_isa_XS && ~ALU_mult_div_RDY) || (div_isa_XS && ~ALU_mult_div_RDY));
	pipeline_register_DX my_pipeline_register_DX(.clock(clock), .stall(stall_DX), .reset(pipeline_register_DX_reset), .PC_input(PC_plus1_DS), .PC_output(PC_plus1_XS), .IR_input(instruction_DX_input), .IR_output(instruction_XS), .A_input(regfile_RS1VAL_DS), .A_output(regfile_RS1VAL_XS), .B_input(regfile_RS2VAL_DS), .B_output(regfile_RS2VAL_XS));


	// - - - E(X)ECUTE (S)TAGE - - - //
		instruction_decoder instruction_decoder_XS(.instruction(instruction_XS), .opcode(opcode_XS), .rd(rd_XS), .rs(rs_XS), .rt(rt_XS), .shamt(shamt_XS), .ALU_op(ALU_op_XS), .immediate(immediate_XS), .target(target_XS), .add_isa(add_isa_XS), .addi_isa(addi_isa_XS), .sub_isa(sub_isa_XS), .and_isa(and_isa_XS), .or_isa(or_isa_XS), .sll_isa(sll_isa_XS), .sra_isa(sra_isa_XS), .mul_isa(mul_isa_XS), .div_isa(div_isa_XS), .sw_isa(sw_isa_XS), .lw_isa(lw_isa_XS), .j_isa(j_isa_XS), .bne_isa(bne_isa_XS), .jal_isa(jal_isa_XS), .jr_isa(jr_isa_XS), .blt_isa(blt_isa_XS), .bex_isa(bex_isa_XS), .setx_isa(setx_isa_XS));

		// - - - ALU - - - //
		wire[4:0] actual_ALU_op;
		assign actual_ALU_op[4:3] = 2'b0;
		or actual_ALU_op_s0(actual_ALU_op[0], sub_isa_XS, bne_isa_XS, blt_isa_XS, or_isa_XS, sra_isa_XS, div_isa_XS);
		or actual_ALU_op_s1(actual_ALU_op[1], and_isa_XS, or_isa_XS, mul_isa_XS, div_isa_XS);
		or actual_ALU_op_s2(actual_ALU_op[2], sll_isa_XS, sra_isa_XS, mul_isa_XS, div_isa_XS);
		assign ctrl_MULT = mul_isa_XS && ~mul_isa_MS; //replace w dffe
		assign ctrl_DIV = div_isa_XS && ~div_isa_MS;

		alu_32b my_ALU(.clock(clock), .data_operandA(ALU_input_A), .data_operandB(ALU_input_B), .ctrl_ALUopcode(actual_ALU_op), .ctrl_shiftamt(shamt_XS), .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV), .data_result(ALU_output_XS), .isNotEqual(ALU_not_equal), .isLessThan(ALU_less_than), .overflow(ALU_overflow), .mult_div_RDY(ALU_mult_div_RDY));

		// BYPASS LOGIC
		wire ALU_output_MS_in_ALU_A, dmem_output_WS_in_ALU_A, zero_input_in_ALU_A;
		wire ALU_input_A_mux_s0, ALU_input_A_mux_s1;
		assign ALU_output_MS_in_ALU_A = rs_XS_eq_rd_MS && (add_isa_MS || addi_isa_MS || sub_isa_MS || and_isa_MS || or_isa_MS || sll_isa_MS || sra_isa_MS);
		assign dmem_output_WS_in_ALU_A = rs_XS_eq_rd_WS && (add_isa_WS || addi_isa_WS || sub_isa_WS || and_isa_WS || or_isa_WS || sll_isa_WS || sra_isa_WS || lw_isa_WS);
		assign zero_input_in_ALU_A = rs_XS_eq_r0;

		wire [31:0] ALU_input_A_decision_1, ALU_input_A_decision_2;
		assign ALU_input_A_decision_1 = dmem_output_WS_in_ALU_A ? regfile_DW_WS : regfile_RS1VAL_XS;
		assign ALU_input_A_decision_2 = ALU_output_MS_in_ALU_A ? ALU_output_MS : ALU_input_A_decision_1;
		assign ALU_input_A = zero_input_in_ALU_A ? 32'b0 : ALU_input_A_decision_2;


		wire bypass_to_rt_MS, bypass_to_rd_MS, bypass_to_rt_WS, bypass_to_rd_WS;
		wire ALU_output_MS_in_ALU_B, dmem_output_WS_in_ALU_B, zero_input_in_ALU_B, immediate_in_ALU_B;
		wire regfile_RS2VAL_XS_bypassed_mux_s0, regfile_RS2VAL_XS_bypassed_mux_s1;

		assign bypass_to_rt_MS = rt_XS_eq_rd_MS && (add_isa_MS || addi_isa_MS || sub_isa_MS || and_isa_MS || or_isa_MS || sll_isa_MS || sra_isa_MS) && (add_isa_XS || sub_isa_XS || and_isa_XS || or_isa_XS || mul_isa_XS || div_isa_XS);
		assign bypass_to_rd_MS = rd_XS_eq_rd_MS && (add_isa_MS || addi_isa_MS || sub_isa_MS || and_isa_MS || or_isa_MS || sll_isa_MS || sra_isa_MS) && (sw_isa_XS || bne_isa_XS || jr_isa_XS || blt_isa_XS);
		assign bypass_to_rt_WS = rt_XS_eq_rd_WS && (add_isa_WS || addi_isa_WS || sub_isa_WS || and_isa_WS || or_isa_WS || sll_isa_WS || sra_isa_WS || lw_isa_WS) && (add_isa_XS || sub_isa_XS || and_isa_XS || or_isa_XS || mul_isa_XS || div_isa_XS);
		assign bypass_to_rd_WS = rd_XS_eq_rd_WS && (add_isa_WS || addi_isa_WS || sub_isa_WS || and_isa_WS || or_isa_WS || sll_isa_WS || sra_isa_WS || lw_isa_WS) && (sw_isa_XS || bne_isa_XS || jr_isa_XS || blt_isa_XS);

		assign ALU_output_MS_in_ALU_B = bypass_to_rt_MS || bypass_to_rd_MS;
		assign dmem_output_WS_in_ALU_B = bypass_to_rt_WS || bypass_to_rd_WS;
		assign zero_input_in_ALU_B = (rt_XS_eq_r0 && (add_isa_XS || sub_isa_XS || and_isa_XS || or_isa_XS || mul_isa_XS || div_isa_XS)) || (rd_XS_eq_r0 && (sw_isa_XS || bne_isa_XS || jr_isa_XS || blt_isa_XS));
		assign immediate_in_ALU_B = addi_isa_XS || sw_isa_XS || lw_isa_XS;

		wire [31:0] ALU_input_B_decision_1, ALU_input_B_decision_2, ALU_input_B_decision_3, ALU_input_B_decision_4;
		assign ALU_input_B_decision_1 = dmem_output_WS_in_ALU_B ? regfile_DW_WS : regfile_RS2VAL_XS;
		assign ALU_input_B_decision_2 = ALU_output_MS_in_ALU_B ? ALU_output_MS : ALU_input_B_decision_1;
		assign ALU_input_B_decision_3 = (bex_isa_XS && exception_flag_hot_WS) ? exception_flag_WS : ALU_input_B_decision_2;
		assign ALU_input_B_decision_4 = (bex_isa_XS && exception_flag_hot_MS) ? exception_flag_MS : ALU_input_B_decision_3;
		assign regfile_RS2VAL_XS_bypassed = zero_input_in_ALU_B ? 32'b0 : ALU_input_B_decision_4;
		assign ALU_input_B = immediate_in_ALU_B ? immediate_XS : regfile_RS2VAL_XS_bypassed;


		// - - - EXCEPTION HANDLING - - - //

		wire [31:0] exception_handling_decision_1, exception_handling_decision_2, exception_handling_decision_3, exception_handling_decision_4, exception_handling_decision_5;
		assign exception_handling_decision_1 = (add_isa_XS && ALU_overflow) ? 32'd1 : 32'd0;
		assign exception_handling_decision_2 = (addi_isa_XS && ALU_overflow) ? 32'd2 : exception_handling_decision_1;
		assign exception_handling_decision_3 = (sub_isa_XS && ALU_overflow) ? 32'd3 : exception_handling_decision_2;
		assign exception_handling_decision_4 = (mul_isa_XS && ALU_overflow) ? 32'd4 : exception_handling_decision_3;
		assign exception_handling_decision_5 = (div_isa_XS && ALU_overflow) ? 32'd5 : exception_handling_decision_4;
		assign exception_flag_XS = setx_isa_XS ? target_XS : exception_handling_decision_5;

		assign exception_flag_hot_XS = setx_isa_XS || (ALU_overflow && (add_isa_XS || addi_isa_XS || sub_isa_XS || mul_isa_XS || div_isa_XS));


		// - - - PC - - - //
		wire PC_plus1_imm_overflow_dc; 
		carry_select_adder_32b PC1imm_adder(.data_operandA(PC_plus1_XS), .data_operandB(immediate_XS), .sum(PC_plus1_plus_imm_XS), .overflow(PC_plus1_imm_overflow_dc));

		assign bne_branch_XS = bne_isa_XS && ALU_not_equal;
		assign blt_branch_XS = blt_isa_XS && ALU_not_equal && (~ALU_less_than);
		assign bex_branch_XS = bex_isa_XS && ALU_not_equal;
		assign branch_XS = bne_branch_XS || blt_branch_XS;

		wire [31:0] XM_instruction_input;
		assign XM_instruction_input = stall ? noop_instruction : instruction_XS;

	// XM PIPELINE REGISTER
	wire pipeline_register_XM_reset;
	assign pipeline_register_XM_reset = reset;
	pipeline_register_XM my_pipeline_register_XM(.clock(clock), .reset(pipeline_register_XM_reset), .PC_input(PC_plus1_XS), .PC_output(PC_plus1_MS), .IR_input(XM_instruction_input), .IR_output(instruction_MS), .O_input(ALU_output_XS), .O_output(ALU_output_MS), .B_input(regfile_RS2VAL_XS_bypassed), .B_output(regfile_RS2VAL_MS), .exception_flag_input(exception_flag_XS), .exception_flag_output(exception_flag_MS), .exception_flag_hot_input(exception_flag_hot_XS), .exception_flag_hot_output(exception_flag_hot_MS));


	// - - - (M)EMORY (S)TAGE - - - //
		instruction_decoder instruction_decoder_MS(.instruction(instruction_MS), .opcode(opcode_MS), .rd(rd_MS), .rs(rs_MS), .rt(rt_MS), .shamt(shamt_MS), .ALU_op(ALU_op_MS), .immediate(immediate_MS), .target(target_MS), .add_isa(add_isa_MS), .addi_isa(addi_isa_MS), .sub_isa(sub_isa_MS), .and_isa(and_isa_MS), .or_isa(or_isa_MS), .sll_isa(sll_isa_MS), .sra_isa(sra_isa_MS), .mul_isa(mul_isa_MS), .div_isa(div_isa_MS), .sw_isa(sw_isa_MS), .lw_isa(lw_isa_MS), .j_isa(j_isa_MS), .bne_isa(bne_isa_MS), .jal_isa(jal_isa_MS), .jr_isa(jr_isa_MS), .blt_isa(blt_isa_MS), .bex_isa(bex_isa_MS), .setx_isa(setx_isa_MS));

		// GRADING WIRES
		assign dmem_address = ALU_output_MS[11:0];
		assign dmem_data_in = regfile_RS2VAL_MS;
		assign debug_data = dmem_data_in; //Q is this what you want @TAs???
		assign dmem_out = dmem_output_MS;

		dmem mydmem(	.address	(dmem_address),
						.clock		(~clock),
						.data		(dmem_data_in),
						.wren		(sw_isa_MS),
						.q			(dmem_out)
		);

	// MW PIPELINE REGISTER
	wire pipeline_register_MW_reset;
	assign pipeline_register_MW_reset = reset;
	pipeline_register_MW my_pipeline_register_MW(.clock(clock), .reset(pipeline_register_MW_reset), .PC_input(PC_plus1_MS), .PC_output(PC_plus1_WS), .IR_input(instruction_MS), .IR_output(instruction_WS), .O_input(ALU_output_MS), .O_output(ALU_output_WS), .D_input(dmem_output_MS), .D_output(dmem_output_WS), .exception_flag_input(exception_flag_MS), .exception_flag_output(exception_flag_WS), .exception_flag_hot_input(exception_flag_hot_MS), .exception_flag_hot_output(exception_flag_hot_WS));



	// - - - (W)RITEBACK (S)TAGE - - - //
		instruction_decoder instruction_decoder_WS(.instruction(instruction_WS), .opcode(opcode_WS), .rd(rd_WS), .rs(rs_WS), .rt(rt_WS), .shamt(shamt_WS), .ALU_op(ALU_op_WS), .immediate(immediate_WS), .target(target_WS), .add_isa(add_isa_WS), .addi_isa(addi_isa_WS), .sub_isa(sub_isa_WS), .and_isa(and_isa_WS), .or_isa(or_isa_WS), .sll_isa(sll_isa_WS), .sra_isa(sra_isa_WS), .mul_isa(mul_isa_WS), .div_isa(div_isa_WS), .sw_isa(sw_isa_WS), .lw_isa(lw_isa_WS), .j_isa(j_isa_WS), .bne_isa(bne_isa_WS), .jal_isa(jal_isa_WS), .jr_isa(jr_isa_WS), .blt_isa(blt_isa_WS), .bex_isa(bex_isa_WS), .setx_isa(setx_isa_WS));

		// regfile RD
		wire regfile_RD_mux_s0, regfile_RD_mux_s1;
		assign regfile_RD_mux_s0 = jal_isa_WS;
		assign regfile_RD_mux_s1 = setx_isa_WS;
		mux_4_5b regfile_RD_mux(.out(regfile_RD), .in0(rd_WS), .in1(ra), .in2(rstatus), .in3(5'b0), .s0(regfile_RD_mux_s0), .s1(regfile_RD_mux_s1));

		// write enable, data write
		or write_enableOR(regfile_WE, add_isa_WS, addi_isa_WS, sub_isa_WS, and_isa_WS, or_isa_WS, sll_isa_WS, sra_isa_WS, mul_isa_WS, div_isa_WS, lw_isa_WS, jal_isa_WS, setx_isa_WS);
		wire regfile_DW_WS_mux_s0, regfile_DW_WS_mux_s1;
		or regfile_DW_WS_mux_s0_gate(regfile_DW_WS_mux_s0, jal_isa_WS, lw_isa_WS);
		or regfile_DW_WS_mux_s1_gate(regfile_DW_WS_mux_s1, setx_isa_WS, lw_isa_WS);
		mux_4_32b regfile_DW_WS_mux(.out(regfile_DW_WS), .in0(ALU_output_WS), .in1(PC_plus1_WS), .in2(target_WS), .in3(dmem_output_WS), .s0(regfile_DW_WS_mux_s0), .s1(regfile_DW_WS_mux_s1));

endmodule

// - - - PIPELINE REGISTERS - - - //

module pipeline_register_FD(clock, stall, reset, PC_input, PC_output, IR_input, IR_output);
	input clock, stall, reset;
	input [31:0] PC_input, IR_input;
	output [31:0] PC_output, IR_output;

	register_32b PC_register(.clock(clock), .ctrl_writeEnable(~stall), .ctrl_reset(reset), .data_writeReg_32b(PC_input), .data_readReg_32b(PC_output));
	register_32b IR_register(.clock(clock), .ctrl_writeEnable(~stall), .ctrl_reset(reset), .data_writeReg_32b(IR_input), .data_readReg_32b(IR_output));
endmodule

module pipeline_register_DX(clock, stall, reset, PC_input, PC_output, IR_input, IR_output, A_input, A_output, B_input, B_output);
	input clock, stall, reset;
	input [31:0] PC_input, IR_input, A_input, B_input;
	output [31:0] PC_output, IR_output, A_output, B_output;

	register_32b PC_register(.clock(clock), .ctrl_writeEnable(~stall), .ctrl_reset(reset), .data_writeReg_32b(PC_input), .data_readReg_32b(PC_output));
	register_32b IR_register(.clock(clock), .ctrl_writeEnable(~stall), .ctrl_reset(reset), .data_writeReg_32b(IR_input), .data_readReg_32b(IR_output));
	register_32b A_register(.clock(clock), .ctrl_writeEnable(~stall), .ctrl_reset(reset), .data_writeReg_32b(A_input), .data_readReg_32b(A_output));
	register_32b B_register(.clock(clock), .ctrl_writeEnable(~stall), .ctrl_reset(reset), .data_writeReg_32b(B_input), .data_readReg_32b(B_output));
endmodule

module pipeline_register_XM(clock, reset, PC_input, PC_output, IR_input, IR_output, O_input, O_output, B_input, B_output, exception_flag_input, exception_flag_output, exception_flag_hot_input, exception_flag_hot_output);
	input clock, reset, exception_flag_hot_input;
	input [31:0] PC_input, IR_input, O_input, B_input, exception_flag_input;
	output exception_flag_hot_output;
	output [31:0] PC_output, IR_output, O_output, B_output, exception_flag_output;

	register_32b PC_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(PC_input), .data_readReg_32b(PC_output));
	register_32b IR_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(IR_input), .data_readReg_32b(IR_output));
	register_32b O_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(O_input), .data_readReg_32b(O_output));
	register_32b B_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(B_input), .data_readReg_32b(B_output));
	register_32b exception_flag_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(exception_flag_input), .data_readReg_32b(exception_flag_output));
	dffe exception_flag_hot_register(.d(exception_flag_hot_input), .clk(clock), .ena(1'b1), .prn(1'b1), .clrn(~reset), .q(exception_flag_hot_output));
endmodule

module pipeline_register_MW(clock, reset, PC_input, PC_output, IR_input, IR_output, O_input, O_output, D_input, D_output, exception_flag_input, exception_flag_output, exception_flag_hot_input, exception_flag_hot_output);
	input clock, reset, exception_flag_hot_input;
	input [31:0] PC_input, IR_input, O_input, D_input, exception_flag_input;
	output exception_flag_hot_output;
	output [31:0] PC_output, IR_output, O_output, D_output, exception_flag_output;

	register_32b PC_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(PC_input), .data_readReg_32b(PC_output));
	register_32b IR_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(IR_input), .data_readReg_32b(IR_output));
	register_32b O_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(O_input), .data_readReg_32b(O_output));
	register_32b D_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(D_input), .data_readReg_32b(D_output));
	register_32b exception_flag_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(reset), .data_writeReg_32b(exception_flag_input), .data_readReg_32b(exception_flag_output));
	dffe exception_flag_hot_register(.d(exception_flag_hot_input), .clk(clock), .ena(1'b1), .prn(1'b1), .clrn(~reset), .q(exception_flag_hot_output));
endmodule

// - - - INSTRUCTION DECODER - - - //

module instruction_decoder(instruction, opcode, rd, rs, rt, shamt, ALU_op, immediate, target, add_isa, addi_isa, sub_isa, and_isa, or_isa, sll_isa, sra_isa, mul_isa, div_isa, sw_isa, lw_isa, j_isa, bne_isa, jal_isa, jr_isa, blt_isa, bex_isa, setx_isa);
	input [31:0] instruction;
	output [4:0] opcode, rd, rs, rt, shamt, ALU_op;
	output [31:0] immediate, target;
	output add_isa, addi_isa, sub_isa, and_isa, or_isa, sll_isa, sra_isa, mul_isa, div_isa, sw_isa, lw_isa, j_isa, bne_isa, jal_isa, jr_isa, blt_isa, bex_isa, setx_isa;
	
	assign opcode = instruction[31:27];
	assign rd = instruction[26:22];
	assign rs = instruction[21:17];
	assign rt = instruction[16:12];
	assign shamt = instruction[11:7];
	assign ALU_op = instruction[6:2];
	assign target[26:0] = instruction[26:0];
	assign target[31:27] = 5'b0;
	assign immediate[16:0] = instruction[16:0];
	assign immediate[31:17] = immediate[16] ? 15'b111111111111111 : 15'b0;
	and andadd(add_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ~ALU_op[2], ~ALU_op[1], ~ALU_op[0]);
	and andaddi(addi_isa, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
	and andsub(sub_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ~ALU_op[2], ~ALU_op[1], ALU_op[0]);
	and andand(and_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ~ALU_op[2], ALU_op[1], ~ALU_op[0]);
	and andor(or_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ~ALU_op[2], ALU_op[1], ALU_op[0]);
	and andsll(sll_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ALU_op[2], ~ALU_op[1], ~ALU_op[0]);
	and andsra(sra_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ALU_op[2], ~ALU_op[1], ALU_op[0]);
	and andmul(mul_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ALU_op[2], ALU_op[1], ~ALU_op[0]);
	and anddiv(div_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0], ~ALU_op[4], ~ALU_op[3], ALU_op[2], ALU_op[1], ALU_op[0]);
	and andsw(sw_isa, ~opcode[4], ~opcode[3], opcode[2], opcode[1], opcode[0]);
	and andlw(lw_isa, ~opcode[4], opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and andj(j_isa, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], opcode[0]);
	and andbne(bne_isa, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], ~opcode[0]);
	and andjal(jal_isa, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], opcode[0]);
	and andjr(jr_isa, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], ~opcode[0]);
	and andblt(blt_isa, ~opcode[4], ~opcode[3], opcode[2], opcode[1], ~opcode[0]);
	and andbex(bex_isa, opcode[4], ~opcode[3], opcode[2], opcode[1], ~opcode[0]);
	and andsetx(setx_isa, opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
endmodule



// - - - ALU - - - //

module alu_32b(clock, data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, ctrl_MULT, ctrl_DIV, data_result, isNotEqual, isLessThan, overflow, mult_div_RDY);
	input clock, ctrl_MULT, ctrl_DIV;
	input [31:0] data_operandA, data_operandB;
	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	output [31:0] data_result;
	output isNotEqual, isLessThan, overflow, mult_div_RDY;

	wire [31:0] add_out, sub_out, and_out, or_out, sll_out, sra_out, mult_div_out;
	wire add_overflow, sub_overflow, mult_div_exception;
	carry_select_adder_32b adder0(.data_operandA(data_operandA), .data_operandB(data_operandB), .sum(add_out), .overflow(add_overflow));
	carry_select_subtracter_32b subtracter0(.data_operandA(data_operandA), .data_operandB(data_operandB), .difference(sub_out), .overflow(sub_overflow), .isNotEqual(isNotEqual), .isLessThan(isLessThan));
	and_32b and0(.data_operandA(data_operandA), .data_operandB(data_operandB), .data_result(and_out));
	or_32b or0(.data_operandA(data_operandA), .data_operandB(data_operandB), .data_result(or_out));
	sll_32b sll0(.data_operandA(data_operandA), .ctrl_shiftamt(ctrl_shiftamt), .data_result(sll_out));
	sra_32b sra0(.data_operandA(data_operandA), .ctrl_shiftamt(ctrl_shiftamt), .data_result(sra_out));
	mult_div_32b my_mult_div(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_MULT(ctrl_MULT), .ctrl_DIV(ctrl_DIV), .clock(clock), .data_result(mult_div_out), .data_exception(mult_div_exception), .data_resultRDY(mult_div_RDY));

	mux_8_32b data_result_mux(.in0(add_out), .in1(sub_out), .in2(and_out), .in3(or_out), .in4(sll_out), .in5(sra_out), .in6(mult_div_out), .in7(mult_div_out), .s0(ctrl_ALUopcode[0]), .s1(ctrl_ALUopcode[1]), .s2(ctrl_ALUopcode[2]), .out(data_result));
	mux_8_1b overflow_mux(.in0(add_overflow), .in1(sub_overflow), .in2(1'b0), .in3(1'b0), .in4(1'b0), .in5(1'b0), .in6(mult_div_exception), .in7(mult_div_exception), .s0(ctrl_ALUopcode[0]), .s1(ctrl_ALUopcode[1]), .s2(ctrl_ALUopcode[2]), .out(overflow));
endmodule


// - - - REGFILE - - - //

module regfile_32b(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, read_score_reg, data_writeReg, data_readRegA, data_readRegB, exception_flag, exception_flag_hot, ps2_key_pressed, ps2_out, screenIndexReg1, screenIndexReg2, screenIndexReg3, goodBad_reg);
	input clock, ctrl_writeEnable, ctrl_reset, exception_flag_hot, ps2_key_pressed;
	input [7:0] ps2_out;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg, exception_flag;
	output [31:0] data_readRegA, data_readRegB, screenIndexReg1, screenIndexReg2, screenIndexReg3;
	output [1:0] goodBad_reg;
	output [9:0] read_score_reg;

	wire [31:0] decoded_writeReg, decoded_readRegA, decoded_readRegB;
	decoder_32b writeDecoder(.in_5b(ctrl_writeReg), .enable(ctrl_writeEnable), .out_32b(decoded_writeReg));
	decoder_32b readDecoderA(.in_5b(ctrl_readRegA), .enable(1'b1), .out_32b(decoded_readRegA));
	decoder_32b readDecoderB(.in_5b(ctrl_readRegB), .enable(1'b1), .out_32b(decoded_readRegB));

	// 32 REGISTERS

		// clockCycle REGISTER
		wire [31:0] data_readReg_32b_1;
		register_32b register_1(.clock(clock), .ctrl_writeEnable(decoded_writeReg[1]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_1));
		assign data_readRegA = decoded_readRegA[1] ? data_readReg_32b_1 : 32'bz;
		assign data_readRegB = decoded_readRegB[1] ? data_readReg_32b_1 : 32'bz;


		// lastKeyInput REGISTER
		wire [31:0] data_readReg_32b_2;
		wire [31:0] ps2_out_32b;
		wire [31:0] ps2_register_write;
		assign ps2_out_32b[31:8] = 24'b0;
		assign ps2_out_32b[7:0] = ps2_out;
		assign ps2_register_write[31:0] = ps2_key_pressed ? ps2_out_32b : data_writeReg;
		register_32b register_2(.clock(clock), .ctrl_writeEnable(decoded_writeReg[2] || ps2_key_pressed), .ctrl_reset(ctrl_reset), .data_writeReg_32b(ps2_register_write), .data_readReg_32b(data_readReg_32b_2));
		assign data_readRegA = decoded_readRegA[2] ? data_readReg_32b_2 : 32'bz;
		assign data_readRegB = decoded_readRegB[2] ? data_readReg_32b_2 : 32'bz;


		// counterSinceLastArrow REGISTER
		wire [31:0] data_readReg_32b_3;
		register_32b register_3(.clock(clock), .ctrl_writeEnable(decoded_writeReg[3]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_3));
		assign data_readRegA = decoded_readRegA[3] ? data_readReg_32b_3 : 32'bz;
		assign data_readRegB = decoded_readRegB[3] ? data_readReg_32b_3 : 32'bz;


		// randomNumber REGISTER
		wire [31:0] data_readReg_32b_4;
		register_32b register_4(.clock(clock), .ctrl_writeEnable(decoded_writeReg[4]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_4));
		assign data_readRegA = decoded_readRegA[4] ? data_readReg_32b_4 : 32'bz;
		assign data_readRegB = decoded_readRegB[4] ? data_readReg_32b_4 : 32'bz;


		// score REGISTER
		wire [31:0] data_readReg_32b_5;
		register_32b register_5(.clock(clock), .ctrl_writeEnable(decoded_writeReg[5]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_5));
		assign data_readRegA = decoded_readRegA[5] ? data_readReg_32b_5 : 32'bz;
		assign data_readRegB = decoded_readRegB[5] ? data_readReg_32b_5 : 32'bz;
		assign read_score_reg = data_readReg_32b_5[9:0]; // always outputs current score

		// screenIndexReg1 REGISTER
		wire [31:0] data_readReg_32b_6;
		register_32b register_6(.clock(clock), .ctrl_writeEnable(decoded_writeReg[6]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_6));
		assign data_readRegA = decoded_readRegA[6] ? data_readReg_32b_6 : 32'bz;
		assign data_readRegB = decoded_readRegB[6] ? data_readReg_32b_6 : 32'bz;
		assign screenIndexReg1 = data_readReg_32b_6;

		// screenIndexReg2 REGISTER
		wire [31:0] data_readReg_32b_7;
		register_32b register_7(.clock(clock), .ctrl_writeEnable(decoded_writeReg[7]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_7));
		assign data_readRegA = decoded_readRegA[7] ? data_readReg_32b_7 : 32'bz;
		assign data_readRegB = decoded_readRegB[7] ? data_readReg_32b_7 : 32'bz;
		assign screenIndexReg2 = data_readReg_32b_7;

		// screenIndexReg3 REGISTER
		wire [31:0] data_readReg_32b_8;
		register_32b register_8(.clock(clock), .ctrl_writeEnable(decoded_writeReg[8]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_8));
		assign data_readRegA = decoded_readRegA[8] ? data_readReg_32b_8 : 32'bz;
		assign data_readRegB = decoded_readRegB[8] ? data_readReg_32b_8 : 32'bz;
		assign screenIndexReg3 = data_readReg_32b_8;

		// goodBad REGISTER
		wire [31:0] data_readReg_32b_9;
		register_32b register_9(.clock(clock), .ctrl_writeEnable(decoded_writeReg[9]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_9));
		assign data_readRegA = decoded_readRegA[9] ? data_readReg_32b_9 : 32'bz;
		assign data_readRegB = decoded_readRegB[9] ? data_readReg_32b_9 : 32'bz;
		assign goodBad_reg = data_readReg_32b_9[1:0];

		wire [31:0] data_readReg_32b_10;
		register_32b register_10(.clock(clock), .ctrl_writeEnable(decoded_writeReg[10]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_10));
		assign data_readRegA = decoded_readRegA[10] ? data_readReg_32b_10 : 32'bz;
		assign data_readRegB = decoded_readRegB[10] ? data_readReg_32b_10 : 32'bz;


		wire [31:0] data_readReg_32b_11;
		register_32b register_11(.clock(clock), .ctrl_writeEnable(decoded_writeReg[11]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_11));
		assign data_readRegA = decoded_readRegA[11] ? data_readReg_32b_11 : 32'bz;
		assign data_readRegB = decoded_readRegB[11] ? data_readReg_32b_11 : 32'bz;


		wire [31:0] data_readReg_32b_12;
		register_32b register_12(.clock(clock), .ctrl_writeEnable(decoded_writeReg[12]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_12));
		assign data_readRegA = decoded_readRegA[12] ? data_readReg_32b_12 : 32'bz;
		assign data_readRegB = decoded_readRegB[12] ? data_readReg_32b_12 : 32'bz;


		wire [31:0] data_readReg_32b_13;
		register_32b register_13(.clock(clock), .ctrl_writeEnable(decoded_writeReg[13]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_13));
		assign data_readRegA = decoded_readRegA[13] ? data_readReg_32b_13 : 32'bz;
		assign data_readRegB = decoded_readRegB[13] ? data_readReg_32b_13 : 32'bz;


		wire [31:0] data_readReg_32b_14;
		register_32b register_14(.clock(clock), .ctrl_writeEnable(decoded_writeReg[14]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_14));
		assign data_readRegA = decoded_readRegA[14] ? data_readReg_32b_14 : 32'bz;
		assign data_readRegB = decoded_readRegB[14] ? data_readReg_32b_14 : 32'bz;


		wire [31:0] data_readReg_32b_15;
		register_32b register_15(.clock(clock), .ctrl_writeEnable(decoded_writeReg[15]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_15));
		assign data_readRegA = decoded_readRegA[15] ? data_readReg_32b_15 : 32'bz;
		assign data_readRegB = decoded_readRegB[15] ? data_readReg_32b_15 : 32'bz;


		wire [31:0] data_readReg_32b_16;
		register_32b register_16(.clock(clock), .ctrl_writeEnable(decoded_writeReg[16]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_16));
		assign data_readRegA = decoded_readRegA[16] ? data_readReg_32b_16 : 32'bz;
		assign data_readRegB = decoded_readRegB[16] ? data_readReg_32b_16 : 32'bz;


		wire [31:0] data_readReg_32b_17;
		register_32b register_17(.clock(clock), .ctrl_writeEnable(decoded_writeReg[17]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_17));
		assign data_readRegA = decoded_readRegA[17] ? data_readReg_32b_17 : 32'bz;
		assign data_readRegB = decoded_readRegB[17] ? data_readReg_32b_17 : 32'bz;


		wire [31:0] data_readReg_32b_18;
		register_32b register_18(.clock(clock), .ctrl_writeEnable(decoded_writeReg[18]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_18));
		assign data_readRegA = decoded_readRegA[18] ? data_readReg_32b_18 : 32'bz;
		assign data_readRegB = decoded_readRegB[18] ? data_readReg_32b_18 : 32'bz;


		wire [31:0] data_readReg_32b_19;
		register_32b register_19(.clock(clock), .ctrl_writeEnable(decoded_writeReg[19]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_19));
		assign data_readRegA = decoded_readRegA[19] ? data_readReg_32b_19 : 32'bz;
		assign data_readRegB = decoded_readRegB[19] ? data_readReg_32b_19 : 32'bz;


		wire [31:0] data_readReg_32b_20;
		register_32b register_20(.clock(clock), .ctrl_writeEnable(decoded_writeReg[20]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_20));
		assign data_readRegA = decoded_readRegA[20] ? data_readReg_32b_20 : 32'bz;
		assign data_readRegB = decoded_readRegB[20] ? data_readReg_32b_20 : 32'bz;


		wire [31:0] data_readReg_32b_21;
		register_32b register_21(.clock(clock), .ctrl_writeEnable(decoded_writeReg[21]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_21));
		assign data_readRegA = decoded_readRegA[21] ? data_readReg_32b_21 : 32'bz;
		assign data_readRegB = decoded_readRegB[21] ? data_readReg_32b_21 : 32'bz;


		wire [31:0] data_readReg_32b_22;
		register_32b register_22(.clock(clock), .ctrl_writeEnable(decoded_writeReg[22]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_22));
		assign data_readRegA = decoded_readRegA[22] ? data_readReg_32b_22 : 32'bz;
		assign data_readRegB = decoded_readRegB[22] ? data_readReg_32b_22 : 32'bz;


		wire [31:0] data_readReg_32b_23;
		register_32b register_23(.clock(clock), .ctrl_writeEnable(decoded_writeReg[23]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_23));
		assign data_readRegA = decoded_readRegA[23] ? data_readReg_32b_23 : 32'bz;
		assign data_readRegB = decoded_readRegB[23] ? data_readReg_32b_23 : 32'bz;


		wire [31:0] data_readReg_32b_24;
		register_32b register_24(.clock(clock), .ctrl_writeEnable(decoded_writeReg[24]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_24));
		assign data_readRegA = decoded_readRegA[24] ? data_readReg_32b_24 : 32'bz;
		assign data_readRegB = decoded_readRegB[24] ? data_readReg_32b_24 : 32'bz;


		wire [31:0] data_readReg_32b_25;
		register_32b register_25(.clock(clock), .ctrl_writeEnable(decoded_writeReg[25]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_25));
		assign data_readRegA = decoded_readRegA[25] ? data_readReg_32b_25 : 32'bz;
		assign data_readRegB = decoded_readRegB[25] ? data_readReg_32b_25 : 32'bz;


		wire [31:0] data_readReg_32b_26;
		register_32b register_26(.clock(clock), .ctrl_writeEnable(decoded_writeReg[26]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_26));
		assign data_readRegA = decoded_readRegA[26] ? data_readReg_32b_26 : 32'bz;
		assign data_readRegB = decoded_readRegB[26] ? data_readReg_32b_26 : 32'bz;


		wire [31:0] data_readReg_32b_27;
		register_32b register_27(.clock(clock), .ctrl_writeEnable(decoded_writeReg[27]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_27));
		assign data_readRegA = decoded_readRegA[27] ? data_readReg_32b_27 : 32'bz;
		assign data_readRegB = decoded_readRegB[27] ? data_readReg_32b_27 : 32'bz;


		wire [31:0] data_readReg_32b_28;
		register_32b register_28(.clock(clock), .ctrl_writeEnable(decoded_writeReg[28]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_28));
		assign data_readRegA = decoded_readRegA[28] ? data_readReg_32b_28 : 32'bz;
		assign data_readRegB = decoded_readRegB[28] ? data_readReg_32b_28 : 32'bz;


		wire [31:0] data_readReg_32b_29;
		register_32b register_29(.clock(clock), .ctrl_writeEnable(decoded_writeReg[29]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_29));
		assign data_readRegA = decoded_readRegA[29] ? data_readReg_32b_29 : 32'bz;
		assign data_readRegB = decoded_readRegB[29] ? data_readReg_32b_29 : 32'bz;

		// RSTATUS REGISTER
		wire [31:0] data_readReg_32b_30;
		wire [31:0] rstatus_write;
		assign rstatus_write = exception_flag_hot ? exception_flag : data_writeReg;
		register_32b register_30(.clock(clock), .ctrl_writeEnable(decoded_writeReg[30] || exception_flag_hot), .ctrl_reset(ctrl_reset), .data_writeReg_32b(rstatus_write), .data_readReg_32b(data_readReg_32b_30));
		assign data_readRegA = decoded_readRegA[30] ? data_readReg_32b_30 : 32'bz;
		assign data_readRegB = decoded_readRegB[30] ? data_readReg_32b_30 : 32'bz;


		wire [31:0] data_readReg_32b_31;
		register_32b register_31(.clock(clock), .ctrl_writeEnable(decoded_writeReg[31]), .ctrl_reset(ctrl_reset), .data_writeReg_32b(data_writeReg), .data_readReg_32b(data_readReg_32b_31));
		assign data_readRegA = decoded_readRegA[31] ? data_readReg_32b_31 : 32'bz;
		assign data_readRegB = decoded_readRegB[31] ? data_readReg_32b_31 : 32'bz;


		// Skip register 0 and just always output 0 if they request access to that register
		assign data_readRegA = decoded_readRegA[0] ? 32'b0 : 32'bz;
		assign data_readRegB = decoded_readRegB[0] ? 32'b0 : 32'bz;
endmodule


// - - - REGISTERS - - - //

module register_32b(clock, ctrl_writeEnable, ctrl_reset, data_writeReg_32b, data_readReg_32b);
	input clock, ctrl_writeEnable, ctrl_reset;
	input [31:0] data_writeReg_32b;
	output [31:0] data_readReg_32b;
	
	wire prn, ctrl_reset_inv;
	assign prn = 1'b1; //async. preset negative
	not(ctrl_reset_inv, ctrl_reset);

	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin : loop1
			dffe a_dffe(.d(data_writeReg_32b[i]), .clk(clock), .ena(ctrl_writeEnable), .prn(prn), .clrn(ctrl_reset_inv), .q(data_readReg_32b[i]));
		end
	endgenerate	
endmodule

module register_64b(clock, ctrl_writeEnable, ctrl_reset, data_writeReg, data_readReg);
	input clock, ctrl_writeEnable, ctrl_reset;
	input [63:0] data_writeReg;
	output [63:0] data_readReg;
	
	wire prn;
	assign prn = 1'b1; //async. preset negative

	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1) begin : loop1
			dffe a_dffe(.d(data_writeReg[i]), .clk(clock), .ena(ctrl_writeEnable), .prn(prn), .clrn(~ctrl_reset), .q(data_readReg[i]));
		end
	endgenerate	
endmodule

// - - - MULTDIV - - - //

module mult_div_32b(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
	input [31:0] data_operandA, data_operandB;
	input ctrl_MULT, ctrl_DIV, clock;
	output [31:0] data_result;
	output data_exception, data_resultRDY;
	
	// swap between mult and div assertions held in DFF triggered when ctrl_MULT/DIV are asserted
	wire mult_asserted, div_asserted;
	dffe mult_dff(.d(ctrl_MULT), .clk(clock), .ena(ctrl_MULT), .q(mult_asserted), .clrn(~ctrl_DIV), .prn(1'b1));
	dffe div_dff(.d(ctrl_DIV), .clk(clock), .ena(ctrl_DIV), .q(div_asserted), .clrn(~ctrl_MULT), .prn(1'b1));

	wire [31:0] data_operandA_latched, data_operandB_latched;
	register_32b data_operandA_register(.clock(clock), .ctrl_writeEnable(ctrl_MULT || ctrl_DIV), .ctrl_reset(1'b0), .data_writeReg_32b(data_operandA), .data_readReg_32b(data_operandA_latched));
	register_32b data_operandB_register(.clock(clock), .ctrl_writeEnable(ctrl_MULT || ctrl_DIV), .ctrl_reset(1'b0), .data_writeReg_32b(data_operandB), .data_readReg_32b(data_operandB_latched));
	
	wire [31:0] mult_result;
	wire mult_exception, mult_RDY;
	multiplier_32b my_multiplier(.data_operandA(data_operandA_latched), .data_operandB(data_operandB_latched), .ctrl_MULT(ctrl_MULT), .clock(clock), .data_result(mult_result), .data_exception(mult_exception), .data_resultRDY(mult_RDY));
	
	wire [31:0] div_result;
	wire div_exception, div_RDY;
	divider_32b my_divider(.data_operandA(data_operandA_latched), .data_operandB(data_operandB_latched), .ctrl_DIV(ctrl_DIV), .clock(clock), .data_result(div_result), .data_exception(div_exception), .data_resultRDY(div_RDY));
	
	assign data_result = mult_asserted ? mult_result : div_result;
	assign data_exception = mult_asserted ? mult_exception : div_exception;
	assign data_resultRDY = mult_asserted ? mult_RDY : div_RDY;
	
endmodule

module multiplier_32b(data_operandA, data_operandB, ctrl_MULT, clock, data_result, data_exception, data_resultRDY);
	input [31:0] data_operandA, data_operandB; 
	input ctrl_MULT, clock;
	output [31:0] data_result;
	output data_exception, data_resultRDY;

	wire [31:0] multiplicand, multiplier;

	// if multiplier is negative, invert it and invert product result later
	wire multiplier_is_neg;
	wire [31:0] data_operandB_inv;
	assign multiplier_is_neg = data_operandB[31];
	inverter_32b B_inverter(.to_invert(data_operandB), .inverted(data_operandB_inv));
	
	assign multiplicand = data_operandA;
	assign multiplier = multiplier_is_neg ? data_operandB_inv : data_operandB;

	// count to 32, product is ready when you get there, takes 32 clock cycles
	wire [5:0] count;
	counter32 counter(.clock(clock), .reset(ctrl_MULT), .out(count));

	wire [63:0] product_input, product_output;
	register_64b product_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(ctrl_MULT), .data_writeReg(product_input), .data_readReg(product_output));

	wire product_LSB;
	assign product_LSB = product_output[0];

	wire [31:0] upper_32_plus_multiplicand;
	wire dc_overflow;
	carry_select_adder_32b mult_adder(.data_operandA(product_output[63:32]), .data_operandB(multiplicand), .sum(upper_32_plus_multiplicand), .overflow(dc_overflow));

	// if LSB of product in last cycle was 1, use added multiplicand, if 0, keep it
	wire [63:0] new_product_input_to_shift;
	assign new_product_input_to_shift[63:32] = product_LSB ? upper_32_plus_multiplicand : product_output[63:32];
	assign new_product_input_to_shift[31:0] = product_output[31:0];

	// shift product and input it back into the register
	wire [63:0] product_input_not_initial, product_input_initial;
	rshift1_64b right_shifter(.to_shift(new_product_input_to_shift), .shifted(product_input_not_initial));
	assign product_input_initial[31:0] = multiplier;

	genvar i;
	generate
		for(i = 32; i < 64; i = i + 1) begin : loop1
			assign product_input_initial[i] = 1'b0;
		end
	endgenerate	


	wire count_equals_0;
	equal_to_checker_6b is_initial(.is_equal(count_equals_0), .data_operandA(count), .data_operandB(6'd0));
	assign product_input = count_equals_0 ? product_input_initial : product_input_not_initial;

	wire [63:0] product_output_inv;
	inverter_64b product_inverter(.to_invert(product_output), .inverted(product_output_inv));

	// if multiplier was negative, negate product for data result
	wire [63:0] product_result;
	assign product_result = multiplier_is_neg ? product_output_inv : product_output;
	assign data_result = product_result[31:0];

	equal_to_checker_6b is_done_checker(.is_equal(data_resultRDY), .data_operandA(count), .data_operandB(6'd33));

	// if [63:31] aren't all the same, the product has overflowed
	wire all1, all0;
	and overflow_checker_all_1(all1, product_result[31], product_result[32], product_result[33], product_result[34], product_result[35], product_result[36], product_result[37], product_result[38], product_result[39], product_result[40], product_result[41], product_result[42], product_result[43], product_result[44], product_result[45], product_result[46], product_result[47], product_result[48], product_result[49], product_result[50], product_result[51], product_result[52], product_result[53], product_result[54], product_result[55], product_result[56], product_result[57], product_result[58], product_result[59], product_result[60], product_result[61], product_result[62], product_result[63]);
	nor overflow_checker_all_0(all0, product_result[31], product_result[32], product_result[33], product_result[34], product_result[35], product_result[36], product_result[37], product_result[38], product_result[39], product_result[40], product_result[41], product_result[42], product_result[43], product_result[44], product_result[45], product_result[46], product_result[47], product_result[48], product_result[49], product_result[50], product_result[51], product_result[52], product_result[53], product_result[54], product_result[55], product_result[56], product_result[57], product_result[58], product_result[59], product_result[60], product_result[61], product_result[62], product_result[63]);
	nor overflow_checker(data_exception, all1, all0);

endmodule

module divider_32b(data_operandA, data_operandB, ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
	input [31:0] data_operandA, data_operandB; 
	input ctrl_DIV, clock;
	output [31:0] data_result;
	output data_exception, data_resultRDY;

	wire [31:0] dividend, divisor;

	// if dividend and/or divisor are negative, make them positive and keep in mind whether to invert the final quotient
	wire dividend_is_neg, divisor_is_neg;
	wire [31:0] data_operandA_inv, data_operandB_inv;
	assign dividend_is_neg = data_operandA[31];
	assign divisor_is_neg = data_operandB[31];
	inverter_32b A_inverter(.to_invert(data_operandA), .inverted(data_operandA_inv));
	inverter_32b B_inverter(.to_invert(data_operandB), .inverted(data_operandB_inv));
	assign dividend = dividend_is_neg ? data_operandA_inv : data_operandA;
	assign divisor = divisor_is_neg ? data_operandB_inv : data_operandB;
	wire quotient_is_neg;
	xor neg_quotient_xor(quotient_is_neg, dividend_is_neg, divisor_is_neg);

	// count to 32, quotient is ready when you get there, takes 32 clock cycles
	wire [5:0] count;
	counter32 counter(.clock(clock), .reset(ctrl_DIV), .out(count));

	wire [63:0] divd_quotient_input, divd_quotient_output;
	register_64b divd_quotient_block(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(ctrl_DIV), .data_writeReg(divd_quotient_input), .data_readReg(divd_quotient_output));

	// subtract (upper 32 of dividend - divisor), if it's positive or 0, we'll want to use this subtracted difference
	wire [31:0] upper_32_minus_divisor;
	wire upper_32_less_than_divisor, dc_sub_overflow, dc_sub_equal;
	carry_select_subtracter_32b div_subtracter(.data_operandA(divd_quotient_output[63:32]), .data_operandB(divisor), .difference(upper_32_minus_divisor), .overflow(dc_sub_overflow), .isNotEqual(dc_sub_equal), .isLessThan(upper_32_less_than_divisor));

	// assign pieces of new dividend quotient block before you shift it
	wire [63:0] new_divd_quotient_to_shift;
	assign new_divd_quotient_to_shift[63:32] = upper_32_less_than_divisor ? divd_quotient_output[63:32] : upper_32_minus_divisor;
	assign new_divd_quotient_to_shift[31:1] = divd_quotient_output[31:1];
	// if upper 32 greater than or equal to divisor, set LSB of current quotient to 1
	not LSB_set_one(new_divd_quotient_to_shift[0], upper_32_less_than_divisor);

	// initialization
	wire [63:0] new_divd_quotient_initial;
	assign new_divd_quotient_initial[31:0] = dividend;
	genvar i;
	generate
		for(i = 32; i < 64; i = i + 1) begin : loop1
			assign new_divd_quotient_initial[i] = 1'b0;
		end
	endgenerate	
	wire count_initial;
	equal_to_checker_6b is_initial(.is_equal(count_initial), .data_operandA(count), .data_operandB(6'd0));

	assign divd_quotient_input = count_initial ? (new_divd_quotient_initial << 1) : (new_divd_quotient_to_shift << 1);

	// looking at lower 32 shifted by one to account for the input automatically being shifted one
	wire [31:0] divd_quotient_lower32, divd_quotient_lower32_inv;
	assign divd_quotient_lower32 = divd_quotient_output[32:1];
	inverter_32b divd_quotient_lower32_inverter(.to_invert(divd_quotient_lower32), .inverted(divd_quotient_lower32_inv));

	// if result should be negative, negate quotient for data result
	assign data_result = quotient_is_neg ? divd_quotient_lower32_inv : divd_quotient_lower32;
	equal_to_checker_32b divide_by_zero_checker(.is_equal(data_exception), .data_operandA(32'b0), .data_operandB(data_operandB));
	equal_to_checker_6b is_done_checker(.is_equal(data_resultRDY), .data_operandA(count), .data_operandB(6'd33));

endmodule


module counter32(clock, reset, out);
	input clock, reset;
	output [5:0] out;
	reg [5:0] next;
	dffe dff0(.d(next[0]), .clk(clock), .ena(1'b1), .prn(1'b1), .q(out[0]), .clrn(~reset));
	dffe dff1(.d(next[1]), .clk(clock), .ena(1'b1), .prn(1'b1),  .q(out[1]), .clrn(~reset));
	dffe dff2(.d(next[2]), .clk(clock), .ena(1'b1), .prn(1'b1),  .q(out[2]), .clrn(~reset));
	dffe dff3(.d(next[3]), .clk(clock), .ena(1'b1), .prn(1'b1),  .q(out[3]), .clrn(~reset));
	dffe dff4(.d(next[4]), .clk(clock), .ena(1'b1), .prn(1'b1),  .q(out[4]), .clrn(~reset));
	dffe dff5(.d(next[5]), .clk(clock), .ena(1'b1), .prn(1'b1),  .q(out[5]), .clrn(~reset));
	always@(*) begin
		casex({reset, out})
			7'b1xxxxxx: next = 6'b0;
			7'd0:  next = 6'd1;
			7'd1:  next = 6'd2;
			7'd2:  next = 6'd3;
			7'd3:  next = 6'd4;
			7'd4:  next = 6'd5;
			7'd5:  next = 6'd6;
			7'd6:  next = 6'd7;
			7'd7:  next = 6'd8;
			7'd8:  next = 6'd9;
			7'd9:  next = 6'd10;
			7'd10:  next = 6'd11;
			7'd11:  next = 6'd12;
			7'd12:  next = 6'd13;
			7'd13:  next = 6'd14;
			7'd14:  next = 6'd15;
			7'd15:  next = 6'd16;
			7'd16:  next = 6'd17;
			7'd17:  next = 6'd18;
			7'd18:  next = 6'd19;
			7'd19:  next = 6'd20;
			7'd20:  next = 6'd21;
			7'd21:  next = 6'd22;
			7'd22:  next = 6'd23;
			7'd23:  next = 6'd24;
			7'd24:  next = 6'd25;
			7'd25:  next = 6'd26;
			7'd26:  next = 6'd27;
			7'd27:  next = 6'd28;
			7'd28:  next = 6'd29;
			7'd29:  next = 6'd30;
			7'd30:  next = 6'd31;
			7'd31:  next = 6'd32;
			7'd32:  next = 6'd33;
			7'd33:  next = 6'd34;
			7'd34:  next = 6'd35;
			default: next = 6'b0;
		endcase
	end
endmodule


// - - - ALU SUBMODULES - - - //

module carry_select_adder_32b(data_operandA, data_operandB, sum, overflow);
	input [31:0] data_operandA, data_operandB;
	output [31:0] sum;
	output overflow;
	
	wire second_8b_enable, third_8b_enable, fourth_8b_enable;
	wire second_8b_cout_0, second_8b_cout_1, third_8b_cout_0, third_8b_cout_1, fourth_8b_cout_0, fourth_8b_cout_1;
	wire [7:0] second_8b_0, second_8b_1, third_8b_0, third_8b_1, fourth_8b_0, fourth_8b_1;
	// Question: if we don't care about one of the outputs, do we still need to give it a wire we don't plan to use?

	slow_adder_8b first_8b_adder(.a(data_operandA[7:0]), .b(data_operandB[7:0]), .cin(1'b0), .cout(second_8b_enable), .sum(sum[7:0]));

	slow_adder_8b second_8b_adder0(.a(data_operandA[15:8]), .b(data_operandB[15:8]), .cin(1'b0), .cout(second_8b_cout_0), .sum(second_8b_0));
	slow_adder_8b second_8b_adder1(.a(data_operandA[15:8]), .b(data_operandB[15:8]), .cin(1'b1), .cout(second_8b_cout_1), .sum(second_8b_1));
	slow_adder_8b third_8b_adder0(.a(data_operandA[23:16]), .b(data_operandB[23:16]), .cin(1'b0), .cout(third_8b_cout_0), .sum(third_8b_0));
	slow_adder_8b third_8b_adder1(.a(data_operandA[23:16]), .b(data_operandB[23:16]), .cin(1'b1), .cout(third_8b_cout_1), .sum(third_8b_1));
	slow_adder_8b fourth_8b_adder0(.a(data_operandA[31:24]), .b(data_operandB[31:24]), .cin(1'b0), .cout(fourth_8b_cout_0), .sum(fourth_8b_0));
	slow_adder_8b fourth_8b_adder1(.a(data_operandA[31:24]), .b(data_operandB[31:24]), .cin(1'b1), .cout(fourth_8b_cout_1), .sum(fourth_8b_1));
	
	assign third_8b_enable = second_8b_enable ? second_8b_cout_1 : second_8b_cout_0;
	assign fourth_8b_enable = third_8b_enable ? third_8b_cout_1: third_8b_cout_0;

	assign sum[15:8] = second_8b_enable ? second_8b_1 : second_8b_0;
	assign sum[23:16] = third_8b_enable ? third_8b_1 : third_8b_0;
	assign sum[31:24] = fourth_8b_enable ? fourth_8b_1 : fourth_8b_0;
	
	wire a_MSB, a_MSB_inv, b_MSB, b_MSB_inv, sum_MSB, sum_MSB_inv;
	assign a_MSB = data_operandA[31];
	assign b_MSB = data_operandB[31];
	assign sum_MSB = sum[31];
	not nota(a_MSB_inv, a_MSB);
	not notb(b_MSB_inv, b_MSB);
	not nots(sum_MSB_inv, sum_MSB);
	wire overflow_cond1, overflow_cond2;
	and and_overflow1(overflow_cond1, a_MSB_inv, b_MSB_inv, sum_MSB);
	and and_overflow2(overflow_cond2, a_MSB, b_MSB, sum_MSB_inv);
	or or_overflow(overflow, overflow_cond1, overflow_cond2);
endmodule

module carry_select_adder_64b(data_operandA, data_operandB, sum, overflow);
	input [63:0] data_operandA, data_operandB;
	output [63:0] sum;
	output overflow;
	
	wire second_8b_enable, third_8b_enable, fourth_8b_enable, fifth_8b_enable, sixth_8b_enable, seventh_8b_enable, eighth_8b_enable;
	wire second_8b_cout_0, second_8b_cout_1, third_8b_cout_0, third_8b_cout_1, fourth_8b_cout_0, fourth_8b_cout_1, fifth_8b_cout_0, fifth_8b_cout_1, sixth_8b_cout_0, sixth_8b_cout_1, seventh_8b_cout_0, seventh_8b_cout_1, eighth_8b_cout_0, eighth_8b_cout_1;
	wire [7:0] second_8b_0, second_8b_1, third_8b_0, third_8b_1, fourth_8b_0, fourth_8b_1, fifth_8b_0, fifth_8b_1, sixth_8b_0, sixth_8b_1, seventh_8b_0, seventh_8b_1, eighth_8b_0, eighth_8b_1;

	slow_adder_8b first_8b_adder(.a(data_operandA[7:0]), .b(data_operandB[7:0]), .cin(1'b0), .cout(second_8b_enable), .sum(sum[7:0]));

	slow_adder_8b second_8b_adder0(.a(data_operandA[15:8]), .b(data_operandB[15:8]), .cin(1'b0), .cout(second_8b_cout_0), .sum(second_8b_0));
	slow_adder_8b second_8b_adder1(.a(data_operandA[15:8]), .b(data_operandB[15:8]), .cin(1'b1), .cout(second_8b_cout_1), .sum(second_8b_1));
	slow_adder_8b third_8b_adder0(.a(data_operandA[23:16]), .b(data_operandB[23:16]), .cin(1'b0), .cout(third_8b_cout_0), .sum(third_8b_0));
	slow_adder_8b third_8b_adder1(.a(data_operandA[23:16]), .b(data_operandB[23:16]), .cin(1'b1), .cout(third_8b_cout_1), .sum(third_8b_1));
	slow_adder_8b fourth_8b_adder0(.a(data_operandA[31:24]), .b(data_operandB[31:24]), .cin(1'b0), .cout(fourth_8b_cout_0), .sum(fourth_8b_0));
	slow_adder_8b fourth_8b_adder1(.a(data_operandA[31:24]), .b(data_operandB[31:24]), .cin(1'b1), .cout(fourth_8b_cout_1), .sum(fourth_8b_1));

	slow_adder_8b fifth_8b_adder0(.a(data_operandA[39:32]), .b(data_operandB[39:32]), .cin(1'b0), .cout(fifth_8b_cout_0), .sum(fifth_8b_0));
	slow_adder_8b fifth_8b_adder1(.a(data_operandA[39:32]), .b(data_operandB[39:32]), .cin(1'b1), .cout(fifth_8b_cout_1), .sum(fifth_8b_1));
	slow_adder_8b sixth_8b_adder0(.a(data_operandA[47:40]), .b(data_operandB[47:40]), .cin(1'b0), .cout(sixth_8b_cout_0), .sum(sixth_8b_0));
	slow_adder_8b sixth_8b_adder1(.a(data_operandA[47:40]), .b(data_operandB[47:40]), .cin(1'b1), .cout(sixth_8b_cout_1), .sum(sixth_8b_1));
	slow_adder_8b seventh_8b_adder0(.a(data_operandA[55:48]), .b(data_operandB[55:48]), .cin(1'b0), .cout(seventh_8b_cout_0), .sum(seventh_8b_0));
	slow_adder_8b seventth_8b_adder1(.a(data_operandA[55:48]), .b(data_operandB[55:48]), .cin(1'b1), .cout(seventh_8b_cout_1), .sum(seventh_8b_1));
	slow_adder_8b eighth_8b_adder0(.a(data_operandA[63:56]), .b(data_operandB[63:56]), .cin(1'b0), .cout(eighth_8b_cout_0), .sum(eighth_8b_0));
	slow_adder_8b eighth_8b_adder1(.a(data_operandA[63:56]), .b(data_operandB[63:56]), .cin(1'b1), .cout(eighth_8b_cout_1), .sum(eighth_8b_1));

	
	assign third_8b_enable = second_8b_enable ? second_8b_cout_1 : second_8b_cout_0;
	assign fourth_8b_enable = third_8b_enable ? third_8b_cout_1: third_8b_cout_0;
	assign fifth_8b_enable = fourth_8b_enable ? fourth_8b_cout_1 : fourth_8b_cout_0;
	assign sixth_8b_enable = fifth_8b_enable ? fifth_8b_cout_1: fifth_8b_cout_0;
	assign seventh_8b_enable = sixth_8b_enable ? sixth_8b_cout_1 : sixth_8b_cout_0;
	assign eighth_8b_enable = seventh_8b_enable ? seventh_8b_cout_1: seventh_8b_cout_0;

	assign sum[15:8] = second_8b_enable ? second_8b_1 : second_8b_0;
	assign sum[23:16] = third_8b_enable ? third_8b_1 : third_8b_0;
	assign sum[31:24] = fourth_8b_enable ? fourth_8b_1 : fourth_8b_0;
	assign sum[39:32] = fifth_8b_enable ? fifth_8b_1 : fifth_8b_0;
	assign sum[47:40] = sixth_8b_enable ? sixth_8b_1 : sixth_8b_0;
	assign sum[55:48] = seventh_8b_enable ? seventh_8b_1 : seventh_8b_0;
	assign sum[63:56] = eighth_8b_enable ? eighth_8b_1 : eighth_8b_0;
	
	wire a_MSB, a_MSB_inv, b_MSB, b_MSB_inv, sum_MSB, sum_MSB_inv;
	assign a_MSB = data_operandA[63];
	assign b_MSB = data_operandB[63];
	assign sum_MSB = sum[63];
	not nota(a_MSB_inv, a_MSB);
	not notb(b_MSB_inv, b_MSB);
	not nots(sum_MSB_inv, sum_MSB);
	wire overflow_cond1, overflow_cond2;
	and and_overflow1(overflow_cond1, a_MSB_inv, b_MSB_inv, sum_MSB);
	and and_overflow2(overflow_cond2, a_MSB, b_MSB, sum_MSB_inv);
	or or_overflow(overflow, overflow_cond1, overflow_cond2);
endmodule

module full_adder_1b(a, b, cin, cout, sum);
	input a,b, cin;
	output cout, sum;
	
	wire xor0_out, and0_out, and1_out;
	
	xor xor0(xor0_out, a, b);
	xor xor1(sum, cin, xor0_out);
	and and0(and0_out, cin, xor0_out);
	and and1(and1_out, a, b);
	or or0(cout, and0_out, and1_out);
endmodule

module slow_adder_8b(a, b, cin, cout, sum);
	input [7:0] a, b; 
	input cin;
	output [7:0] sum;
	output cout;
	
	wire [8:0] intermediate_cout; // 8 values because 0th is cin and 8th is cou
	assign intermediate_cout[0] = cin;

	genvar i;
	generate
		for(i = 0; i < 8; i = i + 1) begin : loop1
			full_adder_1b a_full_adder(.a(a[i]), .b(b[i]), .cin(intermediate_cout[i]), .cout(intermediate_cout[i+1]), .sum(sum[i]));
		end
	endgenerate
	
	assign cout = intermediate_cout[8];
endmodule

module carry_select_subtracter_32b(data_operandA, data_operandB, difference, overflow, isNotEqual, isLessThan);
	input [31:0] data_operandA, data_operandB;
	output [31:0] difference;
	output overflow, isNotEqual, isLessThan;
	
	wire [31:0] data_operandB_inv;
	wire add_overflow;
	inverter_32b b_inverter(.to_invert(data_operandB), .inverted(data_operandB_inv));
	carry_select_adder_32b adder0(.data_operandA(data_operandA), .data_operandB(data_operandB_inv), .sum(difference), .overflow(add_overflow));
	or or0(isNotEqual, difference[0], difference[1],  difference[2], difference[3], difference[4], difference[5],  difference[6], difference[7], difference[8], difference[9],  difference[10], difference[11], difference[12], difference[13],  difference[14], difference[15], difference[16], difference[17],  difference[18], difference[19], difference[20], difference[21],  difference[22], difference[23], difference[24], difference[25],  difference[26], difference[27], difference[28], difference[29],  difference[30], difference[31]);
	wire negative_difference;
	
	wire a_MSB, a_MSB_inv, b_MSB, b_MSB_inv, diff_MSB, diff_MSB_inv;
	assign a_MSB = data_operandA[31];
	assign b_MSB = data_operandB[31];
	assign diff_MSB = difference[31];
	not nota(a_MSB_inv, a_MSB);
	not notb(b_MSB_inv, b_MSB);
	not nots(diff_MSB_inv, diff_MSB);
	wire overflow_cond1, overflow_cond2;
	and and_overflow1(overflow_cond1, a_MSB, b_MSB_inv, diff_MSB_inv);
	and and_overflow2(overflow_cond2, a_MSB_inv, b_MSB, diff_MSB);
	or or_overflow(overflow, overflow_cond1, overflow_cond2);
	
	wire MSB_inv, MSB;
	not not0(MSB_inv, MSB);
	assign negative_difference = overflow ?  diff_MSB_inv : diff_MSB;  // Does this logic make sense???
	and and0(isLessThan, isNotEqual, negative_difference);
endmodule

module inverter_32b(to_invert, inverted);
	input [31:0] to_invert;
	output [31:0] inverted;
	
	wire [31:0] flipped_bits;
	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin : loop1
			not a_not(flipped_bits[i], to_invert[i]);
		end
	endgenerate
	
	wire irrelevant_cout;
	carry_select_adder_32b adder0(.data_operandA(flipped_bits), .data_operandB(32'b1), .sum(inverted), .overflow(irrelevant_cout));
endmodule

module inverter_64b(to_invert, inverted);
	input [63:0] to_invert;
	output [63:0] inverted;
	
	wire [63:0] flipped_bits;
	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1) begin : loop1
			not a_not(flipped_bits[i], to_invert[i]);
		end
	endgenerate
	
	wire irrelevant_cout;
	carry_select_adder_64b adder0(.data_operandA(flipped_bits), .data_operandB(64'b1), .sum(inverted), .overflow(irrelevant_cout));
endmodule

module and_32b(data_operandA, data_operandB, data_result);
	input [31:0] data_operandA, data_operandB;
	output [31:0] data_result;

	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin : loop1
			and and0(data_result[i], data_operandA[i], data_operandB[i]);
		end
	endgenerate
endmodule

module or_32b(data_operandA, data_operandB, data_result);
	input [31:0] data_operandA, data_operandB;
	output [31:0] data_result;

	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin : loop1
			or or0(data_result[i], data_operandA[i], data_operandB[i]);
		end
	endgenerate
endmodule

module sll_32b(data_operandA, ctrl_shiftamt, data_result);
	input [31:0] data_operandA;
	input [4:0] ctrl_shiftamt;
	output [31:0] data_result;

	wire [31:0] shifter16_out, shifter8_out, shifter4_out, shifter2_out, shifter1_out;
	wire[31:0] shifter8_in, shifter4_in, shifter2_in, shifter1_in;

	left_shift_16b shifter16(.data_operandA(data_operandA), .data_result(shifter16_out));
	assign shifter8_in = ctrl_shiftamt[4] ? shifter16_out : data_operandA;

	left_shift_8b shifter8(.data_operandA(shifter8_in), .data_result(shifter8_out));
	assign shifter4_in = ctrl_shiftamt[3] ? shifter8_out : shifter8_in;

	left_shift_4b shifter4(.data_operandA(shifter4_in), .data_result(shifter4_out));
	assign shifter2_in = ctrl_shiftamt[2] ? shifter4_out : shifter4_in;

	left_shift_2b shifter2(.data_operandA(shifter2_in), .data_result(shifter2_out));
	assign shifter1_in = ctrl_shiftamt[1] ? shifter2_out : shifter2_in;

	left_shift_1b shifter1(.data_operandA(shifter1_in), .data_result(shifter1_out));
	assign data_result = ctrl_shiftamt[0] ? shifter1_out : shifter1_in;
endmodule

module sra_32b(data_operandA, ctrl_shiftamt, data_result);
	input [31:0] data_operandA;
	input [4:0] ctrl_shiftamt;
	output [31:0] data_result;

	wire [31:0] shifter16_out, shifter8_out, shifter4_out, shifter2_out, shifter1_out;
	wire[31:0] shifter8_in, shifter4_in, shifter2_in, shifter1_in;

	right_shift_16b shifter16(.data_operandA(data_operandA), .data_result(shifter16_out));
	assign shifter8_in = ctrl_shiftamt[4] ? shifter16_out : data_operandA;

	right_shift_8b shifter8(.data_operandA(shifter8_in), .data_result(shifter8_out));
	assign shifter4_in = ctrl_shiftamt[3] ? shifter8_out : shifter8_in;

	right_shift_4b shifter4(.data_operandA(shifter4_in), .data_result(shifter4_out));
	assign shifter2_in = ctrl_shiftamt[2] ? shifter4_out : shifter4_in;

	right_shift_2b shifter2(.data_operandA(shifter2_in), .data_result(shifter2_out));
	assign shifter1_in = ctrl_shiftamt[1] ? shifter2_out : shifter2_in;

	right_shift_1b shifter1(.data_operandA(shifter1_in), .data_result(shifter1_out));
	assign data_result = ctrl_shiftamt[0] ? shifter1_out : shifter1_in;
endmodule

// intermediate left shifters

module left_shift_1b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[0] = 1'b0;
	genvar i;
	generate
		for(i = 1; i < 32; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i-1];
		end
	endgenerate
endmodule

module left_shift_2b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[0] = 1'b0;
	assign data_result[1] = 1'b0;
	genvar i;
	generate
		for(i = 2; i < 32; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i-2];
		end
	endgenerate
endmodule

module left_shift_4b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[0] = 1'b0;
	assign data_result[1] = 1'b0;
	assign data_result[2] = 1'b0;
	assign data_result[3] = 1'b0;

	genvar i;
	generate
		for(i = 4; i < 32; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i-4];
		end
	endgenerate
endmodule

module left_shift_8b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[0] = 1'b0;
	assign data_result[1] = 1'b0;
	assign data_result[2] = 1'b0;
	assign data_result[3] = 1'b0;
	assign data_result[4] = 1'b0;
	assign data_result[5] = 1'b0;
	assign data_result[6] = 1'b0;
	assign data_result[7] = 1'b0;

	genvar i;
	generate
		for(i = 8; i < 32; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i-8];
		end
	endgenerate
endmodule

module left_shift_16b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[0] = 1'b0;
	assign data_result[1] = 1'b0;
	assign data_result[2] = 1'b0;
	assign data_result[3] = 1'b0;
	assign data_result[4] = 1'b0;
	assign data_result[5] = 1'b0;
	assign data_result[6] = 1'b0;
	assign data_result[7] = 1'b0;
	assign data_result[8] = 1'b0;
	assign data_result[9] = 1'b0;
	assign data_result[10] = 1'b0;
	assign data_result[11] = 1'b0;
	assign data_result[12] = 1'b0;
	assign data_result[13] = 1'b0;
	assign data_result[14] = 1'b0;
	assign data_result[15] = 1'b0;

	genvar i;
	generate
		for(i = 16; i < 32; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i-16];
		end
	endgenerate
endmodule

// intermediate right shifters

module right_shift_1b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[31] = data_operandA[31];
	genvar i;
	generate
		for(i = 0; i < 31; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i+1];
		end
	endgenerate
endmodule

module right_shift_2b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[31] = data_operandA[31];
	assign data_result[30] = data_operandA[31];
	genvar i;
	generate
		for(i = 0; i < 30; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i+2];
		end
	endgenerate
endmodule

module right_shift_4b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[31] = data_operandA[31];
	assign data_result[30] = data_operandA[31];
	assign data_result[29] = data_operandA[31];
	assign data_result[28] = data_operandA[31];

	genvar i;
	generate
		for(i = 0; i < 28; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i+4];
		end
	endgenerate
endmodule

module right_shift_8b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[31] = data_operandA[31];
	assign data_result[30] = data_operandA[31];
	assign data_result[29] = data_operandA[31];
	assign data_result[28] = data_operandA[31];
	assign data_result[27] = data_operandA[31];
	assign data_result[26] = data_operandA[31];
	assign data_result[25] = data_operandA[31];
	assign data_result[24] = data_operandA[31];

	genvar i;
	generate
		for(i = 0; i < 24; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i+8];
		end
	endgenerate
endmodule

module right_shift_16b(data_operandA, data_result);
	input [31:0] data_operandA;
	output [31:0] data_result;

	assign data_result[31] = data_operandA[31];
	assign data_result[30] = data_operandA[31];
	assign data_result[29] = data_operandA[31];
	assign data_result[28] = data_operandA[31];
	assign data_result[27] = data_operandA[31];
	assign data_result[26] = data_operandA[31];
	assign data_result[25] = data_operandA[31];
	assign data_result[24] = data_operandA[31];
	assign data_result[23] = data_operandA[31];
	assign data_result[22] = data_operandA[31];
	assign data_result[21] = data_operandA[31];
	assign data_result[20] = data_operandA[31];
	assign data_result[19] = data_operandA[31];
	assign data_result[18] = data_operandA[31];
	assign data_result[17] = data_operandA[31];
	assign data_result[16] = data_operandA[31];

	genvar i;
	generate
		for(i = 0; i < 16; i = i + 1) begin : loop1
			assign data_result[i] = data_operandA[i+16];
		end
	endgenerate
endmodule

// - - - HELPER MODULES - - - //

module equal_to_checker_32b(is_equal, data_operandA, data_operandB);
	input [31:0] data_operandA, data_operandB;
	output is_equal;

	wire not_equal, dc_less_than, dc_overflow;
	wire [31:0] dc_result;
	carry_select_subtracter_32b subtracter0(.data_operandA(data_operandA), .data_operandB(data_operandB), .difference(dc_result), .overflow(dc_overflow), .isNotEqual(not_equal), .isLessThan(dc_less_than));
	not not0(is_equal, not_equal);
endmodule

module equal_to_checker_6b(is_equal, data_operandA, data_operandB);
	input [5:0] data_operandA, data_operandB;
	output is_equal;

	wire [31:0] subA, subB;
	assign subA[5:0] = data_operandA;
	assign subB[5:0] = data_operandB;
	
	genvar i;
	generate
		for(i = 6; i < 32; i = i + 1) begin : loop1
			assign subA[i] = 1'b0;
			assign subB[i] = 1'b0;
		end
	endgenerate	

	wire not_equal, dc_less_than, dc_overflow;
	wire [31:0] dc_result;
	carry_select_subtracter_32b subtracter0(.data_operandA(subA), .data_operandB(subB), .difference(dc_result), .overflow(dc_overflow), .isNotEqual(not_equal), .isLessThan(dc_less_than));
	not not0(is_equal, not_equal);
endmodule

module equal_to_checker_5b(is_equal, data_operandA, data_operandB);
	input [4:0] data_operandA, data_operandB;
	output is_equal;

	wire [31:0] subA, subB;
	assign subA[4:0] = data_operandA;
	assign subB[4:0] = data_operandB;
	
	genvar i;
	generate
		for(i = 5; i < 32; i = i + 1) begin : loop1
			assign subA[i] = 1'b0;
			assign subB[i] = 1'b0;
		end
	endgenerate	

	wire not_equal, dc_less_than, dc_overflow;
	wire [31:0] dc_result;
	carry_select_subtracter_32b subtracter0(.data_operandA(subA), .data_operandB(subB), .difference(dc_result), .overflow(dc_overflow), .isNotEqual(not_equal), .isLessThan(dc_less_than));
	not not0(is_equal, not_equal);
endmodule

module rshift1_64b(to_shift, shifted);
	input [63:0] to_shift;
	output [63:0] shifted;

	assign shifted[63] = to_shift[63];
	genvar i;
	generate
		for(i = 0; i < 63; i = i + 1) begin : loop1
			assign shifted[i] = to_shift[i+1];
		end
	endgenerate
endmodule


// - - - MUXES - - - //

module mux_4_32b(in0, in1, in2, in3, s0, s1, out);
	input [31:0] in0, in1, in2, in3;
	input s0, s1;
	output [31:0] out;

	wire [31:0] mux0_out, mux1_out;
	assign mux0_out = s0 ? in1 : in0;
	assign mux1_out = s0 ? in3 : in2;
	assign      out = s1 ? mux1_out : mux0_out;
endmodule
 
module mux_4_5b(in0, in1, in2, in3, s0, s1, out);
	input [4:0] in0, in1, in2, in3;
	input s0, s1;
	output [4:0] out;

	wire [4:0] mux0_out, mux1_out;
	assign mux0_out = s0 ? in1 : in0;
	assign mux1_out = s0 ? in3 : in2;
	assign      out = s1 ? mux1_out : mux0_out;
endmodule

module mux_8_32b(in0, in1, in2, in3, in4, in5, in6, in7, s0, s1, s2, out);
	input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
	input s0, s1, s2;
	output [31:0] out;

	wire [31:0] mux0_out, mux1_out, mux2_out, mux3_out, mux4_out, mux5_out;
	assign mux0_out = s0 ? in1 : in0;
	assign mux1_out = s0 ? in3 : in2;
	assign mux2_out = s0 ? in5 : in4;
	assign mux3_out = s0 ? in7 : in6;
	assign mux4_out = s1 ? mux1_out : mux0_out;
	assign mux5_out = s1 ? mux3_out : mux2_out;
	assign      out = s2 ? mux5_out : mux4_out;
endmodule

module mux_8_1b(in0, in1, in2, in3, in4, in5, in6, in7, s0, s1, s2, out);
	input in0, in1, in2, in3, in4, in5, in6, in7;
	input s0, s1, s2;
	output out;

	wire mux0_out, mux1_out, mux2_out, mux3_out, mux4_out, mux5_out;
	assign mux0_out = s0 ? in1 : in0;
	assign mux1_out = s0 ? in3 : in2;
	assign mux2_out = s0 ? in5 : in4;
	assign mux3_out = s0 ? in7 : in6;
	assign mux4_out = s1 ? mux1_out : mux0_out;
	assign mux5_out = s1 ? mux3_out : mux2_out;
	assign      out = s2 ? mux5_out : mux4_out;
endmodule




// - - - DECODERS - - - //

module decoder_32b(in_5b, enable, out_32b);
	input [4:0] in_5b;
	input enable;
	output [31:0] out_32b;

	wire in0, in1, in2, in3, in4, in0_inv, in1_inv, in2_inv, in3_inv, in4_inv;
	assign in0 = in_5b[0];
	assign in1 = in_5b[1];
	assign in2 = in_5b[2];
	assign in3 = in_5b[3];
	assign in4 = in_5b[4];
	not not0(in0_inv, in0);
	not not1(in1_inv, in1);
	not not2(in2_inv, in2);
	not not3(in3_inv, in3);
	not not4(in4_inv, in4);

	and  and0(out_32b[0],  enable, in0_inv, in1_inv, in2_inv, in3_inv, in4_inv);
	and  and1(out_32b[1],  enable, in0    , in1_inv, in2_inv, in3_inv, in4_inv);
	and  and2(out_32b[2],  enable, in0_inv, in1    , in2_inv, in3_inv, in4_inv);
	and  and3(out_32b[3],  enable, in0    , in1    , in2_inv, in3_inv, in4_inv);
	and  and4(out_32b[4],  enable, in0_inv, in1_inv, in2    , in3_inv, in4_inv);
	and  and5(out_32b[5],  enable, in0    , in1_inv, in2    , in3_inv, in4_inv);
	and  and6(out_32b[6],  enable, in0_inv, in1    , in2    , in3_inv, in4_inv);
	and  and7(out_32b[7],  enable, in0    , in1    , in2    , in3_inv, in4_inv);
	and  and8(out_32b[8],  enable, in0_inv, in1_inv, in2_inv, in3    , in4_inv);
	and  and9(out_32b[9],  enable, in0    , in1_inv, in2_inv, in3    , in4_inv);
	and and10(out_32b[10], enable, in0_inv, in1    , in2_inv, in3    , in4_inv);
	and and11(out_32b[11], enable, in0    , in1    , in2_inv, in3    , in4_inv);
	and and12(out_32b[12], enable, in0_inv, in1_inv, in2    , in3    , in4_inv);
	and and13(out_32b[13], enable, in0    , in1_inv, in2    , in3    , in4_inv);
	and and14(out_32b[14], enable, in0_inv, in1    , in2    , in3    , in4_inv);
	and and15(out_32b[15], enable, in0    , in1    , in2    , in3    , in4_inv);
	and and16(out_32b[16], enable, in0_inv, in1_inv, in2_inv, in3_inv, in4    );
	and and17(out_32b[17], enable, in0    , in1_inv, in2_inv, in3_inv, in4    );
	and and18(out_32b[18], enable, in0_inv, in1    , in2_inv, in3_inv, in4    );
	and and19(out_32b[19], enable, in0    , in1    , in2_inv, in3_inv, in4    );
	and and20(out_32b[20], enable, in0_inv, in1_inv, in2    , in3_inv, in4    );
	and and21(out_32b[21], enable, in0    , in1_inv, in2    , in3_inv, in4    );
	and and22(out_32b[22], enable, in0_inv, in1    , in2    , in3_inv, in4    );
	and and23(out_32b[23], enable, in0    , in1    , in2    , in3_inv, in4    );
	and and24(out_32b[24], enable, in0_inv, in1_inv, in2_inv, in3    , in4    );
	and and25(out_32b[25], enable, in0    , in1_inv, in2_inv, in3    , in4    );
	and and26(out_32b[26], enable, in0_inv, in1    , in2_inv, in3    , in4    );
	and and27(out_32b[27], enable, in0    , in1    , in2_inv, in3    , in4    );
	and and28(out_32b[28], enable, in0_inv, in1_inv, in2    , in3    , in4    );
	and and29(out_32b[29], enable, in0    , in1_inv, in2    , in3    , in4    );
	and and30(out_32b[30], enable, in0_inv, in1    , in2    , in3    , in4    );
	and and31(out_32b[31], enable, in0    , in1    , in2    , in3    , in4    );
endmodule

module decoder_8b(in_3b, enable, out_8b);
	input [2:0] in_3b;
	input enable;
	output [7:0] out_8b;

	wire in0, in1, in2, in0_inv, in1_inv, in2_inv;
	assign in0 = in_3b[0];
	assign in1 = in_3b[1];
	assign in2 = in_3b[2];
	not not0(in0_inv, in0);
	not not1(in1_inv, in1);
	not not2(in2_inv, in2);

	and and0(out_8b[0], enable, in0_inv, in1_inv, in2_inv);
	and and1(out_8b[1], enable, in0    , in1_inv, in2_inv);
	and and2(out_8b[2], enable, in0_inv, in1    , in2_inv);
	and and3(out_8b[3], enable, in0    , in1    , in2_inv);
	and and4(out_8b[4], enable, in0_inv, in1_inv, in2    );
	and and5(out_8b[5], enable, in0    , in1_inv, in2    );
	and and6(out_8b[6], enable, in0_inv, in1    , in2    );
	and and7(out_8b[7], enable, in0    , in1    , in2    );
endmodule

module decoder_4b(in_2b, enable, out_4b);
	input [1:0] in_2b;
	input enable;
	output [3:0] out_4b;

	wire in0, in1, in0_inv, in1_inv;
	assign in0 = in_2b[0];
	assign in1 = in_2b[1];
	not not0(in0_inv, in0);
	not not1(in1_inv, in1);

	and and0(out_4b[0], enable, in0_inv, in1_inv);
	and and1(out_4b[1], enable, in0    , in1_inv);
	and and2(out_4b[2], enable, in0_inv, in1    );
	and and3(out_4b[3], enable, in0    , in1    );
endmodule