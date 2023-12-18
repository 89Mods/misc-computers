module hc175(
	input [3:0] D,
	output [3:0] Q,
	output [3:0] Qb,
	input clk,
	input MR
);

reg [3:0] state;
assign Q = state;
assign Qb = ~state;

always @(posedge clk or negedge MR) begin
	if(!MR) begin
		state <= 4'h0;
	end else begin
		state <= D;
	end
end

endmodule
