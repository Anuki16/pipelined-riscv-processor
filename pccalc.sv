`include "controls.sv"

module pccalc (
	input logic clk, rstn,
	input logic [31:0] pc_offset,		// For branch and JAL
	input logic [31:0] target_pc,	// For JALR, already calculated PC
	
	input logic [2:0] branch_type,
	input logic alu_zero,
	
	output logic [31:0] pc,		// PC register
	output logic [31:0] return_pc
);

	logic [31:0] next_pc;
	logic branch;
	
	always @(posedge clk or negedge rstn) begin
		if (!rstn) pc <= 32'b0;
		else pc <= next_pc;
	end
	
	// Next PC logic
	always_comb begin
		if (!branch_type || !branch) // no branching
			next_pc = pc + 4;
		else if (branch_type == `JMP_JALR) 
			next_pc = {target_pc[31:1], 1'b0};	// zero LSB
		else
			next_pc = pc + pc_offset;
	end
	
	// Branch logic
	assign branch = (branch_type == `JMP_JAL) ||
						 (branch_type == `JMP_JALR) || 
						 (branch_type == `JMP_BEQ && alu_zero) ||
						 (branch_type == `JMP_BNE && (!alu_zero)) ||
						 (branch_type == `JMP_BLT && (!alu_zero)) ||
						 (branch_type == `JMP_BGT && alu_zero); 	// using slt/sltu
						 
	assign return_pc = pc + 4;

endmodule