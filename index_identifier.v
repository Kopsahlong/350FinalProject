module index_identifier(address, arrow_array, p1_indicator, p2_indicator, clock, index){
	input [18:0] address;
	input [25:0][2:0] arrow_array; 
	input [1:0] p1_indicator, p2_indicator;
	input clock;
	output [7:0] index;

	wire [18:0] arrow_left_addr, arrow_up_addr, arrow_down_addr, arrow_right_addr, shakeyshake_addr;
	wire [7:0] arrow_left_index, arrow_up_index, arrow_down_index, arrow_right_index, shakeyshake_index;


	// data blocks needed to load images
	arrow_left_data my_arrow_left_data(
		.address(arrow_left_addr), //Q: what should the address size be in this case?
		.clock(clock), //Q: check if this should be ~clock
		.q(arrow_left_index))

	arrow_up_data my_arrow_up_data(
		.address(arrow_up_addr),
		.clock(clock),
		.q(arrow_up_index))

	arrow_down_data my_arrow_down_data(
		.address(arrow_down_addr),
		.clock(clock),
		.q(arrow_down_index))

	arrow_right_data my_arrow_right_data(
		.address(arrow_right_addr),
		.clock(clock),
		.q(arrow_right_index))

	shakeyshake_data my_arrow_right_data(
		.address(shakeyshake_addr),
		.clock(clock),
		.q(shakeyshake_index))

	// TODO: add in lightning bolt 

	// data memory to pull from game logic 

	// hard coded constants that can be changed
	parameter SCREEN_WIDTH = 640;
	parameter SCREEN_HEIGHT = 480;
	parameter PLAY_HEIGHT = 432;
	parameter PLAYER_BORDER = SCREEN_WIDTH/2; //320
	parameter LANE_WIDTH = SCREEN_WIDTH/10; //64
	parameter LANE_HEIGHT = LANE_WIDTH; //64
	parameter STATE_HEIGHT = LANE_WIDTH/4; //16
	parameter INDICATOR_PANEL_HEIGHT = SCREEN_HEIGHT-PLAY_HEIGHT; //53

	// check which pixel location the address falls into //TODO: test this!!
	parameter pixel_x = address/SCREEN_WIDTH; // some function of the address
	parameter pixel_y = SCREEN_WIDTH - address%SCREEN_WIDTH; // some function of the address

	// distance of pixel from player edge
	parameter diff_x_p1 = pixel_x - 0;
	parameter diff_x_p2 = pixel_x - PLAYER_BORDER;
	parameter diff_x = in_p1_range ? diff_x_p1 : diff_x_p2;

	// assign address to a range 
	assign in_arrow_range = (pixel_y < (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT));
	assign in_indicator_range = (pixel_y > (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT));
	assign in_p1_range = (pixel_x < PLAYER_BORDER);
	assign in_p2_range = (pixel_x > PLAYER_BORDER);
	assign in_p1_arrow_range = (in_arrow_range) & (in_p1_range));
	assign in_p2_arrow_range = (in_arrow_range) & (in_p2_range);
	assign in_p1_indicator_range = (in_indicator_range) & (in_p1_range); 
	assign in_p2_indicator_range = (in_indicator_range) & (in_p2_range); 

	// assign address to a lane type
	assign lane_type;
	assign in_shake_range = (diff_x<LANE_WIDTH);
	assign in_left_range = (LANE_WIDTH<=diff_x<2*LANE_WIDTH);
	assign in_up_range = (2*LANE_WIDTH<=diff_x<3*LANE_WIDTH);
	assign in_down_range = (3*LANE_WIDTH<=diff_x<4*LANE_WIDTH);
	assign in_right_range = (4*LANE_WIDTH<=diff_x<5*LANE_WIDTH);

	//up 001, left 010, down 011, right 100, shakeyShake 110
	assign lane_type0 = in_shake_range ? 3'b110 : 3'b000;
	assign lane_type1 = in_left_range ? 3'b010 : lane_type0;
	assign lane_type2 = in_right_range ? 3'b100 : lane_type1;
	assign lane_type3 = in_up_range ? 3'b001 : lane_type2;
	assign lane_type = in_down_range ? 3'b011 : lane_type3;

	// choose index in p1 indicator range
	if(in_p1_indicator_range) begin
		select_indicator_index(p1_indicator, index);
	end

	// choose index in p2 indicator range
	if(in_p2_indicator_range) begin
		select_indicator_index(p2_indicator, index);
	end

	// choose index in arrow range
	if(in_arrow_range) begin
		// figure out which state you're in
		wire N;
		parameter N = pixel_y/STATE_WIDTH;

		wire [2:0] arrow_value_0, arrow_value_1, arrow_value_2, arrow_value_3;

		// figure out which indices to pull arrow values from
		parameter arrow_0_N_index = N;
		parameter arrow_1_N_index = N-1;
		parameter arrow_2_N_index = N-2;
		parameter arrow_3_N_index = N-3;

		// check to see if the index is valid
		wire arrow_index_0_valid, arrow_index_1_valid, arrow_index_2_valid, arrow_index_3_valid;
		assign arrow_index_0_valid = arrow_0_N_index > 0;
		assign arrow_index_1_valid = arrow_1_N_index > 0;
		assign arrow_index_2_valid = arrow_2_N_index > 0;
		assign arrow_index_3_valid = arrow_3_N_index > 0;

		// if the state index is valid, use that. otherwise, use 0
		parameter arrow_0_index = arrow_index_0_valid ? arrow_0_N_index : 0;
		parameter arrow_1_index = arrow_index_1_valid ? arrow_1_N_index : 0;
		parameter arrow_2_index = arrow_index_2_valid ? arrow_2_N_index : 0;
		parameter arrow_3_index = arrow_index_3_valid ? arrow_3_N_index : 0;

		// finally, retrieve your arrow values
		wire [2:0] arrow_0_value, arrow_1_value, arrow_2_value, arrow_3_value;
		arrow_0_value = arrow_array[arrow_0_index]; // TODO: make sure you can index with this
		arrow_1_value = arrow_array[arrow_1_index];
		arrow_2_value = arrow_array[arrow_2_index];
		arrow_3_value = arrow_array[arrow_3_index];

		// find the highest state that actually contains the proper arrow type for your lane
		parameter visible_state;

		if((arrow_0_value==lane_type)&&(arrow_index_0_valid)) begin
			visible_state = 0;
		end 
		else if((arrow_1_value==lane_type)&&(arrow_index_1_valid)) begin
			visible_state = 1;
		end 
		else if((arrow_2_value==lane_type)&&(arrow_index_2_valid)) begin
			visible_state = 2;
		end 
		else if((arrow_3_value==lane_type)&&()arrow_index_3_valid) begin
			visible_state = 3;
		end 
		else begin // none contain the proper arrow, use background color 
			visible_state = -1;
		end

		// pull index values from the various arrow value positions //TODO: check this fo sho
		arrow_pixel_y = pixel_y - N*STATE_WIDTH;
		arrow_pixel_x = diff_x/64;

		// calculate address to pull
		assign arrow_addr = arrow_pixel_x * arrow_pixel_y;

		// pull these index values from the correct block <- need 1 clock cycle to pull 
		parameter 
		if(in_shake_range) begin
			arrow_left_addr = arrow_addr;

		end
		if(in_left_range) begin
			
		end

		// calculate position on 64 x 64 block that you should be pulling a pixel from for each state 


		parameter arrow_width 

		// Index of middle arrow value will be from
		// 21.33 -> 42.67

		// Index of bottom arrow value will be from 
		// 0 -> 21.33

		if(in_p1_range) begin
			
		end
		if(in_p2_range) begin
			
		end
	end

