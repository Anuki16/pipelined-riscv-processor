
// Add PC addition part here later
module execute #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter ALU_SEL_WIDTH = 4,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic clk, rstn, stall, 
	input logic [1:0] forward_A, forward_B,
	input logic [REG_WIDTH-1:0] wb_data_ex_mem, wb_data_mem_wb,
	input logic [REG_BITS*3 + CTRL_SIZE + REG_WIDTH*3 + 32 + 1 - 1:0] dec_exc_reg,
	output logic [REG_BITS + 1 + CTRL_SIZE-7 + REG_WIDTH*3 - 1:0] exc_mem_reg,
	output logic alu_zero, prev_pred,
	output logic [2:0] branch_type,
	output logic [31:0] target_pc, pc_with_offset, prev_pc
);
	logic signed [REG_WIDTH-1:0] bus_a, bus_b;
	logic signed [REG_WIDTH-1:0] alu_out;
	
	logic [ALU_SEL_WIDTH-1:0] alu_sel;
	logic alu_a_sel, alu_b_sel;
	
	logic [REG_BITS-1:0] rd, rs1, rs2;
	logic write_en;
	logic [CTRL_SIZE-1:0] ctrl_signals;
	logic [REG_WIDTH-1:0] read_data1, read_data2, imm_data, return_pc;
	logic [REG_WIDTH-1:0] read_sel_data1, read_sel_data2;
	logic [31:0] pc;

	alu #(.WIDTH(REG_WIDTH),
			.ALU_SEL(ALU_SEL_WIDTH)) alu_obj (.*);
			
	mux3 #(.WIDTH(REG_WIDTH)) read_data1_mux (
			.a0(read_data1),
			.a1(wb_data_ex_mem),
			.a2(wb_data_mem_wb),
			.sel(forward_A),
			.out(read_sel_data1)
	);
	
	mux3 #(.WIDTH(REG_WIDTH)) read_data2_mux (
			.a0(read_data2),
			.a1(wb_data_ex_mem),
			.a2(wb_data_mem_wb),
			.sel(forward_B),
			.out(read_sel_data2)
	);
			
	assign {rs1, rs2, rd, ctrl_signals, read_data1, read_data2, imm_data, pc, prev_pred} = dec_exc_reg;
	
	assign {write_en, alu_sel, alu_b_sel, alu_a_sel} = ctrl_signals[CTRL_SIZE-1:CTRL_SIZE-7];
	
	assign bus_a = alu_a_sel? pc : read_sel_data1;		// use PC if 1
	assign bus_b = alu_b_sel? imm_data : read_sel_data2;	// immediate if 1
	
	assign prev_pc = pc;
	assign return_pc = pc + 4;
	assign target_pc = alu_out;
	assign pc_with_offset = pc + imm_data;
	assign branch_type = ctrl_signals[CTRL_SIZE-15:CTRL_SIZE-17];
	
	always @(posedge clk or negedge rstn) begin
		if (~rstn) exc_mem_reg <= 'b0;
		else if (~stall) exc_mem_reg <= {rd, write_en, ctrl_signals[CTRL_SIZE-8:0], alu_out, read_sel_data2, return_pc};
	end
			
endmodule
	
	