
module regfile #(
	parameter WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter REG_BITS = $clog2(REG_COUNT)
)(
	input logic [REG_BITS-1:0] read_reg1, read_reg2, write_reg,
	input logic signed [WIDTH-1:0] write_data,
	input logic write_en,
	input logic clk, rstn,
	output logic signed [WIDTH-1:0] read_data1, read_data2
);
	logic [WIDTH-1:0] registers [REG_COUNT-1:0];		// unpacked array of 32 bit packed values
	
	assign read_data1 = registers[read_reg1];
	assign read_data2 = registers[read_reg2];
	
	always @(negedge clk or negedge rstn) begin
		if (~rstn) begin		// reset all registers to 0 
			for (int i = 0; i < REG_COUNT; i++) registers[i] <= 'b0;
		end
		
		else if (write_en && write_reg) // Don't write if the write reg address is 0, this will keep it hardwired to 0
			registers[write_reg] <= write_data;
	end

endmodule