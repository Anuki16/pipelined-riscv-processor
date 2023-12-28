`include "../controls.sv"

`timescale 1ns/1ps

module pccalc_tb();

	logic clk = 0, rstn = 0;
	logic [31:0] pc_with_offset;		
	logic [31:0] target_pc, pc;
	logic [2:0] branch_type;
	logic alu_zero = 0, alu_neg = 0;
	logic stay = 0;
	logic [31:0] return_pc;
	
	always #5 clk <= ~clk;
	
	pccalc dut (.*);
	
	initial begin 
		@(posedge clk) #1 rstn = 0;
		#10 rstn = 1;
		branch_type = 0;
		pc_with_offset = 32'b1100;
		
		#10 branch_type = `JMP_JAL;
		#10 branch_type = `JMP_BEQ;
		alu_zero = 1;
		#10 branch_type = `JMP_BNE;
		#10 alu_zero = 0;
		alu_neg = 1;
		#10 branch_type = `JMP_BLT;
		#10 branch_type = `JMP_BGT;
		#10 target_pc = 32'b10101100;
		branch_type = `JMP_JALR;
		#10 alu_neg = 0;
	end 
	
endmodule