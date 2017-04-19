module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	dmem_data_in_player1, dmem_data_in_player2, dmem_data_out_player1, dmem_data_out_player2, dmem_address_player1, dmem_address_player2, // extra debugging ports
	leds, 						
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANKgtg
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50,
	color_select, shakeyShake1In, shakeyShake2In, shakeyShake1Out, shakeyShake2Out);  													// 50 MHz clock
		
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input			CLOCK_50;
	input	[7:0]   color_select;
	input shakeyShake1In, shakeyShake2In;
	output shakeyShake1Out, shakeyShake2Out;
	
	//assign shakeyShake1Out = shakeyShake1In;
	//assign shakeyShake2Out = shakeyShake2In;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	dmem_data_in_player1, dmem_data_in_player2, dmem_data_out_player1, dmem_data_out_player2;
	output  [11:0]  dmem_address_player1, dmem_address_player2;
	
	
	wire		clock;
	wire	    lcd_write_en;
	wire [31:0] lcd_write_data;
	wire [7:0]  ps2_key_data;
	wire	    ps2_key_pressed;
	wire [7:0]  ps2_out;
	
	wire        player1_key_pressed, player2_key_pressed;	
	wire [7:0]  player1_arrow_input, player2_arrow_input;
	wire [9:0]  player1_score,       player2_score;
	
	// clock divider (by 5, i.e., 10 MHz)
	pll div(CLOCK_50,inclock);
	//assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	assign clock = inclock;
	
	wire game_reset;
	assign game_reset = (~resetn || (ps2_out == 8'h2d)) ? 1'b1 : 1'b0;

	wire [77:0] player1_indexes,  player2_indexes;
	wire [1:0] player1_good_bad, player2_good_bad;

	processor player1_processor(clock, game_reset, player1_key_pressed, player1_arrow_input, player1_score, dmem_data_in_player1, dmem_address_player1, dmem_data_out_player1, player1_good_bad, player1_indexes);
	processor player2_processor(clock, game_reset, player2_key_pressed, player2_arrow_input, player2_score, dmem_data_in_player2, dmem_address_player2, dmem_data_out_data_player2, player2_good_bad, player2_indexes);

	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);

	wire player1_up, player1_left, player1_down, player1_right, player1_shakey_shake;
	assign player1_up    = ps2_out == 8'h1d;
	assign player1_left  = ps2_out == 8'h1c;
	assign player1_down  = ps2_out == 8'h1b;
	assign player1_right = ps2_out == 8'h23;
	assign player1_shakey_shake = 1'b0; //TODO insert shakeyshake
	assign player1_key_pressed = (ps2_key_pressed && (player1_up || player1_left || player1_down || player1_right)) || player1_shakey_shake;

	wire [2:0] player1_dec1, player1_dec2, player1_dec3, player1_dec4;
	assign player1_dec1 = player1_up    ? 3'b001 : 3'b000;
	assign player1_dec2 = player1_left  ? 3'b010 : player1_dec1;
	assign player1_dec3 = player1_down  ? 3'b011 : player1_dec2;
	assign player1_dec4 = player1_right ? 3'b100 : player1_dec3;
	assign player1_arrow_input[2:0] = player1_shakey_shake ? 3'b101 : player1_dec4;
	assign player1_arrow_input[7:3] = 5'b0;



	wire player2_up, player2_left, player2_down, player2_right, player2_shakey_shake;
	assign player2_up    = ps2_out == 8'h75;
	assign player2_left  = ps2_out == 8'h6b;
	assign player2_down  = ps2_out == 8'h72;
	assign player2_right = ps2_out == 8'h74;
	assign player2_shakey_shake = 1'b0; //TODO insert shakeyshake
	assign player2_key_pressed = (ps2_key_pressed && (player2_up || player2_left || player2_down || player2_right)) || player2_shakey_shake;

	wire [2:0] player2_dec1, player2_dec2, player2_dec3, player2_dec4;
	assign player2_dec1 = player2_up    ? 3'b001 : 3'b000;
	assign player2_dec2 = player2_left  ? 3'b010 : player2_dec1;
	assign player2_dec3 = player2_down  ? 3'b011 : player2_dec2;
	assign player2_dec4 = player2_right ? 3'b100 : player2_dec3;
	assign player2_arrow_input[2:0] = player2_shakey_shake ? 3'b101 : player2_dec4;
	assign player2_arrow_input[7:3] = 5'b0;



	wire [7:0] lcd_supposed;
	wire letter_s, letter_h, letter_i, letter_t;
	assign letter_s = ps2_out == 8'h1b;
	assign letter_h = ps2_out == 8'h33;
	assign letter_i = ps2_out == 8'h43;
	assign letter_t = ps2_out == 8'h2c;
	wire [7:0] data1, data2, data3;
	assign data1 = letter_t ? 8'h54 : 8'h23;
	assign data2 = letter_i ? 8'h49 : data1;
	assign data3 = letter_h ? 8'h48 : data2;
	assign lcd_supposed = letter_s ? 8'h53 : data3;
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, lcd_supposed, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	//TODO: write "Player 1 winning!" or "Player 2 winning!" "Score is tied!" to lcd based on scores 
	
	// SEVEN SEGMENT DISPLAYS
	binary_to_seven_segment_converter(player1_score, seg5, seg6, seg7, seg8);
	binary_to_seven_segment_converter(player2_score, seg1, seg2, seg3, seg4);
	//wire [9:0] debug_sevseg1, debug_sevseg2;
	//assign debug_sevseg1[2:0] = player1_index0;
	//assign debug_sevseg1[9:3] = 7'b0;
	//assign debug_sevseg2[2:0] = player1_index24;
	//assign debug_sevseg2[9:3] = 7'b0;
	//binary_to_seven_segment_converter(debug_sevseg1, seg5, seg6, seg7, seg8);
	//binary_to_seven_segment_converter(debug_sevseg2, seg1, seg2, seg3, seg4);

	
	// some LEDs that you could use for debugging if you wanted
	assign leds[7:1] = 7'b0;
	assign leds[0] = ~shakeyShake1In;
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	vga_controller vga_ins(.iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R),
								 .select(color_select),
								 .player1_good_bad(player1_good_bad),
								 .player2_good_bad(player2_good_bad),
								 .player1_indexes(player1_indexes),
								 .player2_indexes(player2_indexes));
	
	
endmodule
