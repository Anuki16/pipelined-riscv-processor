
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
	
	logic [REG_WIDTH-1:0] wb_data_ex_mem, wb_data_mem_wb;
	
	/* Pipeline registers */
	localparam FETCH_DEC_SIZE = 64;
	localparam DEC_EXC_SIZE = REG_BITS*3 + CTRL_SIZE + REG_WIDTH*3 + 32;
	localparam EXC_MEM_SIZE = REG_BITS + 1 + CTRL_SIZE-7 + REG_WIDTH*3;
	localparam MEM_WB_SIZE = 1 + REG_BITS + REG_WIDTH*3 + 2;
	
	logic [0:FETCH_DEC_SIZE - 1] fetch_dec_reg;
	logic [0:DEC_EXC_SIZE - 1] dec_exc_reg;
	logic [0:EXC_MEM_SIZE - 1] exc_mem_reg;
	logic [0:MEM_WB_SIZE - 1] mem_wb_reg;
	
	/* Variables for forwarding unit */
	logic [REG_BITS-1:0] rs1, rs2, rd_ex, rd_mem;
	logic regWrEn, regWrEn_mem;
	logic [1:0] forward_A, forward_B;

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
				
	// Connect to forwarding unit
	forwarding_unit #(.REG_BITS(REG_BITS)) fwd_unit (.*);
	
	assign {rs1, rs2} = dec_exc_reg[0:2*REG_BITS-1];
	assign rd_ex = exc_mem_reg[0:REG_BITS-1];
	assign rd_mem = mem_wb_reg[0:REG_BITS-1];
	assign regWrEn = exc_mem_reg[REG_BITS];
	assign regWrEn_mem = mem_wb_reg[REG_BITS];
	
	assign wb_data_ex_mem = exc_mem_reg[REG_BITS + 1 + CTRL_SIZE-7:REG_BITS + 1 + CTRL_SIZE-7+REG_WIDTH-1];
	assign wb_data_mem_wb = write_data;
	

endmodule