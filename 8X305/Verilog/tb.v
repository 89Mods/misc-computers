`default_nettype wire
`define BENCH
`timescale 1ns/10ps

module tb(
	input clk,
	input rst,
	output reg [7:0] failed
);

reg [15:0] ROM [8191:0];
reg [7:0] last_command_r;
reg [7:0] last_command_l;
reg [7:0] last_data_r;
reg [7:0] last_data_l;

wire chirp = A == 1037;

initial begin
	failed = 8'h00;
	for(integer i = 0; i < 8191; i=i+1) begin
		ROM[i] = 16'h0000;
	end
	//XMIT-Register
	ROM[0] = 16'b110_00000_10101100; //XMIT 0xAC > R0
	ROM[1] = 16'b110_00101_11111111; //XMIT 0xFF > R5
	ROM[2] = 16'b110_01110_10000111; //XMIT 0x87 > R14
	//XMIT-IV Bus
	ROM[3] = 16'b110_10_111_000_01100; //XMIT 0x0C > IV LB
	ROM[4] = 16'b110_11_101_011_11010; //XMIT (0x02 << 2) > IV RB[4:2]
	//XMIT Register, IV Bus
	//First, clear R10, R11 to later test they’ve not been modified
	ROM[5] = 16'b110_01010_00000000; //XMIT 0x00 > R10
	ROM[6] = 16'b110_01011_00000000; //XMIT 0x00 > R11
	//Actual instructions under test
	ROM[7] = 16'b110_01010_11110101; //XMIT 0xF5 > IV LB
	ROM[8] = 16'b110_01011_01011111; //XMIT 0x5F > IV RB
	//XMIT-IV Bus Address
	ROM[9]  = 16'b110_00111_10101010; //XMIT 0xAA > LB CMD (R7)
	ROM[10] = 16'b110_01111_01010101; //XMIT 0x55 > RB CMD (R15)
	//MOVE-Register, Register
	ROM[11] = 16'b000_00000_000_00101; //MOVE R0 > R5
	ROM[12] = 16'b000_01110_101_00101; //MOVE R14 ROR 5 > R5
	//MOVE-Register, IV Bus Address
	ROM[13] = 16'b000_00000_000_00111; //MOVE R0 > LB CMD (R7)
	ROM[14] = 16'b000_00000_001_01111; //MOVE R0 ROR 1 > RB CMD (R15)
	//MOVE-Register, IV Bus
	ROM[15] = 16'b000_00000_000_10111; //MOVE R0 > IV LB
	ROM[16] = 16'b000_00000_011_11111; //MOVE R0[2:0] | IV[7:3] > IV RB
	ROM[17] = 16'b000_01110_101_10101; //MOVE (R14 << 2)[6:2] | {IV[7], 5'h00, IV[1:0]} > IV LB
	//MOVE-IV Bus, Register
	ROM[18] = 16'b000_11111_000_00101; //MOVE IV RB > R5
	ROM[19] = 16'b000_10110_000_00101; //MOVE IV LB ROR 1 > R5
	ROM[20] = 16'b000_10110_100_00101; //MOVE (IV LB ROR 1)[3:0] > R5
	//MOVE-IV Bus, IV Bus
	ROM[21] = 16'b000_11111_000_10111; //MOVE IV RB > IV LB
	ROM[22] = 16'b000_11100_100_11110; //MOVE (IV RB ROR 3 & 8'h0F << 1) | (IV RB & 8'b11100001) > IV RB
	//MOVE-IV Bus, IV Bus Address
	ROM[23] = 16'b000_11111_000_00111; //MOVE IV RB > LB CMD (R7)
	ROM[24] = 16'b000_10101_101_01111; //MOVE (IV LB ROR 2)[4:0] > RB CMD (R15)
	//JMP
	ROM[25] = 16'b111_0000101110001; //JMP 369
	ROM[369] = 16'b110_00000_11001010; //XMIT 0xCA > R0
	//NZT-Register
	ROM[370] = 16'b101_00000_10000000; //NZT R0, 384
	ROM[384] = 16'b110_00101_00000000; //XMIT 0x00 > R5
	ROM[385] = 16'b101_00101_10000000; //NZT R5, 384
	ROM[386] = 16'b110_00101_00000101; //XMIT 0x05 > R5
	//NZT-IV Bus
	ROM[387] = 16'b101_10110_011_00000; //NZT LB ROR 1 & 8'h07, 384
	ROM[388] = 16'b110_00101_00101111; //XMIT 0x2F > R5
	ROM[389] = 16'b101_10101_011_01010; //NZT LB ROR 2 & 8'h07, 394
	ROM[394] = 16'b110_00101_11110010; //XMIT 0xF2 > R5
	//XEC-Register
	ROM[395] = 16'b111_0001000000000; //JMP 512
	ROM[512] = 16'b100_00101_00000101; //XEC @R5+5
	//XEC-IV Bus
	ROM[513] = 16'b100_11001_010_00101; //XEC @(IV RB ROR 1 & 8'h03 + 5)
	ROM[1024] = 16'b110_01110_11101001; //XMIT 0xE9 > R14
	//ADD
	ROM[1025] = 16'b110_00001_01011110; //XMIT 0x5E > R1
	ROM[1026] = 16'b110_00000_10000100; //XMIT 0x84 > R0
	ROM[1027] = 16'b001_00001_100_00011; //ADD R1 ROR 4 > R3
	ROM[1028] = 16'b000_00011_000_10111; //MOVE R3 > IV LB
	ROM[1029] = 16'b110_00000_00000100; //XMIT 0x04 > R0
	ROM[1030] = 16'b001_00001_100_00011; //ADD R1 ROR 4 > R3
	ROM[1031] = 16'b000_00011_000_11111; //MOVE R3 > IV RB
	//AND
	ROM[1032] = 16'b110_00000_00000011; //XMIT 0x03 > R0
	ROM[1033] = 16'b010_11101_100_00100; //AND IV RB ROR 2 & 8'h0F > R4
	ROM[1034] = 16'b000_00100_000_10111; //MOVE R4 > IV LB
	//XOR
	ROM[1035] = 16'b110_00000_00001010; //XMIT 0x0A > R0
	ROM[1036] = 16'b011_10111_101_10000; //XOR IV LB ROR 0 & 8'h1F > IV LB
	//XMIT example from datasheet
	ROM[1037] = 16'b110_11101_011_00110;
	
	//For XEC
	ROM[518] = 16'b111_0010000000000;
	ROM[13'h02F7] = 16'b000_00101_000_11111; //MOVE R5 > IV RB
end

reg [7:0] IV_in_lb;
always @(*) begin
	case(A)
		default: IV_in_lb = 8'h00;
		3: IV_in_lb = 8'hF0;
		17: IV_in_lb = 8'hD3;
		19: IV_in_lb = 8'h77;
		20: IV_in_lb = 8'h77;
		24: IV_in_lb = 8'h99;
		387: IV_in_lb = 8'hF0;
		389: IV_in_lb = 8'hF0;
		1036: IV_in_lb = 8'h73;
	endcase
end

reg [7:0] IV_in_rb;
always @(*) begin
	case(A)
		default: IV_in_rb = 8'h00;
		4: IV_in_rb = 8'h8F;
		16: IV_in_rb = 8'b11101010;
		18: IV_in_rb = 8'h77;
		21: IV_in_rb = 8'h69;
		22: IV_in_rb = 8'hCE;
		23: IV_in_rb = 8'h5F;
		513: IV_in_rb = 8'hCB;
		1033: IV_in_rb = 8'h95;
		1037: IV_in_rb = 8'hC9;
	endcase
end

wire [12:0] A;
wire MCLK;
wire x2;
wire SC;
wire WC;
wire LB;
wire RB;
wire [7:0] IV_bus;
wire [7:0] r10;
wire [7:0] r11;
wire [7:0] r7;
wire [7:0] r15;
wire [7:0] r0;
wire [7:0] r5;
wire [7:0] r14;
wire [7:0] r8;

wire [7:0] IV_in = LB ^ RB ? (LB ? IV_in_rb : IV_in_lb) : 8'h00;
assign IV_bus = SC || WC || (RB && LB) ? 8'hzz : ~{IV_in[0], IV_in[1], IV_in[2], IV_in[3], IV_in[4], IV_in[5], IV_in[6], IV_in[7]};
wire [7:0] IV_bus_out = ~{IV_bus[0], IV_bus[1], IV_bus[2], IV_bus[3], IV_bus[4], IV_bus[5], IV_bus[6], IV_bus[7]};

always @(posedge MCLK) begin
	if(A == 1) failed <= failed + (r0 != 8'hAC || WC || SC || !LB || !RB);
	if(A == 2) failed <= failed + (r5 != 8'hFF || WC || SC || !LB || !RB);
	if(A == 3) failed <= failed + (r14 != 8'h87 || WC || SC || !LB || !RB);
	if(A == 4) failed <= failed + (IV_bus_out != 8'h0C || LB || !RB || !WC || SC);
	if(A == 5) failed <= failed + (IV_bus_out != 8'b10001011 || RB || !LB || !WC || SC);
	if(A == 8) failed <= failed + (IV_bus_out != 8'hF5 || LB || !RB || r10 != 8'h00 || r11 != 8'h00 || !WC || SC);
	if(A == 9) failed <= failed + (IV_bus_out != 8'h5F || RB || !LB || r11 != 8'h00 || r10 != 8'h00 || !WC || SC);
	if(A == 10) failed <= failed + (IV_bus_out != 8'hAA || LB || !RB || WC || !SC || r11 != 8'h00 || r10 != 8'h00);
	if(A == 11) failed <= failed + (IV_bus_out != 8'h55 || !LB || RB || WC || !SC);
	if(A == 12) failed <= failed + (r7 != 8'hAA || r15 != 8'h55 || r5 != 8'hAC || WC || SC || !LB || !RB);
	if(A == 13) failed <= failed + (r5 != 8'h3C || WC || SC || !LB || !RB);
	if(A == 14) failed <= failed + (r7 != 8'hAC || WC || !SC || LB || !RB || IV_bus_out != 8'hAC);
	if(A == 15) failed <= failed + (r15 != 8'h56 || WC || !SC || !LB || RB || IV_bus_out != 8'h56);
	if(A == 16) failed <= failed + (!WC || SC || LB || !RB || IV_bus_out != 8'hAC);
	if(A == 17) failed <= failed + (!WC || SC || !LB || RB || IV_bus_out != 8'hEC);
	if(A == 18) failed <= failed + (!WC || SC || LB || !RB || IV_bus_out != 8'h9F);
	if(A == 19) failed <= failed + (r5 != 8'h77 || WC || SC || !LB || !RB);
	if(A == 20) failed <= failed + (r5 != 8'hBB || WC || SC || !LB || !RB);
	if(A == 21) failed <= failed + (r5 != 8'h0B || WC || SC || !LB || !RB);
	if(A == 22) failed <= failed + (!WC || SC || LB || !RB || IV_bus_out != 8'h69);
	if(A == 23) failed <= failed + (!WC || SC || !LB || RB || IV_bus_out != 8'hD2);
	if(A == 24) failed <= failed + (WC || !SC || LB || !RB || IV_bus_out != 8'h5F);
	if(A == 25) failed <= failed + (WC || !SC || !LB || RB || IV_bus_out != 8'h06);
	if(A >= 26 && A < 369) failed <= failed + 1'b1;
	if(A == 370) failed <= failed + (r0 != 8'hCA || WC || SC || !LB || !RB);
	if(A >= 371 && A < 384) failed <= failed + 1'b1;
	if(A == 385) failed <= failed + (r5 != 8'h00 || WC || SC || !LB || !RB);
	if(A == 386) failed <= failed + (WC || SC || !LB || !RB);
	if(A == 387) failed <= failed + (r5 != 8'h05 || WC || SC || !LB || !RB);
	if(A == 389) failed <= failed + (r5 != 8'h2F || WC || SC || !LB || !RB);
	if(A >= 390 && A < 394) failed <= failed + 1'b1;
	if(A == 394) failed <= failed + (WC || SC || !LB || !RB);
	if(A == 395) failed <= failed + (r5 != 8'hF2 || WC || SC || !LB || !RB);
	if(A == 512) failed <= failed + (WC || SC || !LB || !RB);
	if(A == 13'h02F7) failed <= failed + (WC || SC || !LB || !RB);
	if(A == 513) failed <= failed + (!WC || SC || !LB || RB || IV_bus_out != 8'hF2);
	if(A >= 514 && A < 1024 && A != 518 && A != 13'h02F7) failed <= failed + 1'b1;
	if(A == 1025) failed <= failed + (r14 != 8'hE9 || WC || SC || !LB || !RB);
	if(A == 1029) failed <= failed + (!WC || SC || LB || !RB || IV_bus_out != 8'h69 || r8 != 8'h01);
	if(A == 1032) failed <= failed + (!WC || SC || !LB || RB || IV_bus_out != 8'hE9 || r8 != 8'h00);
	if(A == 1035) failed <= failed + (!WC || SC || LB || !RB || IV_bus_out != 8'h01);
	if(A == 1037) failed <= failed + (!WC || SC || LB || !RB || IV_bus_out != 8'h79);
	if(A == 1038) failed <= failed + (!WC || SC || !LB || RB || IV_bus_out != 8'hD9);
	if(SC) begin
		if(!LB) begin
			last_command_l <= IV_bus_out;
		end
		if(!RB) begin
			last_command_r <= IV_bus_out;
		end
	end
	if(WC) begin
		if(!LB) begin
			last_data_l <= IV_bus_out;
		end
		if(!RB) begin
			last_data_r <= IV_bus_out;
		end
	end
	if(A == 1042) begin
		$finish();
	end
end

S8x305 S8x305 (
	.x1(clk),
	.x2(x2),
	.reset(!rst),
	.A(A),
	.I(ROM[A]),
	.MCLK(MCLK),
	.IV(IV_bus),
	.SC(SC),
	.WC(WC),
	.RB(RB),
	.LB(LB),
	.r10(r10),
	.r11(r11),
	.r7(r7),
	.r15(r15),
	.r0(r0),
	.r5(r5),
	.r14(r14),
	.r8(r8)
);

initial begin
	$dumpfile("tb.vcd");
	$dumpvars();
end

endmodule
