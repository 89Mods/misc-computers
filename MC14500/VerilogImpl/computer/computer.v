`default_nettype none

module computer (
	output [14:0] rom_addr,
	input [7:0] rom_val,
	output UART_tx,
	output UART_clk,
	input rst,
	input clk
);

/*
 * IMPORTANT SIGNALS
 */
tri1 DATA;
wire WR;
wire JMP;
wire RTN;
wire FLAG_O;
wire FLAG_F;
wire WR_GATE;
wire [7:0] scratchpad;
wire [7:0] MAR;
wire [7:0] DOB;
wire [7:0] RAM_DB;
wire RAM_WEb;
wire DIA_Q7;
wire DIB_Q7;

`ifdef BENCH
wire S0 = scratchpad[0];
wire S1 = scratchpad[1];
wire S2 = scratchpad[2];
wire S3 = scratchpad[3];
wire S4 = scratchpad[4];
wire S5 = scratchpad[5];
wire S6 = scratchpad[6];

wire [7:0] MAR_corr = {MAR[0], MAR[1], MAR[2], MAR[3], MAR[4], MAR[5], MAR[6], MAR[7]};
wire [7:0] DOB_corr = {DOB[0], DOB[1], DOB[2], DOB[3], DOB[4], DOB[5], DOB[6], DOB[7]};
wire [7:0] RAM_DB_corr = {RAM_DB[0], RAM_DB[1], RAM_DB[2], RAM_DB[3], RAM_DB[4], RAM_DB[5], RAM_DB[6], RAM_DB[7]};
`endif

assign UART_tx = scratchpad[7];
assign UART_clk = scratchpad[6];

/*
 * CLOCKS
 */

wire CLK1;
wire CLK2;
wire CLK1_b;
wire CLK2_b;

hc74 U2(
	.rstb1(rst),
	.rstb2(rst),
	.stb1(1'b1),
	.stb2(1'b1),
	.data1(CLK2_b),
	.data2(CLK1),
	.clk1(clk),
	.clk2(clk),
	.q1(CLK1),
	.q2(CLK2),
	.qb1(CLK1_b),
	.qb2(CLK2_b)
);

/*
 * IO DECODE
 */
 
wire [3:0] IO_addr;
hc175 Ux(
	.D(rom_val[7:4]),
	.Q(IO_addr),
	.clk(CLK1),
	.MR(rst)
);

wire [7:0] IO_mux;
wire Y0;
wire Y1;
wire Y2;
wire Y3_b = IO_mux[3];
wire Y4_b = IO_mux[4];

hc138 U15(
	.G1(1'b1),
	.G2A(IO_addr[3]),
	.G2B(1'b0),
	.A(IO_addr[2:0]),
	.Y(IO_mux)
 );

/*
 * GLUE
 */
wire ctr_rst_clk;
wire U8B_6;
wire U8A_3;
wire U25B_6;
wire U8C_8;
hc32 U8(
	.A0(U8B_6),
	.B0(DIA_Q7),
	.Y0(U8A_3),
	.A1(Y3_b),
	.B1(WR),
	.Y1(U8B_6),
	.A2(U25B_6),
	.B2(DIB_Q7),
	.Y2(U8C_8),
	.A3(rst),
	.B3(clk),
	.Y3(ctr_rst_clk)
);

//Simulate D10 and D12
assign DATA = U8A_3 ? 1'bz : 1'b0; 
assign DATA = U8C_8 ? 1'bz : 1'b0;

wire U4D_11;
wire U4A_3;
wire dst_clk;
wire RST_INV;
wire JMP_b;
wire U1B_4;
hc04 U1(
	.A0(IO_mux[0]),
	.Y0(Y0),
	.A1(WR),
	.Y1(U1B_4),
	.A2(rst),
	.Y2(RST_INV),
	.A3(JMP),
	.Y3(JMP_b),
	.A4(U4A_3),
	.Y4(dst_clk),
	.A5(U4D_11),
	.Y5(WR_GATE)
);

wire U3D_8;
wire U5B_6;
wire U5D_11;
wire DIB_plb;
wire DIA_plb;
wire U3B_4;
wire U26B_6;
hc04 U3(
	.A0(U26B_6),
	.Y0(DIA_plb),
	.A1(RTN),
	.Y1(U3B_4),
	.A2(IO_mux[2]),
	.Y2(Y2),
	.A3(FLAG_F),
	.Y3(U3D_8),
	.A4(U5B_6),
	.Y4(RAM_WEb),
	.A5(IO_mux[1]),
	.Y5(Y1)
);

wire U4B_6;
wire U4C_8;
hc00 U4(
	.A0(WR_GATE),
	.B0(Y0),
	.Y0(U4A_3),
	.A1(IO_addr[3]),
	.B1(WR_GATE),
	.Y1(U4B_6),
	.A2(IO_addr[3]),
	.B2(U1B_4),
	.Y2(U4C_8),
	.A3(CLK2_b),
	.B3(WR),
	.Y3(U4D_11)
);

wire mar_clk;
wire dob_clk;
hc08 U5(
	.A0(WR_GATE),
	.B0(Y1),
	.Y0(mar_clk),
	.A1(FLAG_F),
	.B1(CLK2_b),
	.Y1(U5B_6),
	.A2(WR_GATE),
	.B2(Y2),
	.Y2(dob_clk),
	.A3(CLK2_b),
	.B3(FLAG_O),
	.Y3(U5D_11)
);

wire U25C_8;
wire U25D_11;
wire U26A_3;
hc00 U25(
	.A0(U26A_3),
	.B0(Y2),
	.Y0(DIB_plb),
	.A1(U25C_8),
	.B1(U25D_11),
	.Y1(U25B_6),
	.A2(Y4_b),
	.B2(Y4_b),
	.Y2(U25C_8),
	.A3(WR),
	.B3(WR),
	.Y3(U25D_11)
);

hc08 U26(
	.A0(FLAG_O),
	.B0(CLK2_b),
	.Y0(U26A_3),
	.A1(1'b0),
	.B1(1'b0),
	.A2(1'b0),
	.B2(1'b0),
	.A3(U5D_11),
	.B3(Y1),
	.Y3(U26B_6)
);

/*
 * DESTINATION REG
 */

wire [15:0] dest;

hc164 U7(
	.A(DATA),
	.B(DATA),
	.Q(dest[7:0]),
	.CLK(dst_clk),
	.CLRb(rst)
);

hc164 U6(
	.A(dest[7]),
	.B(dest[7]),
	.Q(dest[15:8]),
	.CLK(dst_clk),
	.CLRb(rst)
);

/*
 * PROGRAM COUNTER
 */

wire [15:0] PC;
assign rom_addr = PC[14:0];

wire ctr_clk = !ctr_rst_clk ? 1'b0 : CLK2_b;

wire rco_1;
hc163 U12(
	.CLRb(rst),
	.CLK(ctr_clk),
	.CIN(dest[3:0]),
	.ENP(1'b1),
	.LOADb(JMP_b),
	.ENT(1'b1),
	.Q(PC[3:0]),
	.RCO(rco_1)
);

wire rco_2;
hc163 U11(
	.CLRb(rst),
	.CLK(ctr_clk),
	.CIN(dest[7:4]),
	.ENP(1'b1),
	.LOADb(JMP_b),
	.ENT(rco_1),
	.Q(PC[7:4]),
	.RCO(rco_2)
);

wire rco_3;
hc163 U10(
	.CLRb(rst),
	.CLK(ctr_clk),
	.CIN(dest[11:8]),
	.ENP(1'b1),
	.LOADb(JMP_b),
	.ENT(rco_2),
	.Q(PC[11:8]),
	.RCO(rco_3)
);

hc163 U9(
	.CLRb(rst),
	.CLK(ctr_clk),
	.CIN(dest[15:12]),
	.ENP(1'b1),
	.LOADb(JMP_b),
	.ENT(rco_3),
	.Q(PC[15:12])
);

/*
 * SCRATCHPAD
 */

hc259 U14(
	.D(DATA),
	.A(IO_addr[2:0]),
	.Eb(U4B_6),
	.CLRb(rst),
	.Q(scratchpad)
);

hc4051 U20(
	.Eb(U4C_8),
	.S(IO_addr[2:0]),
	.A_out(DATA),
	.A_in(scratchpad)
);

/*
 * RAM
 */

hc164 U17_mar(
	.A(DATA),
	.B(DATA),
	.Q(MAR),
	.CLK(mar_clk),
	.CLRb(U3B_4)
);

hc164 U18_dob(
	.A(DATA),
	.B(DATA),
	.Q(DOB),
	.CLK(dob_clk),
	.CLRb(rst)
);

hc244 U19(
	.A1(DOB[3:0]),
	.A2(DOB[7:4]),
	.OEb1(U3D_8),
	.OEb2(U3D_8),
	.Y1(RAM_DB[3:0]),
	.Y2(RAM_DB[7:4])
);

hy6116a U21_ram(
	.CSb(1'b0),
	.WEb(RAM_WEb),
	.OEb(FLAG_F),
	.A({3'b000, MAR}),
	.IO(RAM_DB)
);

hc165 U22_dia(
	.DS(1'b0),
	.D(RAM_DB),
	.PLb(DIA_plb),
	.CP(CLK2_b),
	.CEb(Y3_b),
	.Q7(DIA_Q7)
);

hc165 U24_dib(
	.DS(1'b0),
	.D(RAM_DB),
	.PLb(DIB_plb),
	.CP(CLK2_b),
	.CEb(Y4_b),
	.Q7(DIB_Q7)
);

/*
 * CPU
 */
 
wire X1;
mc14500 mc14500(
	.X1(X1),
	.X2(CLK1_b),
	.RST(RST_INV),
	.I(rom_val[3:0]),
	
	.DATA(DATA),
	.WRITE(WR),
	.JMP(JMP),
	.RTN(RTN),
	.FLAG_O(FLAG_O),
	.FLAG_F(FLAG_F)
);

`ifdef BENCH
wire MARKER = rom_val == 8'hE0;
always @(posedge X1) begin
	if(rom_val == 8'hF0) begin
		$display("");
		$finish();
	end
end
`endif
 
endmodule