module select_indicator_index(indicator, index);
	input [1:0] indicator;
	output [7:0] index;

	// congifgure hex values for each category
	wire [7:0] index_excellent, index_good, index_bad, index_default;
	assign index_excellent = 6'H39FF14; // green
	assign index_good = 6'HFF7435; // orange
	assign index_bad = 6'HD82735; // red
	assign index_default = 6'H06A9FC; // blue

	// check whether each category is true
	wire is_excellent, is_good, is_bad;
	assign is_excellent = p1_indicator == 2'b11;
	assign is_good = p1_indicator == 2'b10;
	assign is_bad = p1_indicator == 2'b01;

	// assign index 
	wire [7:0] index0, index1;
	assign index0 = is_excellent ? index_excellent : index_default;
	assign index1 = is_good ? index_good : index0;
	assign index = is_bad ? index_bad : index1;

endmodule 
	// based on pixel height, identify corresponding N state

	// based on pixel width, indicate what type it should be (shake, left, right, up, down)

	// if that chosen type corresponds with what is in the array for that Nth state, calculate the address 

	// based on 
	// PLAYER 2 ARROW ADDRESS
	// range HEIGHT = [0 -> SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT] and WIDTH = [PLAYER_BORDER -> SCREEN_WIDTH]

	// PLAYER 1 INDICATOR PANEL
	// range HEIGHT = [SCREEN_HEIGHT-INDICATOR_HEIGHT -> SCREEN_HEIGHT] and WIDTH = [0 -> PLAYER_BORDER]

	// PLAYER 2 INDICATOR PANEL
	// range HEIGHT = [SCREEN_HEIGHT-INDICATOR_HEIGHT -> SCREEN_HEIGHT] and WIDTH = [PLAYER_BORDER -> SCREEN_WIDTH]


	// If pixel chosen is a 'clear' color, set it it to default background color

}