module index_identifier(address, p1_arrow_array, p2_arrow_array, p1_indicator, p2_indicator, clock, index);
	input [18:0] address;
	input [77:0] p1_arrow_array, p2_arrow_array; // 3*26 = 78 indices
	input [1:0] p1_indicator, p2_indicator;
	input clock;
	output [7:0] index;
	
	// wires needed for images address and indexing
	wire [18:0] image_addr;
	wire [23:0] arrow_up_data_index, arrow_down_data_index, arrow_left_data_index, arrow_right_data_index, shakeyshake_data_index;
	
	wire [7:0] arrow_up_data_index_un_extended;
	
	// blocks needed for images
	arrow_up_img_data	arrow_up_data_inst (
	.address ( image_addr[18:0] ),
	.clock ( clock ),
	.q ( arrow_up_data_index_un_extended )
	);
	arrow_down_img_data	arrow_down_data_inst (
	.address ( image_addr[18:0] ),
	.clock ( clock ),
	.q ( arrow_down_data_index )
	);
	arrow_left_img_data	arrow_left_data_inst (
	.address ( image_addr[18:0] ),
	.clock ( clock ),
	.q ( arrow_left_data_index )
	);
	arrow_right_img_data	arrow_right_data_inst (
	.address ( image_addr[18:0] ),
	.clock ( clock ),
	.q ( arrow_right_data_index )
	);	
	arrow_up_img_data	shakeyshake_data_inst (
	.address ( image_addr[18:0] ),
	.clock ( clock ),
	.q ( shakeyshake_data_index )
	);
	
	assign arrow_up_data_index[7:0] = arrow_up_data_index_un_extended;
	assign arrow_up_data_index[23:8] = 16'd0;

	// transform array to matrix 
	wire [2:0] arrow_matrix [25:0];
	assign arrow_matrix[0] = p1_arrow_array[2:0];
	assign arrow_matrix[1] = p1_arrow_array[5:3];
	assign arrow_matrix[2] = p1_arrow_array[8:6];
	assign arrow_matrix[3] = p1_arrow_array[11:9];
	assign arrow_matrix[4] = p1_arrow_array[14:12];
	assign arrow_matrix[5] = p1_arrow_array[17:15];
	assign arrow_matrix[6] = p1_arrow_array[20:18];
	assign arrow_matrix[7] = p1_arrow_array[23:21];
	assign arrow_matrix[8] = p1_arrow_array[26:24];
	assign arrow_matrix[9] = p1_arrow_array[29:27];
	assign arrow_matrix[10] = p1_arrow_array[32:30];
	assign arrow_matrix[11] = p1_arrow_array[35:33];
	assign arrow_matrix[12] = p1_arrow_array[38:36];
	assign arrow_matrix[13] = p1_arrow_array[41:39];
	assign arrow_matrix[14] = p1_arrow_array[44:42];
	assign arrow_matrix[15] = p1_arrow_array[47:45];
	assign arrow_matrix[16] = p1_arrow_array[50:48];
	assign arrow_matrix[17] = p1_arrow_array[53:51];
	assign arrow_matrix[18] = p1_arrow_array[56:54];
	assign arrow_matrix[19] = p1_arrow_array[59:57];
	assign arrow_matrix[20] = p1_arrow_array[62:60];
	assign arrow_matrix[21] = p1_arrow_array[65:63];
	assign arrow_matrix[22] = p1_arrow_array[68:66];
	assign arrow_matrix[23] = p1_arrow_array[71:69];
	assign arrow_matrix[24] = p1_arrow_array[74:72];
	assign arrow_matrix[25] = p1_arrow_array[77:75];


	// colors for use TODO: input proper colors to these indices
	wire [7:0] excellent_index, good_index, bad_index, left_index, right_index, up_index, down_index, shakeyshake_index, default_index;
	assign excellent_index = 8'h001; // green
	assign good_index = 8'h002; // yellow
	assign bad_index = 8'h003; // red
	assign left_index = 8'h004; // 068315
	assign right_index = 8'h005; // 0067a9
	assign up_index = 8'h006; //666dab
	assign down_index = 8'h007; //674ea7
	assign shakeyshake_index = 8'h008; //abcdef                                             
	assign default_index = 8'h000; //f0e7df

	// hard coded constants that can be changed
	wire [18:0] SCREEN_WIDTH, SCREEN_HEIGHT, PLAY_HEIGHT, PLAYER_BORDER, LANE_WIDTH, LANE_HEIGHT, STATE_HEIGHT, INDICATOR_PANEL_HEIGHT;
	assign SCREEN_WIDTH = 19'd640;
	assign SCREEN_HEIGHT = 19'd480;
	//assign PLAY_HEIGHT = 19'd432;
	assign PLAYER_BORDER = 19'd320; //SCREEN_WIDTH/2
	assign LANE_WIDTH = 19'd64; //SCREEN_WIDTH/10
	assign LANE_HEIGHT = 19'd64; //LANE_WIDTH
	assign STATE_HEIGHT = 19'd16; //LANE_WIDTH/4
	assign INDICATOR_PANEL_HEIGHT = 19'd48; //SCREEN_HEIGHT-PLAY_HEIGHT;

	// check which pixel location the address falls into //TODO: test this!!
	wire [18:0] pixel_x, pixel_y;
	calculate_pixel_location my_pixel_location(pixel_x, pixel_y, address, SCREEN_HEIGHT, SCREEN_WIDTH);

	// assign address to a range 
	wire in_arrow_range, in_indicator_range, in_arrow_block_range, in_p1_range, in_p2_range, in_p1_arrow_range, in_p2_arrow_range, in_p1_indicator_range, in_p2_indicator_range;
	assign in_arrow_range = pixel_y < (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT);
	assign in_arrow_block_range = ((SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT - LANE_HEIGHT) < pixel_y) & ( pixel_y < (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT));
	assign in_indicator_range = (pixel_y > (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT));
	assign in_p1_range = (pixel_x < PLAYER_BORDER);
	assign in_p2_range = (pixel_x > PLAYER_BORDER);
	assign in_p1_arrow_range = (in_arrow_range) & (in_p1_range);
	assign in_p2_arrow_range = (in_arrow_range) & (in_p2_range);
	assign in_p1_indicator_range = (in_indicator_range) & (in_p1_range); 
	assign in_p2_indicator_range = (in_indicator_range) & (in_p2_range); 

	// distance of pixel from player edge
	wire [18:0] diff_x, diff_x_p1, diff_x_p2;
	assign diff_x_p1 = pixel_x;
	assign diff_x_p2 = pixel_x - PLAYER_BORDER;
	assign diff_x = in_p1_range ? diff_x_p1 : diff_x_p2;
	
	// assign lane type that address falls into
	wire in_shake_range, in_left_range, in_up_range, in_down_range, in_right_range;
	assign in_shake_range = (diff_x<64);
	assign in_left_range = (64<=diff_x)&(diff_x<128);
	assign in_up_range = (128<=diff_x)&(diff_x<192);
	assign in_down_range = (192<=diff_x)&(diff_x<256);
	assign in_right_range = (256<=diff_x)&(diff_x<320);

	//up 001, left 010, down 011, right 100, shakeyShake 110
	wire [2:0] lane_type0,lane_type1,lane_type2,lane_type3,lane_type;
	assign lane_type0 = in_shake_range ? 3'b110 : 3'b000;
	assign lane_type1 = in_left_range ? 3'b010 : lane_type0;
	assign lane_type2 = in_right_range ? 3'b100 : lane_type1;
	assign lane_type3 = in_up_range ? 3'b001 : lane_type2;
	assign lane_type = in_down_range ? 3'b011 : lane_type3;

	// -- choose index in p1 indicator range -- //
	
	wire [7:0] p1_indicator_index;
	select_indicator_index p1_indicator_selector(p1_indicator, p1_indicator_index, excellent_index, good_index, bad_index, default_index);

	// -- choose index in p2 indicator range -- //
	
	wire [7:0] p2_indicator_index;
	select_indicator_index p2_indicator_selector(p2_indicator, p2_indicator_index, excellent_index, good_index, bad_index, default_index);
	
	// -- choose index in arrow range -- //
	
	wire [7:0] arrow_range_index;

	// figure out which state slot you're in
	wire [18:0] N;
	assign N = pixel_y/STATE_HEIGHT;
	
	// TODO: ********* redo indexing based on the new flattened matrix *********
	// figure out which indices to pull arrow values from
	wire [18:0] arrow_3_N_index, arrow_2_N_index, arrow_1_N_index, arrow_0_N_index;
	assign arrow_0_N_index = N;
	assign arrow_1_N_index = N-19'd1;
	assign arrow_2_N_index = N-19'd2;
	assign arrow_3_N_index = N-19'd3;

	// check to see if the index is valid
	wire arrow_index_0_valid, arrow_index_1_valid, arrow_index_2_valid, arrow_index_3_valid;
	assign arrow_index_0_valid = (arrow_0_N_index < 19'd77) & (arrow_0_N_index >= 19'd0);
	assign arrow_index_1_valid = (arrow_1_N_index < 19'd77) & (arrow_1_N_index >= 19'd0);
	assign arrow_index_2_valid = (arrow_2_N_index < 19'd77) & (arrow_2_N_index >= 19'd0);
	assign arrow_index_3_valid = (arrow_3_N_index < 19'd77) & (arrow_3_N_index >= 19'd0);

	// if the state index is valid, use that. otherwise, use 0 to not cause an error in indexing matrix
	wire [18:0] arrow_0_index, arrow_1_index, arrow_2_index, arrow_3_index;
	assign arrow_0_index = arrow_index_0_valid ? arrow_0_N_index : 19'd0;
	assign arrow_1_index = arrow_index_1_valid ? arrow_1_N_index : 19'd0;
	assign arrow_2_index = arrow_index_2_valid ? arrow_2_N_index : 19'd0;
	assign arrow_3_index = arrow_index_3_valid ? arrow_3_N_index : 19'd0;

	// finally, retrieve your arrow values
	wire [2:0] arrow_0_value, arrow_1_value, arrow_2_value, arrow_3_value;
	assign arrow_0_value = arrow_matrix[arrow_0_index];
	assign arrow_1_value = arrow_matrix[arrow_1_index];
	assign arrow_2_value = arrow_matrix[arrow_2_index];
	assign arrow_3_value = arrow_matrix[arrow_3_index];

	// if any of these values matches your index and is valid
	wire arrow_0_present, arrow_1_present, arrow_2_present, arrow_3_present;
	assign arrow_0_present = ((arrow_0_value==lane_type)&(arrow_index_0_valid));
	assign arrow_1_present = ((arrow_1_value==lane_type)&(arrow_index_1_valid));
	assign arrow_2_present = ((arrow_2_value==lane_type)&(arrow_index_2_valid));
	assign arrow_3_present = ((arrow_3_value==lane_type)&(arrow_index_3_valid));
	
	wire arrow_present;
	assign arrow_present = arrow_0_present | arrow_1_present | arrow_2_present | arrow_3_present;

	
	// now calculate the pixel_x and pixel_y value for each potentially visible state
	wire [18:0] arrow_pixel_x, arrow_pixel_y;

	wire [18:0] lane_number,lane_number0,lane_number1,lane_number2,lane_number3;
	assign lane_number0 = in_shake_range ? 19'd0 : 19'd999;
	assign lane_number1 = in_left_range ? 19'd1 : lane_number0;
	assign lane_number2 = in_up_range ? 19'd2 : lane_number1;
	assign lane_number3 = in_down_range ? 19'd3 : lane_number2;
	assign lane_number = in_right_range ? 19'd4 : lane_number3;

	assign arrow_pixel_x = diff_x - LANE_WIDTH*lane_number;

	wire [18:0] arrow_pixel_y0,arrow_pixel_y1,arrow_pixel_y2,arrow_pixel_y3;
	assign arrow_pixel_y3 = arrow_3_present ? (STATE_HEIGHT*(N-19'd3)) : 19'd999; // last choice
	assign arrow_pixel_y2 = arrow_2_present ? (STATE_HEIGHT*(N-19'd2)) : arrow_pixel_y3;
	assign arrow_pixel_y1 = arrow_1_present ? (STATE_HEIGHT*(N-19'd1)) : arrow_pixel_y2;
	assign arrow_pixel_y0 = arrow_0_present ? (STATE_HEIGHT*N) : arrow_pixel_y1; // first choice


	assign arrow_pixel_y = pixel_y - arrow_pixel_y0;


	// calculate address to pull
	assign image_addr = arrow_pixel_x + arrow_pixel_y*LANE_HEIGHT;

	// now choose which of the image indices to set as your final index
	wire [7:0] arrow_range_index0, arrow_range_index1, arrow_range_index2, arrow_range_index3;
	assign arrow_range_index0 = (arrow_present & in_shake_range) ? shakeyshake_data_index[7:0] : default_index;
	assign arrow_range_index1 = (arrow_present & in_left_range) ? arrow_left_data_index[7:0] : arrow_range_index0;
	assign arrow_range_index2 = (arrow_present & in_up_range) ? arrow_up_data_index[7:0] : arrow_range_index1;
	assign arrow_range_index3 = (arrow_present & in_down_range) ? arrow_down_data_index[7:0] : arrow_range_index2;
	assign arrow_range_index = (arrow_present & in_right_range) ? arrow_right_data_index[7:0] : arrow_range_index3;

	// -- calculate the static block index if you're in the top 4 states -- // // TODO: LATER choose default if no arrow is present
	wire [7:0] arrow_block_index, arrow_block_index0, arrow_block_index1, arrow_block_index2, arrow_block_index3;
	assign arrow_block_index0 = (in_shake_range) ? shakeyshake_index : default_index;
	assign arrow_block_index1 = (in_left_range) ? left_index : arrow_block_index0;
	assign arrow_block_index2 = (in_up_range) ? up_index : arrow_block_index1;
	assign arrow_block_index3 = (in_down_range) ? down_index : arrow_block_index2;
	assign arrow_block_index = (in_right_range) ? right_index : arrow_block_index3;

	// -- now choose which of the selected indexes to use -- //
	wire [7:0] index0, index1, index2;
	assign index0 = in_p1_indicator_range ? p1_indicator_index : default_index;
	assign index1 = in_p2_indicator_range ? p2_indicator_index : index0;
	assign index2 = in_arrow_range ? arrow_range_index : index1;
	
	// final index assignment 
	assign index = in_arrow_block_range ? arrow_block_index : index2;

endmodule

module select_indicator_index(indicator, indicator_index, excellent_index, good_index, bad_index, default_index);
	input [1:0] indicator;
	input [7:0] excellent_index, good_index, bad_index, default_index;
	output [7:0] indicator_index;

	// check whether each category is true
	wire is_excellent, is_good, is_bad;
	assign is_excellent = indicator == 2'b11;
	assign is_good = indicator == 2'b10;
	assign is_bad = indicator == 2'b01;

	// assign index 
	wire [7:0] index0, index1, index2;
	assign index0 = is_excellent ? excellent_index : default_index;
	assign index1 = is_good ? good_index : index0;
	assign indicator_index = is_bad ? bad_index : index1;

endmodule

module calculate_pixel_location(pixel_x, pixel_y, address, SCREEN_HEIGHT, SCREEN_WIDTH);
	input [18:0] SCREEN_HEIGHT, SCREEN_WIDTH, address;
	output [18:0] pixel_x, pixel_y;

	assign pixel_y = address/SCREEN_WIDTH; // some function of the address
	assign pixel_x = address-pixel_y*SCREEN_WIDTH; // some function of the address //TODO:see if you can do this all on one line or not 
	
endmodule