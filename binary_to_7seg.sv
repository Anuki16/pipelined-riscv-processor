
module binary_to_7seg ( 
	input logic [3:0] data_in,
	output logic [6:0] data_out
);
    // Make a LUT to convert digits to 7 segment output
    // Input - 4 bits, output - 7 bits
    logic [15:0][6:0] lut_7seg;

    // Output is gfedcba
    assign lut_7seg[0] = 7'b0111111;
    assign lut_7seg[1] = 7'b0000110;
    assign lut_7seg[2] = 7'b1011011;
    assign lut_7seg[3] = 7'b1001111;
    assign lut_7seg[4] = 7'b1100110;
    assign lut_7seg[5] = 7'b1101101;
    assign lut_7seg[6] = 7'b1111101;
    assign lut_7seg[7] = 7'b0000111;
    assign lut_7seg[8] = 7'b1111111;
    assign lut_7seg[9] = 7'b1101111;
	 assign lut_7seg[10] = 7'b1110111;	//A
	 assign lut_7seg[11] = 7'b1111100;	//b
	 assign lut_7seg[12] = 7'b0111001;	//C	
	 assign lut_7seg[13] = 7'b1011110;	//d
	 assign lut_7seg[14] = 7'b1111001;	//E
    assign lut_7seg[15] = 7'b1110001;	//F
	 
	 assign data_out = ~lut_7seg[data_in];
	 
endmodule

/*
Seven segment display
    a
f       b
    g
e       c
    d
*/