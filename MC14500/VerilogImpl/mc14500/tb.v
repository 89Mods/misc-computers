`default_nettype none
`timescale 1ns/1ps

module tb (
	input CLK,
	input DATA_in,
	input RST,
	input [3:0] I,
	
	output X1,
	output DATA_out,
	output WRITE,
	output RR,
	output JMP,
	output RTN,
	output FLAG_O,
	output FLAG_F
);

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
		#1;
	end
	
	wire DATA;
	assign DATA_out = DATA;
	assign DATA = !WRITE ? DATA_in : 1'bz;
	mc14500 mc14500 (
		.X2(CLK),
		.DATA(DATA),
		.RST(RST),
		.I(I),
		.X1(X1),
		.WRITE(WRITE),
		.RR(RR),
		.JMP(JMP),
		.RTN(RTN),
		.FLAG_O(FLAG_O),
		.FLAG_F(FLAG_F)
	);
endmodule
