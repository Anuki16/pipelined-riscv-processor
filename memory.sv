
module memory #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter NUM_MEM_LOCS = 64,
	parameter CTRL_SIZE = 21,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic clk, rstn,
	input logic [REG_BITS + 1 + CTRL_SIZE-7 + REG_WIDTH*3 - 1:0] exc_mem_reg,
	output logic [1 + REG_BITS + REG_WIDTH*3 + 2 - 1:0] mem_wb_reg,
	output logic stall
);
	logic [REG_WIDTH-1:0] mem_addr; 
	logic signed [REG_WIDTH-1:0] mem_write_data, mem_read_data;
	
	logic mem_read, mem_write;
	logic [1:0] load_store_type;
	logic load_unsigned;
	
	logic [REG_BITS-1:0] rd;
	logic write_en;
	logic [CTRL_SIZE-8:0] ctrl_signals;
	logic [REG_WIDTH-1:0] alu_out, read_data2, return_pc;
	logic [1:0] write_src_sel;
	
	data_memory_controller #(.ADDR_WIDTH(REG_WIDTH),
					  .DATA_WIDTH(REG_WIDTH),
					  .NUM_MEM_BYTES(NUM_MEM_LOCS)) datamem_obj (.*);
					  
	assign {rd, write_en, ctrl_signals, alu_out, read_data2, return_pc} = exc_mem_reg;
	
	assign mem_addr = alu_out;		// Calculated mem address
	assign mem_write_data = read_data2;	
	
	assign {mem_write, mem_read, load_store_type, load_unsigned, write_src_sel} = ctrl_signals[CTRL_SIZE-8:CTRL_SIZE-14];
	
	always @(posedge clk or negedge rstn) begin
		if (~rstn) mem_wb_reg <= 'b0;
		else if (~stall) mem_wb_reg <= {rd, write_en, alu_out, mem_read_data, return_pc, write_src_sel};
	end

endmodule