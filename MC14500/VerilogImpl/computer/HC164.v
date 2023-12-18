module hc164 (
	input A,
	input B,
	output reg [7:0] Q,
	input CLK,
	input CLRb
);

`ifdef BENCH
wire [7:0] Q_corr = {Q[0], Q[1], Q[2], Q[3], Q[4], Q[5], Q[6], Q[7]};
`endif

always @(posedge CLK or negedge CLRb) begin
	if(!CLRb) begin
		Q <= 8'h00;
	end else begin
		Q <= {Q[6:0], A & B};
	end
end

endmodule
