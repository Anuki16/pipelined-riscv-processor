

module fetch #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter NUM_MEM_LOCS = 64,
	parameter NUM_INST = 128,
	parameter ALU_SEL_WIDTH = 4,
	parameter CTRL_SIZE = 21
)(
	input logic clk, rstn,
	input logic alu_zero,
	input logic [2:0] branch_type,
	input logic [31:0] target_pc, pc_offset,
	output logic [63:0] fetch_dec_reg
);

	logic [31:0] pc, return_pc;
	
	logic [31:0] instruction;
	
	pccalc pclogic_obj (.*);
	
	inst_memory #(.NUM_INST(NUM_INST)) instmem_obj (.*);
	
	assign fetch_dec_reg = {instruction, pc};		// add return_pc if needed later
	
endmodule