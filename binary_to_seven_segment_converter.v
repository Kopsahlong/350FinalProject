module binary_to_seven_segment_converter(binary_input_10b, seg1_output, seg2_output, seg3_output, seg4_output);
	// code adapted from http://www.deathbylogic.com/2013/12/binary-to-binary-coded-decimal-bcd-converter/
	input [9:0] binary_input_10b;
	output [6:0] seg1_output, seg2_output, seg3_output, seg4_output;

	wire negative;
	assign negative = binary_input_10b ? 1'b1 : 1'b0;
	wire [7:0] inverted_input;

	wire [31:0] to_invert, inverted;
	assign to_invert[31:8] = 24'b1;
	assign to_invert[7:0] = binary_input_10b[7:0];
	inverter_32b B_inverter(.to_invert(to_invert), .inverted(inverted));
	assign inverted_input = inverted[7:0];
	
	// I/O Signal Definitions
	wire  [7:0] number;
	assign number = negative ? inverted_input : binary_input_10b[7:0];
	reg [3:0] hundreds;
	reg [3:0] tens;
	reg [3:0] ones;
   
   // Internal variable for storing bits
   reg [19:0] shift;
   integer i;
   
   always @(number)
   begin
      // Clear previous number and store new number in shift register
      shift[19:8] = 0;
      shift[7:0] = number;
      
      // Loop eight times
      for (i=0; i<8; i=i+1) begin
         if (shift[11:8] >= 5)
            shift[11:8] = shift[11:8] + 3;
            
         if (shift[15:12] >= 5)
            shift[15:12] = shift[15:12] + 3;
            
         if (shift[19:16] >= 5)
            shift[19:16] = shift[19:16] + 3;
         
         // Shift entire register left once
         shift = shift << 1;
      end
      
      // Push decimal numbers to output
      hundreds = shift[19:16];
      tens     = shift[15:12];
      ones     = shift[11:8];

      // assign numbers to seven seg displays
      assign seg4_output = negative ? 7'b1111111 : 7'b0111111;
      numToSegment(.number(hundreds), .seg(seg3_output));
      numToSegment(.number(tens), .seg(seg2_output));
      numToSegment(.number(ones), .seg(seg1_output));
   end
 
endmodule

module numToSegment(number, seg);
	input [4:0] number;
	output [6:0] seg;
	
	wire [9:0] n;
	and(n[9], number[3], ~number[2], ~number[1], number[0]); 
	and(n[8], number[3], ~number[2], ~number[1], ~number[0]); 
	and(n[7], ~number[3], number[2], number[1], number[0]); 
	and(n[6], ~number[3], number[2], number[1], ~number[0]); 
	and(n[5], ~number[3], number[2], ~number[1], number[0]); 
	and(n[4], ~number[3], number[2], ~number[1], ~number[0]); 
	and(n[3], ~number[3], ~number[2], number[1], number[0]); 
	and(n[2], ~number[3], ~number[2], number[1], ~number[0]); 
	and(n[1], ~number[3], ~number[2], ~number[1], number[0]); 
	and(n[0], ~number[3], ~number[2], ~number[1], ~number[0]); 
	
	nor(seg[0], n[0], n[2], n[3], n[5], n[6], n[7], n[8], n[9]);
	nor(seg[1], n[0], n[1], n[2], n[3], n[4], n[7], n[8], n[9]);
	nor(seg[2], n[0], n[1], n[3], n[4], n[5], n[6], n[7], n[8], n[9]);
	nor(seg[3], n[0], n[2], n[3], n[5], n[6], n[8], n[9]);
	nor(seg[4], n[0], n[2], n[6], n[8]);
	nor(seg[5], n[0], n[4], n[5], n[6], n[8], n[9]);
	nor(seg[6], n[2], n[3], n[4], n[5], n[6], n[8], n[9]);	
endmodule