module hc244 (
	input [3:0] A1,
	input [3:0] A2,
	input OEb1,
	input OEb2,
	output [3:0] Y1,
	output [3:0] Y2
);

assign Y1 = OEb1 ? 4'bzzzz : A1;
assign Y2 = OEb2 ? 4'bzzzz : A2;

endmodule
