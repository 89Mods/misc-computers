`default_nettype none

module mc14500(
	input X2,
	input RST,
	input [3:0] I,

	output X1,
	inout DATA,
	output WRITE,
	output RR,
	output JMP,
	output RTN,
	output FLAG_O,
	output FLAG_F
);

reg RR_l;
reg IEN_l;
reg OEN_l;

reg [3:0] instr;
reg skip;
reg data_out;

wire g_2_1 = ~( instr[3] |  instr[2]);
wire g_2_2 = ~( instr[3] | ~instr[2]);
wire g_2_3 = ~(~instr[3] |  instr[2]);
wire g_2_4 = ~(~instr[3] | ~instr[2]);

wire g_1_1 = ~( instr[1] |  instr[0]);
wire g_1_2 = ~( instr[1] | ~instr[0]);
wire g_1_3 = ~(~instr[1] |  instr[0]);
wire g_1_4 = ~(~instr[1] | ~instr[0]);

wire NOPO_i = ~(g_2_1 & g_1_1);
wire ANDC_i = ~(g_2_2 & g_1_1);
wire XNOR_i = ~(g_2_2 & g_1_4);
wire IEN_i  = ~(g_2_3 & g_1_3);
wire OEN_i  = ~(g_2_3 & g_1_4);
wire JMP_i  = ~(g_2_4 & g_1_1);
wire RTN_i  = ~(g_2_4 & g_1_2);
wire SKZ_i  = ~(g_2_4 & g_1_3);
wire NOPF_i = ~(g_2_4 & g_1_4);

wire LDC_ORC   = g_1_3;
wire OR_ORC    = ~(g_1_1 | g_1_4) & g_2_2;
wire LD_OR     = g_1_2;
wire AND_XNOR  = g_1_4;
wire update_rr = ~(g_2_3 | g_2_4) & NOPO_i;

//Data bus
wire data = DATA & IEN_l;

//Logic Unit, directly translated from https://static.righto.com/images/mc14500b/alu-diagram.jpg
wire LU_out = ((((~ANDC_i & RR_l) | (~XNOR_i & ~RR_l) | LDC_ORC) & ~data) |
				(OR_ORC & RR_l) |
				((LD_OR ^ (AND_XNOR & RR_l)) & data)
				);
				
//Output signals
assign FLAG_O = ~(NOPO_i | skip);
assign FLAG_F = ~NOPF_i;
assign JMP    = ~JMP_i;
assign RTN    = ~RTN_i;
assign RR     = RR_l;
wire   WE     = ~(~g_2_3 | ~(g_1_1 | g_1_2));
assign WRITE  = WE & X2 & OEN_l;
assign X1     = X2;

assign DATA = WE ? data_out : 1'bz;

always @(posedge X2) begin
	//The one thing I’m 100% unsure about is how reset is done in MC14500, but the easiest way I’ve found is to force skip permanently during reset, and AND the RR latch data with reset.
	skip  <= ~(SKZ_i | RR_l) | RST;
	RR_l  <= (update_rr ? LU_out : RR_l) & ~RST;
	IEN_l <= IEN_i ? IEN_l : DATA;
	OEN_l <= OEN_i ? OEN_l : DATA;
	data_out <= (g_1_1 ? RR_l : ~RR_l) & OEN_l;
end

always @(negedge X2) begin
	instr <= I & {4{~skip}};
end

endmodule
