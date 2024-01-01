
module clock_divide_half (
    input logic clk50, rstn,
    output logic clk
);

    // Toggle flip-flop for dividing the clock by 2
    always_ff @(posedge clk50 or negedge rstn) begin
		  if (~rstn) clk <= 1'b0;
        else clk <= ~clk;
    end

endmodule