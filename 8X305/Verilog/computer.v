`default_nettype wire
`define BENCH
`timescale 1ns/10ps

module tb(
	input clk,
	input rst,
	output reg [7:0] failed
);

reg [7:0] RAM [255:0];
reg [7:0] ROM [16383:0];
reg [7:0] ROM_latch;
wire [7:0] TEST = ~RAM[23];
wire [7:0] ROM_val = ROM[ROM_addr];
wire [15:0] ROM_reversed = {ROM_val[0], ROM_val[1], ROM_val[2], ROM_val[3], ROM_val[4], ROM_val[5], ROM_val[6], ROM_val[7]
						, ROM_latch[0], ROM_latch[1], ROM_latch[2], ROM_latch[3], ROM_latch[4], ROM_latch[5], ROM_latch[6], ROM_latch[7]};

initial begin
	failed = 8'h00;
	for(integer i = 0; i < 16384; i++) begin
		ROM[i] = 8'h00;
	end
	
	$readmemh("../../TestPGM/verilog.txt", ROM);
end

wire [12:0] A;
wire [13:0] ROM_addr = {A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], MCLK};
wire MCLK;
wire x2;
wire SC;
wire WC;
wire LB;
wire RB;
wire [7:0] IV_bus;
reg [7:0] command;
wire [7:0] IV_bus_out = ~{IV_bus[0], IV_bus[1], IV_bus[2], IV_bus[3], IV_bus[4], IV_bus[5], IV_bus[6], IV_bus[7]};
wire [7:0] RAM_raw = RAM[command];
wire [7:0] RAM_val = !LB && WCgb ? {RAM_raw[0], RAM_raw[1], RAM_raw[2], RAM_raw[3], RAM_raw[4], RAM_raw[5], RAM_raw[6], RAM_raw[7]} : 8'hzz;
wire [7:0] input_port = 8'hFF;
reg [3:0] output_port;
reg [7:0] output_port2_latch;
wire RS = output_port[0];
wire UART_CEb = output_port[1];
wire E = output_port[2];
wire LED = output_port[3];

wire WCgb = ~(WC & MCLK);
wire WCg = !WCgb;
wire cmd_clk = SC & MCLK;
wire RBb = ~RB;
wire oport_clk = MCLK & WCg & RBb & command[5];
wire oport2_clk = !clk & WCg & RBb & command[6];
wire [7:0] output_port2 = oport2_clk ? ~IV_bus_out : output_port2_latch;

assign IV_bus = command[7] & RBb ? ~{input_port[0], input_port[1], input_port[2], input_port[3], input_port[4], input_port[5], input_port[6], input_port[7]} : RAM_val;

always @(negedge clk) begin
	if(MCLK) begin
		ROM_latch <= ROM_val;
	end
	if(rst) begin
		command <= 8'hFF;
		output_port <= 4'hF;
		output_port2_latch <= 8'h00;
	end
end

always @(posedge cmd_clk) begin
	command <= IV_bus_out;
end

always @(negedge WCgb) begin
	if(!LB) begin
		RAM[command] <= ~IV_bus_out;
	end
end

always @(negedge oport2_clk) begin
	output_port2_latch <= ~IV_bus_out;
end

always @(posedge oport_clk) begin
	output_port <= ~IV_bus_out;
end

always @(posedge E) begin
	if(!UART_CEb) begin
		if(RS) begin
		
		end else begin
		
		end
	end
end

S8x305 S8x305 (
	.x1(clk),
	.x2(x2),
	.reset(!rst),
	.A(A),
	.I(ROM_reversed),
	.MCLK(MCLK),
	.IV(IV_bus),
	.SC(SC),
	.WC(WC),
	.RB(RB),
	.LB(LB),
	.r10(),
	.r11(),
	.r7(),
	.r15(),
	.r0(),
	.r5(),
	.r14(),
	.r8()
);

initial begin
	$dumpfile("tb.vcd");
	$dumpvars();
end

endmodule
