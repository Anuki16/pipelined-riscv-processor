
module writeback #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic clk, rstn,
	input logic [1 + REG_BITS + REG_WIDTH*3 + 2 - 1:0] mem_wb_reg,
	output logic write_en,
	output logic [REG_BITS-1:0] write_reg,
	output logic signed [REG_WIDTH-1:0] write_data
);

	logic signed [REG_WIDTH-1:0] alu_out, mem_read_data, return_pc;
	logic [1:0] write_src_sel;
	
	mux3 #(.WIDTH(REG_WIDTH)) reg_src_mux (
			.a0(alu_out),
			.a1(mem_read_data),
			.a2(return_pc),
			.sel(write_src_sel),
			.out(write_data)
	);
	
	assign {write_en, write_reg, alu_out, mem_read_data, return_pc, write_src_sel} = mem_wb_reg;
	
endmodule