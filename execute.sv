
// Add PC addition part here later
module execute #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter ALU_SEL_WIDTH = 4,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic clk, rstn,
	input logic [REG_BITS + CTRL_SIZE + REG_WIDTH*3 + 32 - 1:0] dec_exc_reg,
	output logic [REG_BITS + 1 + CTRL_SIZE-7 + REG_WIDTH*3 + 1 - 1:0] exc_mem_reg
);
	logic signed [REG_WIDTH-1:0] bus_a, bus_b;
	logic signed [REG_WIDTH-1:0] alu_out;
	logic alu_zero;
	
	logic [ALU_SEL_WIDTH-1:0] alu_sel;
	logic alu_a_sel, alu_b_sel;
	
	logic [REG_BITS-1:0] rd;
	logic write_en;
	logic [CTRL_SIZE-1:0] ctrl_signals;
	logic [REG_WIDTH-1:0] read_data1, read_data2, imm_data, return_pc;
	logic [31:0] pc;

	alu #(.WIDTH(REG_WIDTH),
			.ALU_SEL(ALU_SEL_WIDTH)) alu_obj (.*);
			
	assign {rd, ctrl_signals, read_data1, read_data2, imm_data, pc} = dec_exc_reg;
	
	assign {write_en, alu_sel, alu_b_sel, alu_a_sel} = ctrl_signals[CTRL_SIZE-1:CTRL_SIZE-7];
	
	assign bus_a = alu_a_sel? pc : read_data1;		// use PC if 1
	assign bus_b = alu_b_sel? imm_data : read_data2;	// immediate if 1
	
	assign return_pc = pc + 4;
	assign exc_mem_reg = {rd, write_en, ctrl_signals[CTRL_SIZE-8:0], alu_out, alu_zero, read_data2, return_pc};
			
endmodule
	
	