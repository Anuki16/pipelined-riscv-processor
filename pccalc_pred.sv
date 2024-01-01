`include "controls.sv"

module pccalc_pred (
	input logic clk, rstn, stall, prev_pred,
	input logic [31:0] prev_pc, pc_with_offset,		// For branch and JAL
	input logic [31:0] target_pc,	// For JALR, already calculated PC
	
	input logic [2:0] branch_type,
	input logic alu_zero,
	
	output logic [31:0] pc,		// PC register
	output logic flush, out_pred
);

	logic [31:0] next_pc, next_pc_pred;
	logic branch_taken, pred;
	
	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			pc <= 32'b0;
			out_pred <= 1'b0;
		end
		else if (~stall) begin
			pc <= next_pc;
			out_pred <= flush ? branch_taken : pred;
		end else begin
			pc <= pc;
			out_pred <= out_pred;
		end
	end
	
	// Next PC logic
	always_comb begin
		if (!flush) 	// Directly use prediction
			next_pc = next_pc_pred;
		else if (!branch_type || !branch_taken) // branch predicted taken, actual is not taken
			next_pc = prev_pc + 4;
		else if (branch_type == `JMP_JALR) 		// predicted not taken, actual is taken
			next_pc = {target_pc[31:1], 1'b0};	// zero LSB
		else												// predicted not taken, actual is taken
			next_pc = pc_with_offset;
	end
	
	// Branch logic
	assign branch_taken = (branch_type == `JMP_JAL) ||
						 (branch_type == `JMP_JALR) || 
						 (branch_type == `JMP_BEQ && alu_zero) ||
						 (branch_type == `JMP_BNE && (!alu_zero)) ||
						 (branch_type == `JMP_BLT && (!alu_zero)) ||
						 (branch_type == `JMP_BGT && alu_zero); 	// using slt/sltu
						 
	// If processed instruction is a branch and the prediction for it was wrong, flush
	assign flush = (branch_type) && (branch_taken ^ prev_pred);
						 
	branch_target btu (
        .clk(clk),
        .rstn(rstn),
        .branch_taken(branch_taken),
        .epc(prev_pc),
        .fpc(pc),
        .pred(pred),
		  .next_pc(next_pc_pred)
    );

endmodule