module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							        select,
                      player1_good_bad,
                      player2_good_bad,
                      player1_indexes,
                      player2_indexes);

	
input iRST_n;
input iVGA_CLK;
input [7:0] select;
input [1:0] player1_good_bad, player2_good_bad;
input [77:0] player1_indexes, player2_indexes;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Address generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end
//////////////////////////
//////INDEX addr.

wire [77:0] arrow_array; // 3*26 = 78 indices
wire [1:0] p1_indicator, p2_indicator;

//assign address = 19'd300800;

assign VGA_CLK_n = ~iVGA_CLK;
index_identifier_background_two_matrices my_index_identifier(.address(ADDR), .p1_arrow_array(player1_indexes), .p2_arrow_array(player2_indexes), .p1_indicator(player1_good_bad), .p2_indicator(player2_good_bad), .clock(VGA_CLK_n), .index(index));

//assign index = 8'b01;

/*img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index ) // Index output 
	);*/

//always@(VGA_CLK_n)
//begin
//end

/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);
	

//////
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	















