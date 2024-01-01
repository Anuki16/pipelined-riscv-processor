
module decode #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic clk, rstn, stall, flush,
	input logic [64:0] fetch_dec_reg,
	input logic write_en,
	input logic [REG_BITS-1:0] write_reg,
	input logic signed [REG_WIDTH-1:0] write_data,
	output logic [REG_BITS*3 + CTRL_SIZE + REG_WIDTH*3 + 32 + 1 - 1:0] dec_exc_reg,
	
	output logic [REG_WIDTH-1:0] x5, x6, x11
);
	logic [REG_BITS-1:0] read_reg1, read_reg2, rd;
	logic signed [REG_WIDTH-1:0] read_data1, read_data2, imm_data;
	logic [31:0] instruction;
	logic [31:0] pc;
	logic pred;
	
	logic ex_no_stay;
	logic [CTRL_SIZE-1:0] ctrl_signals;

	regfile #(.WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT)) regfile_obj(.*);
				
	immgen immgen_obj (
			.inst(instruction),
			.imm_out(imm_data)
	);
	
	controller #(.CTRL_SIZE(CTRL_SIZE)) ctrl_obj (.*);
	
	assign {instruction, pc, pred} = fetch_dec_reg;
	assign ex_no_stay = 1;
	
	assign read_reg1 = instruction[19:15];
	assign read_reg2 = instruction[24:20];
	assign rd = instruction[11:7];	// not used now
	
	always @(posedge clk or negedge rstn) begin
		if (~rstn) dec_exc_reg <= 'b0;
		else if (~stall) dec_exc_reg <= {read_reg1, read_reg2, rd, ctrl_signals, read_data1, read_data2, imm_data, pc, pred};
		else if (flush) dec_exc_reg <= 'b0;
	end
	
endmodule