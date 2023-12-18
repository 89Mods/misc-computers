module hc4051 (
	input Eb,
	input [2:0] S,
	output A_out,
	input [7:0] A_in
);

assign A_out = Eb ? 1'bz : A_in[S];

endmodule
