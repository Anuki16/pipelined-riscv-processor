`include "controls.sv"

module datapath_mem #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter NUM_MEM_LOCS = 64,
	parameter NUM_INST = 128,
	parameter ALU_SEL_WIDTH = 4,
	parameter CTRL_SIZE = 21
)(
	input logic clk, rstn,
	input logic [CTRL_SIZE-1:0] ctrl_signals,
	output logic [31:0] instruction,
	output logic ex_no_stay
);

	localparam N_WIDTH = 7;

	/* Datapath Wires */
	localparam REG_BITS = $clog2(REG_COUNT);
	logic [REG_BITS-1:0] read_reg1, read_reg2, write_reg;
	logic signed [REG_WIDTH-1:0] read_data1, read_data2, write_data, imm_data, imm_sel_data;
	logic signed [REG_WIDTH-1:0] bus_a, bus_b, alu_out;
	logic alu_zero, alu_neg, stall;
	logic [REG_WIDTH-1:0] mem_addr; 
	logic signed [REG_WIDTH-1:0] mem_write_data, mem_read_data;
	logic [31:0] pc, target_pc, return_pc, pc_with_offset;
	logic [REG_BITS-1:0] rs1, rs2, rd;
   logic [N_WIDTH-1:0] counter_N;
	logic counter_words, counter_done;
	logic [31:0] counter_out;
	
	/* control signals */
	logic write_en;
	logic [ALU_SEL_WIDTH-1:0] alu_sel;
	logic alu_a_sel, alu_b_sel;
	logic mem_read, mem_write;
	logic [1:0] load_store_type, ls_temp;
	logic load_unsigned;
	logic [1:0] write_src_sel; 	// from where is written to register
	logic [2:0] branch_type;
	logic stay, stay_temp;		// Do not go to next instruction
	logic memcpy_store;	// Load or store instruction within memcopy
	logic counter_en, counter_sel;
	
	/* Control signal assignments */
	assign {write_en, alu_sel, alu_b_sel, alu_a_sel, mem_write, mem_read, ls_temp, load_unsigned, write_src_sel, branch_type, stay_temp, memcpy_store, counter_en, counter_sel} = ctrl_signals;
	assign stay = stay_temp & (~ex_no_stay);
	always_comb begin
		if (!counter_sel) load_store_type = ls_temp;
		else if (counter_words) load_store_type = `LS_WORD;
		else load_store_type = `LS_BYTE;
	end
	
	
	/* Assignments in datapath */
	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign rd = instruction[11:7];
	
	assign read_reg1 = memcpy_store? rs2 : rs1;
	assign read_reg2 = memcpy_store? rd  : rs2;
	assign write_reg = rd;
	
	assign bus_a = alu_a_sel? pc : read_data1;		// use PC if 1
	assign bus_b = alu_b_sel? imm_sel_data : read_data2;	// immediate if 1
	
	assign mem_addr = alu_out;		// Calculated mem address
	assign mem_write_data = read_data2;		// rs2 contents (cannot use bus B because it might have immediate)
	
	assign target_pc = alu_out;
	assign pc_with_offset = pc + imm_data;
	
	assign counter_N = imm_data[N_WIDTH-1:0];
	assign imm_sel_data = counter_sel? counter_out : imm_data;
	assign ex_no_stay = counter_done & counter_en;	// Only check this on a memcopy instruction
	
	
	regfile #(.WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT)) regfile_obj(.*);
				
	alu #(.WIDTH(REG_WIDTH),
			.ALU_SEL(ALU_SEL_WIDTH)) alu_obj (.*);
			
	immgen immgen_obj (
			.inst(instruction),
			.imm_out(imm_data)
	);
	
	data_memory #(.ADDR_WIDTH(REG_WIDTH),
					  .DATA_WIDTH(REG_WIDTH),
					  .NUM_LOCS(NUM_MEM_LOCS)) datamem_obj (.*);
	
	pccalc pclogic_obj (.*);
	
	mux3 #(.WIDTH(REG_WIDTH)) reg_src_mux (
			.a0(alu_out),
			.a1(mem_read_data),
			.a2(return_pc),
			.sel(write_src_sel),
			.out(write_data)
	);
	
	inst_memory #(.NUM_INST(NUM_INST)) instmem_obj (.*);
	
	counter #(.WIDTH(N_WIDTH)) count_obj (.*);

endmodule