`timescale 1ns/1ps

module regfile_tb();
	
	logic [4:0] read_reg1, read_reg2, write_reg;
	logic signed [31:0] write_data;
	logic write_en;
	logic clk = 0;
	logic rstn = 1;
	logic signed [31:0] read_data1, read_data2;
	logic [31:0] x5, x6, x11;
	
	regfile dut(.*);
	
	always #5 clk <= ~clk;
	
	initial begin
		@(posedge clk) #1 rstn = 0;
		#10 rstn = 1;
		
		write_data = 12983;
		write_reg = 10;
		write_en = 1;
		#10 write_en = 0;
		#10 write_data = 324;
		write_reg = 30;
		write_en = 1;
		#10 write_en = 0;
		write_data = 500;
		
		@(posedge clk) #1 read_reg1 = 10;
		read_reg2 = 30;
		@(posedge clk) assert (read_data1 == 12983 && read_data2 == 324) else $error("%d %d", read_data1, read_data2);
		#10 write_data = 500;
		write_reg = 0;
		write_en = 1;
		
		@(posedge clk) #1 read_reg1 = 10;
		read_reg2 = 0;
		@(posedge clk) assert (read_data1 == 12983 && read_data2 == 0) else $error("%d %d", read_data1, read_data2);
		
		$finish();
	end
	
	
endmodule