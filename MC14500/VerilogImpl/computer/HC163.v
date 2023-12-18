module hc163 (
	input CLRb,
	output CLK,
	input [3:0] CIN,
	input ENP,
	input LOADb,
	input ENT,
	output reg [3:0] Q,
	output RCO
);

assign RCO = Q == 4'hF & ENT;

always @(posedge CLK) begin
	if(!CLRb) begin
		Q <= 4'h0;
	end else if(!LOADb) begin
		Q <= CIN;
	end else if(ENT && ENP) begin
		Q <= Q + 1;
	end
end

endmodule
