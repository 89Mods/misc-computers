module hc74(
	input rstb1,
	input rstb2,
	input stb1,
	input stb2,
	input data1,
	input data2,
	input clk1,
	input clk2,
	output reg q1,
	output reg q2,
	output reg qb1,
	output reg qb2
);

always @(posedge clk1 or negedge rstb1 or negedge stb1 or posedge rstb1 or posedge stb1) begin
	if(!rstb1 && !stb1) begin
		q1 <= 1'b1;
		qb1 <= 1'b1;
	end else if(!rstb1) begin
		q1 <= 1'b0;
		qb1 <= 1'b1;
	end else if(!stb1) begin
		q1 <= 1'b1;
		qb1 <= 1'b0;
	end else begin
		q1 <= data1;
		qb1 <= ~data1;
	end
end

always @(posedge clk2 or negedge rstb2 or negedge stb2 or posedge rstb2 or posedge stb2) begin
	if(!rstb2 && !stb2) begin
		q2 <= 1'b1;
		qb2 <= 1'b1;
	end else if(!rstb2) begin
		q2 <= 1'b0;
		qb2 <= 1'b1;
	end else if(!stb2) begin
		q2 <= 1'b1;
		qb2 <= 1'b0;
	end else begin
		q2 <= data2;
		qb2 <= ~data2;
	end
end

endmodule
