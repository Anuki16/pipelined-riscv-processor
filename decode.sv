
module decode #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic clk, rstn,
	input logic [63:0] fetch_dec_reg,
	input logic [37:0] mem_wb_reg,
	output logic [REG_BITS + CTRL_SIZE + REG_WIDTH*3 + 32 - 1:0] dec_exc_reg
);
	logic [REG_BITS-1:0] read_reg1, read_reg2, write_reg, rd;
	logic signed [REG_WIDTH-1:0] read_data1, read_data2, write_data, imm_data;
	logic [31:0] instruction;
	logic [31:0] pc;
	
	logic write_en;
	logic ex_no_stay;
	logic [CTRL_SIZE-1:0] ctrl_signals;

	regfile #(.WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT)) regfile_obj(.*);
				
	immgen immgen_obj (
			.inst(instruction),
			.imm_out(imm_data)
	);
	
	controller #(.CTRL_SIZE(CTRL_SIZE)) ctrl_obj (.*);
	
	assign {instruction, pc} = fetch_dec_reg;
	assign {write_en, write_reg, write_data} = mem_wb_reg;
	assign ex_no_stay = 1;
	
	assign read_reg1 = instruction[19:15];
	assign read_reg2 = instruction[24:20];
	assign rd = instruction[11:7];	// not used now
	
	assign dec_exc_reg = {rd, ctrl_signals, read_data1, read_data2, imm_data, pc};
	
endmodule