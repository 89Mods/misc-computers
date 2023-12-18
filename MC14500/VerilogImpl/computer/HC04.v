module hc04 (
	input A0,
	output Y0,
	input A1,
	output Y1,
	input A2,
	output Y2,
	input A3,
	output Y3,
	input A4,
	output Y4,
	input A5,
	output Y5
);

assign Y0 = ~A0;
assign Y1 = ~A1;
assign Y2 = ~A2;
assign Y3 = ~A3;
assign Y4 = ~A4;
assign Y5 = ~A5;

endmodule
