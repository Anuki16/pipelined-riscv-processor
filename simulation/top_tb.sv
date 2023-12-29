`include "../controls.sv"

`timescale 1ns/1ps

module top_tb();

	logic clk = 0, rstn = 0;
	always #5 clk <= ~clk;
	
	localparam REG_WIDTH = 32;
	localparam REG_COUNT = 32;
	localparam NUM_MEM_LOCS = 64;
	localparam NUM_INST = 128;
	localparam ALU_SEL_WIDTH = 4;
	localparam CTRL_SIZE = 21;
	
	logic [REG_WIDTH-1:0] x5, x6, mem1;
	
	riscv_pipelined_processor #(.REG_WIDTH(REG_WIDTH), 
				  .REG_COUNT(REG_COUNT),
				  .NUM_MEM_LOCS(NUM_MEM_LOCS),
				  .NUM_INST(NUM_INST),
				  .ALU_SEL_WIDTH(ALU_SEL_WIDTH),
				  .CTRL_SIZE(CTRL_SIZE)) dut (.*);
				  
	initial begin
		@(posedge clk) #1 rstn = 1;
	end
	
endmodule