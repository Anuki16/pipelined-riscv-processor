
module inst_memory #(parameter NUM_INST = 128)
(
	input logic [31:0] pc,
	output logic [31:0] instruction
);

	logic [3:0][7:0] memory [0:NUM_INST-1];
	
	// Since PC is byte addressed, we must ignore last 2 bits when indexing
	assign instruction = memory[pc >> 2];
	
	/* Program to be executed */
	assign memory[0] = 32'b00000000010000000000001010010011;			// addi x5 x0 4	-> x5 = 4
	assign memory[1] = 32'b01000101011001111000_00110_0110111;		// lui x6 0x45678 -> x6 = 0x45678000
	assign memory[2] = 32'b00010010001100110000001100010011;			// addi x6 x6 0x123	-> x6 = 0x45678123
	assign memory[3] = 32'b00000000011000101010000000100011;			// sw x6, 0(x5) 	-> store x6 at mem address 4
	assign memory[4] = 32'b00000000011000101010001000100011;			// sw x6, 4(x5) 	-> store x6 at mem address 8
	assign memory[5] = 32'b00000000011000101010010000100011;			// sw x6, 8(x5) 	-> store x6 at mem address 12
	assign memory[6] = 32'b00000011110000000000001110010011;			// addi x7 x0 60	-> x7 = 60
	assign memory[7] = 32'b00000000100000101101010110000011;			// lhu x11, 8(x5)	-> x11 = 8123
	assign memory[8] = 32'b00000000000000101101011000000011;			// lhu x12, 0(x5)	-> x12 = 8123
	assign memory[9] = 32'b0;													// nop
	assign memory[10] = 32'b0000000_01100_01011_000_10000_1100011;	// beq x11, x12, 8		remember to change this if you remove the nops
	assign memory[11] = 32'b00000000110000101000001010010011;		// addi x5 x5 12	
	assign memory[12] = 32'b0000000_00101_00111_100_00101_0110011;	// xor x5 x7 x5	-> x5 = 56 = 0x38
	
	assign memory[13]= 32'b00000000000000000000001100010011;         //addi x6, x0, 0         -> load i=0 to r2 
	assign memory[14]= 32'b00000000001100000000000010010011;         //addi x1, x0, 3         -> load 3 to r1
	assign memory[15]= 32'b00000000000000000000000110010011;         //addi x3, x0, 0          -> load a=0 to r3 
	assign memory[16]= 32'b00000000000100011000000110010011;         //addi r3,r3,1    ->a++
	assign memory[17] = 32'b00000000000100110000001100010011;         //addi r6,r6,1    ->i++
	assign memory[18]= 32'b11111110000100110100110011100011;         //blt r6,r1,-8    ->go to mem 2 by offseting -8
	assign memory[19] = 32'b00000000001100110000001100110011;         //add x6, x6, x3
	
	always_comb begin
		for (int i = 20; i < NUM_INST; i++) memory[i] = 32'b0;
	end
	
endmodule

