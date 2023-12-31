`include "../controls.sv"

`timescale 1ns/1ps

module data_memory_tb();
	
	localparam ADDR_WIDTH = 32;
	localparam DATA_WIDTH = 32;
	localparam NUM_MEM_BYTES = 256;
	
	logic [ADDR_WIDTH-1:0] mem_addr;
	logic signed [DATA_WIDTH-1:0] mem_write_data;
	logic clk = 0, rstn = 0;
	logic mem_read = 0, mem_write = 0;	// control signals
	logic [1:0] load_store_type; 
	logic load_unsigned;
	logic signed [DATA_WIDTH-1:0] mem_read_data;
	logic [31:0] mem1;
	logic stall;
	
	always #5 clk <= ~clk;
	
	data_memory_controller #(.ADDR_WIDTH(ADDR_WIDTH),
					  .DATA_WIDTH(DATA_WIDTH),
					  .NUM_MEM_BYTES(NUM_MEM_BYTES)) dut (.*);
	
	initial begin
		@(posedge clk) #1 rstn = 0;
		#10 rstn = 1;
		#1 mem_write = 1;
		mem_write_data = 32'b11110000111100001111000011110000;
		mem_addr = (5 << 2)|2;	// 5th loc 2nd byte
		load_store_type = `LS_BYTE;
		load_unsigned = 0;
		
		#20 mem_addr = 150;	
		load_store_type = `LS_HALF;
		
		#20 mem_addr = 80;	
		load_store_type = `LS_WORD;
		
		#20 mem_write = 0;
		mem_read = 1;
		mem_addr = (5 << 2)|2;
		load_store_type = `LS_BYTE;
		load_unsigned = 0;		
		#20 assert (mem_read_data == $signed(mem_write_data[7:0])) 
			else $error("%d %d", mem_read_data, mem_write_data[7:0]);
			
		#20 load_unsigned = 1;		
		#1 assert (mem_read_data == $unsigned(mem_write_data[7:0])) 
			else $error("%d %d", mem_read_data, mem_write_data[7:0]);
			
		#20 mem_addr = 150;
		load_store_type = `LS_HALF;
		load_unsigned = 0;		
		#20 assert (mem_read_data == $signed(mem_write_data[15:0])) 
			else $error("%d %d", mem_read_data, mem_write_data[15:0]);
			
		#10 load_unsigned = 1;		
		#1 assert (mem_read_data == $unsigned(mem_write_data[15:0])) 
			else $error("%d %d", mem_read_data, mem_write_data[15:0]);
			
		#20 mem_addr = 80;
		load_store_type = `LS_WORD;
		load_unsigned = 0;		
		#20 assert (mem_read_data == mem_write_data) 
			else $error("%d %d", mem_read_data, mem_write_data);
			
		#20 mem_addr = (5 << 2);
		load_store_type = `LS_WORD;
		load_unsigned = 0;		
		#20 assert (mem_read_data == {8'b0, mem_write_data[7:0], 16'b0}) 
			else $error("%d", mem_read_data);
		
	end
	
endmodule
		
		
		