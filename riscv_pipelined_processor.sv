
module riscv_pipelined_processor #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter NUM_MEM_LOCS = 64,
	parameter NUM_INST = 128,
	parameter ALU_SEL_WIDTH = 4,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)( 
	input logic clk, rstn
);
	/* Intermediate variables */
	logic alu_zero;
	logic [2:0] branch_type;
	logic [31:0] target_pc, pc_with_offset;
	
	logic write_en;
	logic [REG_BITS-1:0] write_reg;
	logic signed [REG_WIDTH-1:0] write_data;
	
	/* Pipeline registers */
	logic [63:0] fetch_dec_reg;
	logic [REG_BITS + CTRL_SIZE + REG_WIDTH*3 + 32 - 1:0] dec_exc_reg;
	logic [REG_BITS + 1 + CTRL_SIZE-7 + REG_WIDTH*3 - 1:0] exc_mem_reg;
	logic [1 + REG_BITS + REG_WIDTH*3 + 2 - 1:0] mem_wb_reg;

	/* Pipeline stages */
	
	fetch #(.NUM_INST(NUM_INST)) fetch_stage (.*);
	
	decode #(.REG_WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT),
				.CTRL_SIZE(CTRL_SIZE)) decode_stage (.*);
				
	execute #(.REG_WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT),
				.CTRL_SIZE(CTRL_SIZE),
				.ALU_SEL_WIDTH(ALU_SEL_WIDTH)) execute_stage (.*);
	
	memory #(.REG_WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT),
				.CTRL_SIZE(CTRL_SIZE),
				.NUM_MEM_LOCS(NUM_MEM_LOCS)) memory_stage (.*);
				
	writeback #(.REG_WIDTH(REG_WIDTH),
				.REG_COUNT(REG_COUNT),
				.CTRL_SIZE(CTRL_SIZE)) writeback_stage (.*);

endmodule