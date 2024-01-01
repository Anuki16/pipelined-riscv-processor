
module branch_target (
    input logic clk, rstn, branch_taken,
    input logic [31:0] epc,fpc,
    output logic [31:0] next_pc,
    output logic pred
);

    // Parameters for the BTB
    parameter int BTB_SIZE = 32; // Adjust the size as needed
    parameter int INDEX_BITS = $clog2(BTB_SIZE);

    logic [INDEX_BITS-1:0] index;
    logic [31:0] BTB [0:BTB_SIZE-1];
	 logic BTB_valid [0:BTB_SIZE-1];
    logic [31:0] branch_target;
    logic is_branch_inst, is_branch_prev;

    branch_pred bpu(
        .clk(clk),
        .rstn(rstn),
        .branch_taken(branch_taken),
		  .is_branch_prev(is_branch_prev),
        .epc(epc),
        .fpc(fpc),
        .pred(pred)
    );

	 assign index = fpc[INDEX_BITS+1:2];
    assign branch_target = BTB[index];
	 assign is_branch_inst = BTB_valid[index];
	 assign is_branch_prev = BTB_valid[epc[INDEX_BITS+1:2]];

    assign next_pc = (pred & is_branch_inst) ? branch_target : fpc+4;
	 
	 assign BTB[10] = (10 + 4) << 2;	// instruction 10 is a branch instruction, target address is 16
	 assign BTB_valid[10] = 1'b1;
	 
	 always_comb begin
		for (int i = 0; i < BTB_SIZE; i++) begin
			if (i != 10) begin
				BTB[i] = 32'b0;
				BTB_valid[i] = 1'b0;
			end
		end
	end

endmodule
