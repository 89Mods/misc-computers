module hc00 (
	input A0,
	input B0,
	output Y0,
	input A1,
	input B1,
	output Y1,
	input A2,
	input B2,
	output Y2,
	input A3,
	input B3,
	output Y3
);

assign Y0 = ~(A0 & B0);
assign Y1 = ~(A1 & B1);
assign Y2 = ~(A2 & B2);
assign Y3 = ~(A3 & B3);

endmodule
