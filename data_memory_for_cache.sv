module data_memory_for_cache #(

	parameter LINE_SIZE = 16,
	parameter BYTE_COUNT = 1024,
	parameter LINE_COUNT = BYTE_COUNT/LINE_SIZE,
	parameter ADDR_SIZE = $clog2(LINE_COUNT)

)(
	
	input logic clk, rstn,
	input logic wr_en, //write enable
	input logic [LINE_SIZE*8 -1:0] wr_data, 
	input logic [ADDR_SIZE -1:0] input_addr,
	output logic [LINE_SIZE*8 -1:0] rd_data //data read from memory address
	
);


	//memory 
	logic [LINE_SIZE*8 -1:0] memory[0:LINE_COUNT-1]; 
	
	assign rd_data = memory[input_addr];

	
	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			for (int i = 0; i < LINE_COUNT; i = i+1) memory[i] <= 'b0;
		end 
		
		else if (wr_en) begin
			memory[input_addr] <= wr_data;
		end
	end

endmodule
