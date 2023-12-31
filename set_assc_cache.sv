`include "controls.sv"

module set_assc_cache #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter CACHE_LINE_SIZE = 16,	// bytes
	parameter NUM_MEM_BYTES = 1024,
	parameter NUM_CACHE_LINES = 8,
	parameter CACHE_SET_SIZE = 2,
	parameter MEM_ADDR_WIDTH = $clog2((NUM_MEM_BYTES / CACHE_LINE_SIZE))	// line address
)(	
	input logic clk, rstn,
	
	// Inputs/outputs/controls on CPU side
	input logic [ADDR_WIDTH-1:0] addr_from_cpu,
	input logic signed [DATA_WIDTH-1:0] data_from_cpu,
	input logic mem_read_cpu, mem_write_cpu,	// control signals
	input logic [1:0] load_store_type, 
	input logic load_unsigned,
	output logic signed [DATA_WIDTH-1:0] data_to_cpu,
	output logic stall,
	
	// Inputs/outputs/controls on memory side
	input logic [CACHE_LINE_SIZE*8-1:0] data_from_memory,
	output logic [MEM_ADDR_WIDTH-1:0] addr_to_memory,
	output logic [CACHE_LINE_SIZE*8-1:0] data_to_memory,
	output logic mem_write
);
	localparam NUM_CACHE_SETS = NUM_CACHE_LINES / CACHE_SET_SIZE;
	localparam NUM_MEM_LINES = NUM_MEM_BYTES / CACHE_LINE_SIZE;
	
	localparam BLOCK_NUM_WIDTH = $clog2(CACHE_LINE_SIZE);	// How many bits for byte within block
	localparam SET_NUM_WIDTH = $clog2(NUM_CACHE_SETS);		// How many bits for set number
	localparam TAG_BITS_WIDTH = $clog2(NUM_MEM_BYTES) - BLOCK_NUM_WIDTH - SET_NUM_WIDTH;
	
	localparam ADR_TAG_BEGIN = BLOCK_NUM_WIDTH + SET_NUM_WIDTH + TAG_BITS_WIDTH - 1;   
	localparam ADR_TAG_END = BLOCK_NUM_WIDTH + SET_NUM_WIDTH; 
	localparam ADR_SET_BEGIN = BLOCK_NUM_WIDTH + SET_NUM_WIDTH - 1;
	localparam ADR_SET_END = BLOCK_NUM_WIDTH;
	localparam ADR_BYTE_BEGIN = BLOCK_NUM_WIDTH-1;
	localparam ADR_BYTE_END = 0;
	
	// Memory address division:
	// 000..000 | TAG_BITS_WIDTH | SET_NUM_WIDTH | BLOCK_NUM_WIDTH
	
	// Cache, organized as lines and sets
	logic [CACHE_LINE_SIZE*8-1:0] cache [0:NUM_CACHE_SETS-1][0:CACHE_SET_SIZE-1];
	logic [TAG_BITS_WIDTH-1:0] tag_store [0:NUM_CACHE_SETS-1][0:CACHE_SET_SIZE-1];
	logic valid_bit_store [0:NUM_CACHE_SETS-1][0:CACHE_SET_SIZE-1];
	logic dirty_bit_store [0:NUM_CACHE_SETS-1][0:CACHE_SET_SIZE-1];
	logic lru_store [0:NUM_CACHE_SETS-1];
	
	logic [TAG_BITS_WIDTH-1:0] tag;
	logic [SET_NUM_WIDTH-1:0] set_idx;
	logic [BLOCK_NUM_WIDTH-1:0] byte_idx;
	logic [CACHE_LINE_SIZE*8-1:0] cur_cache_line;
	logic [MEM_ADDR_WIDTH-1:0] w_addr;
	
	logic is_cache_hit, hit_idx, select_idx;
	
	assign tag = addr_from_cpu[ADR_TAG_BEGIN:ADR_TAG_END];
	assign set_idx = addr_from_cpu[ADR_SET_BEGIN:ADR_SET_END];
	assign byte_idx = addr_from_cpu[ADR_BYTE_BEGIN:ADR_BYTE_END];
	
	assign addr_to_memory = mem_write? w_addr : {tag, set_idx};		// Select address for read or write
	assign select_idx = ~lru_store[set_idx];	// select the one not recently used
	assign stall = (mem_read_cpu || mem_write_cpu) && (~is_cache_hit);
	
	/* Cache read logic */
	always_comb begin
	
		if (valid_bit_store[set_idx][0] && tag_store[set_idx][0] == tag) begin
			cur_cache_line = cache[set_idx][0];
			is_cache_hit = 1;
			hit_idx = 0;
			
		end else if (valid_bit_store[set_idx][1] && tag_store[set_idx][1] == tag) begin
			cur_cache_line = cache[set_idx][1];
			is_cache_hit = 1;
			hit_idx = 1;
			
		end else begin
			cur_cache_line = 'b0;
			is_cache_hit = 0;
			hit_idx = 0;
		end
		
		if (mem_read_cpu) begin
			data_to_cpu[7:0] = cur_cache_line[byte_idx*8 +: 8];
		
			unique case (load_store_type) 
				`LS_BYTE: begin
					if (load_unsigned) data_to_cpu[DATA_WIDTH-1:8] = {(DATA_WIDTH-8){1'b0}};
					else data_to_cpu[DATA_WIDTH-1:8] = {(DATA_WIDTH-8){data_to_cpu[7]}};
				end
				`LS_HALF: begin
					data_to_cpu[15:8] = cur_cache_line[8*(byte_idx+1) +: 8];
					if (load_unsigned) data_to_cpu[DATA_WIDTH-1:16] = {(DATA_WIDTH-16){1'b0}};
					else data_to_cpu[DATA_WIDTH-1:16] = {(DATA_WIDTH-16){data_to_cpu[15]}};
				end
				`LS_WORD: begin
					data_to_cpu[15:8] = cur_cache_line[8*(byte_idx+1) +: 8];
					data_to_cpu[23:16] = cur_cache_line[8*(byte_idx+2) +: 8];
					data_to_cpu[31:24] = cur_cache_line[8*(byte_idx+3) +: 8];
				end
				default: data_to_cpu = 'b0;
			endcase
				
		end else data_to_cpu = 'b0;
		
	end
	
	always @(posedge clk or negedge rstn) begin
	
		if (~rstn) begin
			for (int i = 0; i < NUM_CACHE_SETS; i = i+1) begin
				for (int j = 0; j < CACHE_SET_SIZE; j = j+1) begin
					cache[i][j] <= 'b0;
					tag_store[i][j] <= 'b0;
					valid_bit_store[i][j] <= 'b0;
					dirty_bit_store[i][j] <= 'b0;
				end
			end
			mem_write <= 0;
			data_to_memory <= 'b0;
			w_addr <= 'b0;
			
		end else if (stall) begin	// Fetch data from memory, store in select_idx
		
				// Write back if there is a valid and dirty bit before replacing
				if (valid_bit_store[set_idx][select_idx] && dirty_bit_store[set_idx][select_idx]) begin
					data_to_memory <= cache[set_idx][select_idx];
					w_addr <= {tag_store[set_idx][select_idx], set_idx};
					dirty_bit_store[set_idx][select_idx] <= 1'b0;
					mem_write <= 1;
				end
				
				cache[set_idx][select_idx] <= data_from_memory;
				tag_store[set_idx][select_idx] <= tag;
				valid_bit_store[set_idx][select_idx] <= 1'b1;
				
		end else if (mem_write_cpu && is_cache_hit) begin	
		
			// Data is in cache (at hit_idx) and need to write
			for (int b = 0; b <= load_store_type; b = b+1) begin
				cache[set_idx][hit_idx][8*(byte_idx+b) +: 8] <= data_from_cpu[8*b+:8];
				dirty_bit_store[set_idx][hit_idx] <= 1'b1;
			end
			mem_write <= 0;
			w_addr <= {tag, set_idx};
			
		end else begin 
			mem_write <= 0;
			w_addr <= {tag, set_idx};
		end
	end
	
	// Update LRU with last hit
	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			for (int i = 0; i < NUM_CACHE_SETS; i = i+1) begin
				lru_store[i] <= 1'b0;
			end
			
		end else if ((mem_read_cpu || mem_write_cpu) && (is_cache_hit)) begin
			lru_store[set_idx] <= hit_idx;
		
		end 
			
	end
	

endmodule