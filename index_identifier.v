module index_identifier(address, clock, index){
	input [18:0] address;
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


	// data memory to pull from game logic 


	// hard coded constants that can be changed
	parameter SCREEN_WIDTH = 640;
	parameter SCREEN_HEIGHT = 480;
	parameter ARROW_WIDTH = 40;
	parameter PLAYER_BORDER = SCREEN_WIDTH/2;
	parameter LANE_WIDTH = SCREEN_WIDTH/10;
	parameter LANE_HEIGHT = LANE_WIDTH;
	parameter INDICATOR_PANEL_HEIGHT = SCREEN_WIDTH/4 - LANE_HEIGHT;
	parameter INDICATOR_PANEL_WIDTH =  SCREEN_WIDTH/2;
	parameter OVERLAP_NUMBER = 2; // number of overlapping arrows
	parameter N = SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT; // number of states 

	// check which grid area the address falls into 
	parameter pixel_width = // some function of the address
	parameter pixel_height = // some function of the address

	// PLAYER 1 ARROW ADDRESS
	// range HEIGHT = [0 -> SCREEN_HEIGHT - INDICATOR_PANEL_HEIGHT] and WIDTH = [0 -> PLAYER_BORDER]

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