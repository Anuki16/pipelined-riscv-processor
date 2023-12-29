
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
	assign memory[9] = 32'b0000000_01100_01011_000_01000_1100011;	// beq x11, x12, 8
	assign memory[10] = 32'b00000000110000101000001010010011;		// addi x5 x5 12	
	assign memory[11] = 32'b0100000_00111_00101_111_00101_0110011;	// mul x5 x5 x7	-> x5 = 240 = 0xF0
	
	always_comb begin
		for (int i = 12; i < NUM_INST; i++) memory[i] = 32'b0;
	end
	
endmodule

