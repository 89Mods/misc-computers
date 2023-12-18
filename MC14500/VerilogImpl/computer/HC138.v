module hc138 (
	input G1,
	input G2A,
	input G2B,
	input [2:0] A,
	output [7:0] Y
);

reg [7:0] sel;
always @(*) begin
	case(A)
		0: sel = 8'b11111110;
		1: sel = 8'b11111101;
		2: sel = 8'b11111011;
		3: sel = 8'b11110111;
		4: sel = 8'b11101111;
		5: sel = 8'b11011111;
		6: sel = 8'b10111111;
		7: sel = 8'b01111111;
	endcase
end

assign Y = G1 && ~G2A && ~G2B ? sel : 8'b11111111;

endmodule
