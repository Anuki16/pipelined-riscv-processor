
module processor_fpga #(
	parameter REG_WIDTH = 32,
	parameter REG_COUNT = 32,
	parameter NUM_MEM_LOCS = 64,
	parameter NUM_INST = 128,
	parameter ALU_SEL_WIDTH = 4,
	parameter CTRL_SIZE = 21
)( 
	input logic clk, rstn,
	output logic [6:0] out1, out2, out3, out4, out5, out6, out7	// 7 segment outputs
);	
	logic [REG_WIDTH-1:0] x5, x6, mem1;
	
	// x5, x6: registers
	// mem1 : memory address 64
	
	riscv_single_cycle_processor #(.REG_WIDTH(REG_WIDTH), 
				  .REG_COUNT(REG_COUNT),
				  .NUM_MEM_LOCS(NUM_MEM_LOCS),
				  .NUM_INST(NUM_INST),
				  .ALU_SEL_WIDTH(ALU_SEL_WIDTH),
				  .CTRL_SIZE(CTRL_SIZE)) proc (.*);
				  
	/* 7 segment outputs */
	logic [3:0] one1, one2, ten1, ten2; // single digits

   assign one1 = x5[3:0];
   assign ten1 = x5[7:4];
   assign one2 = x6[3:0];
   assign ten2 = x6[7:4];
	
	binary_to_7seg ss1 (.data_in(one1), .data_out(out2));
	binary_to_7seg ss2 (.data_in(ten1), .data_out(out1));
	binary_to_7seg ss3 (.data_in(one2), .data_out(out4));
	binary_to_7seg ss4 (.data_in(ten2), .data_out(out3));
	
	binary_to_7seg ss5 (.data_in(mem1[11:8]), .data_out(out5));
	binary_to_7seg ss6 (.data_in(mem1[7:4]), .data_out(out6));
	binary_to_7seg ss7 (.data_in(mem1[3:0]), .data_out(out7));
	
endmodule
