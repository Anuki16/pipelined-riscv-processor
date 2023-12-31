
module data_memory_controller #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter NUM_MEM_BYTES = 256,	// Number of 32 bit words
	parameter CACHE_LINE_SIZE = 16,
	parameter MEM_ADDR_WIDTH = $clog2((NUM_MEM_BYTES / CACHE_LINE_SIZE))
)(
	input logic [ADDR_WIDTH-1:0] mem_addr,
	input logic signed [DATA_WIDTH-1:0] mem_write_data,
	input logic clk, rstn,
	input logic mem_read, mem_write,	// control signals
	input logic [1:0] load_store_type, 
	input logic load_unsigned,
	output logic signed [DATA_WIDTH-1:0] mem_read_data,
	output logic stall
);

	// Connections between cache and memory
	logic wr_en; //write enable
	logic [CACHE_LINE_SIZE*8 -1:0] wr_data;
	logic [MEM_ADDR_WIDTH -1:0] input_addr;
	logic [CACHE_LINE_SIZE*8 -1:0] rd_data; //data read from memory address
	
	set_assc_cache #(.ADDR_WIDTH(ADDR_WIDTH),
						  .DATA_WIDTH(DATA_WIDTH),
						  .NUM_MEM_BYTES(NUM_MEM_BYTES),
						  .CACHE_LINE_SIZE(CACHE_LINE_SIZE)) cache_memory_obj (
						  
						  .clk(clk), .rstn(rstn),
						  
						  .addr_from_cpu(mem_addr),
						  .data_from_cpu(mem_write_data),
						  .mem_read_cpu(mem_read),
						  .mem_write_cpu(mem_write),
						  .load_store_type(load_store_type),
						  .load_unsigned(load_unsigned),
						  .data_to_cpu(mem_read_data),
						  .stall(stall),
						  
						  .data_from_memory(rd_data),
						  .data_to_memory(wr_data),
						  .addr_to_memory(input_addr),
						  .mem_write(wr_en));
						  
	data_memory_for_cache #(.BYTE_COUNT(NUM_MEM_BYTES),
						  .LINE_SIZE(CACHE_LINE_SIZE)) data_memory_obj (.*);

	

endmodule