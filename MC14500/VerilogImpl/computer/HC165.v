module hc165 (
	input DS,
	input [7:0] D,
	input PLb,
	input CP,
	input CEb,
	output Q7,
	output Q7b
);

reg [7:0] state;
wire clock = CP | CEb;

`ifdef BENCH
wire [7:0] state_corr = {state[0], state[1], state[2], state[3], state[4], state[5], state[6], state[7]};
`endif

assign Q7 = state[7];
assign Q7b = ~state[7];

always @(posedge clock or negedge PLb) begin
	if(PLb) begin
		state <= {state[6:0], DS};
	end else begin
		state <= D;
	end
end

endmodule
