module forwarding_unit #(
	parameter REG_BITS = 5
)(	
	input logic [REG_BITS-1:0] rs1,		// in ID/EX, register rs1
	input logic [REG_BITS-1:0] rs2,		// in ID/EX, register rs2
	input logic [REG_BITS-1:0] rd_ex,	// in EX/MEM, register rd
	input logic [REG_BITS-1:0] rd_mem,	// in MEM/WB, register rd
	
	//control signals from buffers
	input logic regWrEn,			//in EX/MEM, reg write enable
	input logic regWrEn_mem,	//in MEM/WB, reg write enable
 
	output logic [1:0] forward_A, //alu input A
	output logic [1:0] forward_B  //alu input B
 );
  
 //MUX: 00- directly from ID/EX, 01 - from EX/MEM, 10 - from MEM/WB

 
  always_comb
    begin
	 
		//Forward A
		if ((rd_ex== rs1) && (regWrEn != 0) && (rd_ex != 0))
			 begin
				forward_A = 2'b01;
			 end
			else
			 begin 
				if ((rd_mem == rs1) && (regWrEn_mem != 0) && (rd_mem != 0))
				  begin
					 forward_A = 2'b10;
				  end
				else
				  begin
					 forward_A = 2'b00;
				  end
			 end
		 
		//Forward B
		if ((rd_ex== rs2) && (regWrEn != 0) && (rd_ex != 0))
		 begin
			forward_B = 2'b01;
		 end
		else
		 begin 
			if ((rd_mem == rs2) && (regWrEn_mem != 0) && (rd_mem != 0))
			  begin
				 forward_B = 2'b10;
			  end
			else
			  begin
				 forward_B = 2'b00;
			  end
		 end
	end
		 
endmodule
