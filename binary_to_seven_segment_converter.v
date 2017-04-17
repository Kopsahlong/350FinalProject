module binary_to_seven_segment_converter(binary_input_10b, seg1_output, seg2_output, seg3_output, seg4_output);
	// code adapted from http://verilogcodes.blogspot.com/2015/10/verilog-code-for-8-bit-binary-to-bcd.html
	input [9:0] binary_input_10b;
	output [6:0] seg1_output, seg2_output, seg3_output, seg4_output;

	wire negative;
	assign negative = binary_input_10b[9] ? 1'b1 : 1'b0;
	wire [7:0] inverted_input;

	wire [31:0] to_invert, inverted;
	assign to_invert[31:8] = 24'b1;
	assign to_invert[7:0] = binary_input_10b[7:0];
	inverter_32b B_inverter(.to_invert(to_invert), .inverted(inverted));
	assign inverted_input = inverted[7:0];
	
    
    //input ports and their sizes
    wire [7:0] bin;
	 assign bin = negative ? inverted_input : binary_input_10b[7:0];
    //output ports and, their size
    //wire [11:0] bcd;
    //Internal variables
    reg [11 : 0] bcd; 
     reg [3:0] i;   
     
     //Always block - implement the Double Dabble algorithm
     always @(bin)
        begin
            bcd = 0; //initialize bcd to zero.
            for (i = 0; i < 8; i = i+1) //run for 8 iterations
            begin
                bcd = {bcd[10:0],bin[7-i]}; //concatenation
                    
                //if a hex digit of 'bcd' is more than 4, add 3 to it.  
                if(i < 7 && bcd[3:0] > 4) 
                    bcd[3:0] = bcd[3:0] + 3;
                if(i < 7 && bcd[7:4] > 4)
                    bcd[7:4] = bcd[7:4] + 3;
                if(i < 7 && bcd[11:8] > 4)
                    bcd[11:8] = bcd[11:8] + 3;  
            end
        end     

   // assign numbers to seven seg displays
   assign seg4_output = negative ? 7'b0111111 : 7'b1111111;
   numToSegment seg3_encoder(.number(bcd[11:8]), .seg(seg3_output));
   numToSegment seg2_encoder(.number(bcd[7:4]), .seg(seg2_output));
   numToSegment seg1_encoder(.number(bcd[3:0]), .seg(seg1_output));
 
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