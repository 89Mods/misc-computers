module hc259 (
	input D,
	input [2:0] A,
	input Eb,
	input CLRb,
	output [7:0] Q
);

reg data [7:0];

assign Q = {data[7], data[6], data[5], data[4], data[3], data[2], data[1], data[0]};

always @(negedge CLRb or negedge Eb) begin
	if(!CLRb) begin
		data[0] <= 1'b0;
		data[1] <= 1'b0;
		data[2] <= 1'b0;
		data[3] <= 1'b0;
		data[4] <= 1'b0;
		data[5] <= 1'b0;
		data[6] <= 1'b0;
		data[7] <= 1'b0;
	end else begin
		data[A] <= D;
	end
end

endmodule
