`include "controls.sv"

module alu #(
	parameter WIDTH = 32,
	parameter ALU_SEL = 4
)(
	input logic signed [WIDTH-1:0] bus_a, bus_b,	
	input logic [ALU_SEL-1:0] alu_sel,
	output logic signed [WIDTH-1:0] alu_out,
	output logic alu_zero
);
	
	always_comb begin
		unique case (alu_sel)
			`ALU_ADD: alu_out = bus_a + bus_b;
			`ALU_SUB: alu_out = bus_a - bus_b;
			`ALU_SLL: alu_out = bus_a << $unsigned(bus_b);
			`ALU_SRL: alu_out = bus_a >> $unsigned(bus_b);
			`ALU_SRA: alu_out = bus_a >>> $unsigned(bus_b);	// Arithmetic right shift retains MSB
			`ALU_AND: alu_out = bus_a & bus_b;
			`ALU_OR: alu_out = bus_a | bus_b;
			`ALU_XOR: alu_out = bus_a ^ bus_b;
			`ALU_SLT: alu_out = bus_a < bus_b;
			`ALU_SLTU: alu_out = $unsigned(bus_a) < $unsigned(bus_b);
			`ALU_A:	 alu_out = bus_a;
			`ALU_B:	 alu_out = bus_b;
			//`ALU_MUL: alu_out = $unsigned(bus_a) * $unsigned(bus_b);
			default: alu_out = 'b0;
		endcase
	end
	
	assign alu_zero = (alu_out == 0);
	
endmodule