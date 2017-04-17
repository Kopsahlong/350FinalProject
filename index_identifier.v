module index_identifier(address, arrow_array, p1_indicator, p2_indicator, clock, index){
	input [18:0] address;
	input [19:0][2:0] arrow_array; 
	input [1:0] p1_indicator, p2_indicator;
	input clock;
	output [7:0] index;

	wire [18:0] arrow_left_addr, arrow_up_addr, arrow_down_addr, arrow_right_addr;
	wire [7:0] arrow_left_index, arrow_up_index, arrow_down_index, arrow_right_index;


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

	// TODO: add in lightning bolt 

	// data memory to pull from game logic 

	// hard coded constants that can be changed
	parameter SCREEN_WIDTH = 640;
	parameter SCREEN_HEIGHT = 480;
	parameter PLAY_HEIGHT = 427;
	parameter PLAYER_BORDER = SCREEN_WIDTH/2;
	parameter LANE_WIDTH = SCREEN_WIDTH/10;
	parameter LANE_HEIGHT = LANE_WIDTH;
	parameter INDICATOR_PANEL_HEIGHT = SCREEN_HEIGHT-PLAY_HEIGHT; //53
	parameter INDICATOR_PANEL_WIDTH =  SCREEN_WIDTH/2; // 320

	// check which grid area the address falls into 
	parameter pixel_width = address/SCREEN_WIDTH; // some function of the address
	parameter pixel_height = SCREEN_WIDTH - address%SCREEN_WIDTH; // some function of the address

	// PLAYER 1 ARROW ADDRESS
	// range HEIGHT = [0 -> SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT] and WIDTH = [0 -> PLAYER_BORDER]
	assign in_arrow_range = (pixel_height < (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT));
	assign in_indicator_range = (pixel_height > (SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT));
	assign in_p1_range = (pixel_width < PLAYER_BORDER);
	assign in_p2_range = (pixel_width > PLAYER_BORDER);
	assign in_p1_arrow_range = (in_arrow_range) & (in_p1_range));
	assign in_p2_arrow_range = (in_arrow_range) & (in_p2_range);
	assign in_p1_indicator_range = (in_indicator_range) & (in_p1_range); 
	assign in_p2_indicator_range = (in_indicator_range) & (in_p2_range); 

	// TODO: extract out to a module
	if(in_p1_indicator_range) begin
		// congifgure hex values for each category
		assign index_excellent = 6'H39FF14; // green
		assign index_good = 6'HFF7435; // orange
		assign index_bad = 6'HD82735; // red
		assign index_default = 6'H06A9FC; // blue

		// check whether each category is true
		assign is_excellent = p1_indicator == 2'b11;
		assign is_good = p1_indicator == 2'b10;
		assign is_bad = p1_indicator == 2'b01;

		// assign index 
		assign index0 = is_excellent ? index_excellent : index_default;
		assign index1 = is_good ? index_good : index0;
		assign index = is_bad ? index_bad : index1;
	end

	if(in_p1_indicator_range) begin
		// congifgure hex values for each category
		assign index_excellent = 6'H39FF14; // green
		assign index_good = 6'HFF7435; // orange
		assign index_bad = 6'HD82735; // red
		assign index_default = 6'H06A9FC; // blue

		// check whether each category is true
		assign is_excellent = p1_indicator == 2'b11;
		assign is_good = p1_indicator == 2'b10;
		assign is_bad = p1_indicator == 2'b01;

		// assign index 
		assign index0 = is_excellent ? index_excellent : index_default;
		assign index1 = is_good ? index_good : index0;
		assign index = is_bad ? index_bad : index1;
	end


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