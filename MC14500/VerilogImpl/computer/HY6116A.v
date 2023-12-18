module hy6116a (
	input CSb,
	input WEb,
	input OEb,
	input [10:0] A,
	inout [7:0] IO
);

reg [7:0] memory [2047:0];

`ifdef BENCH
wire [7:0] TEST_ADDR = 8'hFE;
wire [10:0] TEST_ADDR_EXP = {3'b000, TEST_ADDR[0], TEST_ADDR[1], TEST_ADDR[2], TEST_ADDR[3], TEST_ADDR[4], TEST_ADDR[5], TEST_ADDR[6], TEST_ADDR[7]};
wire [7:0] TEST_MEM_VAL = memory[TEST_ADDR_EXP];
wire [7:0] TEST = {TEST_MEM_VAL[0], TEST_MEM_VAL[1], TEST_MEM_VAL[2], TEST_MEM_VAL[3], TEST_MEM_VAL[4], TEST_MEM_VAL[5], TEST_MEM_VAL[6], TEST_MEM_VAL[7]};
`endif

assign IO = !CSb && WEb && !OEb ? memory[A] : 8'hzz;

always @(posedge WEb) begin
	if(!CSb) begin
		memory[A] <= IO;
	end
end

always @(posedge CSb) begin
	if(!WEb) begin
		memory[A] <= IO;
	end
end

endmodule
