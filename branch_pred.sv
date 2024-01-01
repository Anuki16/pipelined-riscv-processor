module branch_pred (
    input logic clk, rstn,branch_taken,is_branch_prev,
    input logic [31:0] epc,fpc,
    output logic pred
);  

logic [2:0] LHT [7:0];
logic [1:0] LPT [7:0];
logic [2:0] pLHT_val,nLHT_val;
logic [2:0] pLHT_index,nLHT_index;
logic [1:0] pLPT_val,nLPT_val;
logic [2:0] pindex,nindex;

// Get the index of the LHT
assign pindex = epc[4:2];
assign pLHT_val = LHT[pindex];
assign pLHT_index=pLHT_val;
assign pLPT_val = LPT[pLHT_index];

assign nindex=fpc[4:2];
assign nLHT_val = LHT[nindex];
assign nLPT_val = LPT[nLHT_index];
assign nLHT_index=nLHT_val;

assign pred = ((nLPT_val == 2'b00) |(nLPT_val ==2'b01 )) ? 1'b0 : 1'b1;

// Always block to update the LHT and LPT
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        // Loop through each entry and set them to zeros
        for (int i = 0; i < 8; i++) begin
            LHT[i] <= 3'b000;
            LPT[i] <= 2'b11;		// initially predict taken
        end
    end else if (is_branch_prev) begin
			  // Update the LPT of previous branch
			  if(pLPT_val == 2'b00) begin
					LPT[pLHT_index] <= branch_taken ? 2'b01 : 2'b00;
			  end else if (pLPT_val == 2'b01) begin
					LPT[pLHT_index] <= branch_taken ? 2'b11 : 2'b00;
			  end else if (pLPT_val == 2'b10) begin
					LPT[pLHT_index] <= branch_taken ? 2'b11 : 2'b00;
			  end else begin
					LPT[pLHT_index] <= branch_taken ? 2'b11 : 2'b10;
			  end

			  // Update the LHT of previous branch
			  LHT[pindex] <= {branch_taken,pLHT_val[2:1]};
    end

end



endmodule