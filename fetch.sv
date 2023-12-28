

module fetch #(
	parameter NUM_INST = 128
)(
	input logic clk, rstn,
	input logic alu_zero,
	input logic [2:0] branch_type,
	input logic [31:0] target_pc, pc_with_offset,
	output logic [63:0] fetch_dec_reg
);

	logic [31:0] pc;
	
	logic [31:0] instruction;
	
	pccalc pclogic_obj (.*);
	
	inst_memory #(.NUM_INST(NUM_INST)) instmem_obj (.*);
	
	assign fetch_dec_reg = {instruction, pc};		
	
endmodule