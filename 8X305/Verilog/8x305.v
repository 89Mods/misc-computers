module S8x305(
	input x1,
	output reg x2,
	input reset,
	
	inout [7:0] IV,
	output RB,
	output LB,
	output SC,
	output WC,
	
	output [12:0] A,
	input [15:0] I,

	output MCLK,
	
`ifdef BENCH
	output [7:0] r10,
	output [7:0] r11,
	output [7:0] r7,
	output [7:0] r15,
	output [7:0] r0,
	output [7:0] r5,
	output [7:0] r14,
	output [7:0] r8
`endif
);

reg [1:0] cycle;

reg [7:0] regs [15:0];

`ifdef BENCH
assign r0 = regs[0];
wire [7:0] r1 = regs[1];
wire [7:0] r2 = regs[2];
wire [7:0] r3 = regs[3];
wire [7:0] r4 = regs[4];
assign r5 = regs[5];
wire [7:0] r6 = regs[6];
assign r7 = regs[7];
assign r8 = regs[8];
wire [7:0] r9 = regs[9];
assign r10 = regs[10];
assign r11 = regs[11];
wire [7:0] r12 = regs[12];
wire [7:0] r13 = regs[13];
assign r14 = regs[14];
assign r15 = regs[15];
`endif

reg [12:0] PC;
reg [12:0] addr_reg;
assign A = addr_reg;
reg [15:0] i_latch;
reg [7:0] iv_latch;
wire [15:0] instr = cycle == 0 ? I : i_latch;

wire is_MOVE = instr[15:13] == 3'b000;
wire is_ADD = instr[15:13] == 3'b001;
wire is_AND = instr[15:13] == 3'b010;
wire is_XOR = instr[15:13] == 3'b011;
wire is_XEC = instr[15:13] == 3'b100;
wire is_NZT = instr[15:13] == 3'b101;
wire is_XMIT = instr[15:13] == 3'b110;
wire is_JMP = instr[15:13] == 3'b111;

wire [4:0] S_field = instr[12:8];
wire [2:0] L_field = instr[7:5];
wire [4:0] D_field = is_XMIT ? S_field : instr[4:0];
wire [12:0] A_field = instr[12:0];
wire [7:0] J_field = S_field[4] ? {3'b000, instr[4:0]} : instr[7:0];

wire is_ALU_op = is_MOVE || is_ADD || is_AND || is_XOR;

wire [7:0] XEC_targ = S_field[4]
		? {3'b000, iv_in_adj_rr_masked[4:0] + J_field[4:0]}
		: regs[S_field[3:0]] + J_field;

wire should_branch = !is_NZT || (S_field[4] ? iv_in_adj_rr_masked : regs[S_field[3:0]]) != 0;

wire to_iv_bus_address = (is_MOVE || is_XMIT) && (D_field == 5'h07 || D_field == 5'h0F);

wire MOVE_special = !S_field[4] && !D_field[4];
wire is_MOVE_IV_IV = is_MOVE && S_field[4] && D_field[4];
wire is_MOVE_IV_REG = is_MOVE && S_field[4] && !D_field[4];
wire [2:0] rr_amount = is_XEC ? S_field[2:0] : ~(is_XMIT ? 3'b111 : MOVE_special ? ~L_field : (!S_field[4] ? D_field[2:0] : S_field[2:0]));
wire [2:0] length = is_XMIT ? L_field : (MOVE_special ? 3'b111 : L_field);
wire [2:0] lsh_xmit = ~D_field[2:0];
wire [7:0] J_field_xmit = S_field[4] ? J_field << lsh_xmit : J_field;
wire [2:0] lsh_amount = ~(is_MOVE_IV_IV ? D_field[2:0] : (is_MOVE_IV_REG || is_NZT ? 3'b111 : ~rr_amount));

reg [7:0] l_bitmask;
always @(*) begin
	case(L_field)
		1: l_bitmask = 8'b00000001;
		2: l_bitmask = 8'b00000011;
		3: l_bitmask = 8'b00000111;
		4: l_bitmask = 8'b00001111;
		5: l_bitmask = 8'b00011111;
		6: l_bitmask = 8'b00111111;
		7: l_bitmask = 8'b01111111;
		0: l_bitmask = 8'b11111111;
	endcase
end

wire [7:0] ALU_in1 = regs[0];
wire [7:0] ALU_in2 = !S_field[4] ? (MOVE_special ? (regs[S_field[3:0]] >> rr_amount) | (regs[S_field[3:0]] << (8-rr_amount)) : regs[S_field[3:0]]) : iv_in_adj_rr_masked;
reg [8:0] ALU_res;
always @(*) begin
	case(instr[14:13])
		0: ALU_res = {regs[8][0], ALU_in2};
		1: ALU_res = {1'b0, ALU_in1} + {1'b0, ALU_in2};
		2: ALU_res = {regs[8][0], ALU_in1 & ALU_in2};
		3: ALU_res = {regs[8][0], ALU_in1 ^ ALU_in2};
	endcase
end
wire [7:0] l_bitmask_shifted = l_bitmask << (is_XMIT ? lsh_xmit : lsh_amount);
wire [7:0] ALU_res_adj = MOVE_special || is_MOVE_IV_REG ? ALU_res[7:0] : (iv_latch & ~l_bitmask_shifted) | ((ALU_res[7:0] << lsh_amount) & l_bitmask_shifted);
wire [7:0] XMIT_res_adj = S_field[4] ? (J_field_xmit & l_bitmask_shifted) | (iv_latch & ~l_bitmask_shifted) : J_field_xmit;

wire [7:0] iv_in_adj = {!IV[0], !IV[1], !IV[2], !IV[3], !IV[4], !IV[5], !IV[6], !IV[7]};
wire [7:0] iv_in_adj_rr = (iv_latch >> rr_amount) | (iv_latch << (8-rr_amount));
wire [7:0] iv_in_adj_rr_masked = is_XMIT ? iv_latch : iv_in_adj_rr & l_bitmask;

wire input_phase = cycle == 0;
wire processing_phase = cycle == 1;
wire output_phase = cycle == 2 || cycle == 3;

wire is_output_reg = (D_field[3:0] == 4'h0A || D_field[3:0] == 4'h0B) && is_XMIT;

assign LB = !((input_phase && S_field[4] && !S_field[3]) ||
				(output_phase && (is_ALU_op || is_XMIT) && D_field == 5'h07) ||
				(output_phase && (is_ALU_op || is_XMIT) && D_field[4] && !D_field[3]) ||
				(output_phase && is_output_reg && D_field[4:0] == 5'h0A) ||
				(input_phase && is_MOVE && !is_MOVE_IV_IV && D_field[4] && !D_field[3])
			);
assign RB = !((input_phase && S_field[4] && S_field[3]) ||
				(output_phase && (is_ALU_op || is_XMIT) && D_field == 5'h0F) ||
				(output_phase && (is_ALU_op || is_XMIT) && D_field[4] && D_field[3]) ||
				(output_phase && is_output_reg && D_field[4:0] == 5'h0B) ||
				(input_phase && is_MOVE && !is_MOVE_IV_IV && D_field[4] && D_field[3])
			);

wire AAA = ((is_ALU_op && D_field[4]) || (is_XMIT && S_field[4])) || is_output_reg;
assign SC = output_phase && to_iv_bus_address;
assign WC = AAA && output_phase;

wire will_output = to_iv_bus_address || AAA;
wire is_output = output_phase && will_output;

assign IV = is_output ? {!iv_latch[0], !iv_latch[1], !iv_latch[2], !iv_latch[3], !iv_latch[4], !iv_latch[5], !iv_latch[6], !iv_latch[7]} : 8'hzz;

assign #0.01 MCLK = cycle == 3;

always @(posedge x1) begin
	if(!reset) begin
		x2 <= 1'b0;
		cycle <= 2'b00;
		regs[8] <= 8'h00;
		iv_latch <= 8'h00;
		PC <= 13'h0000;
		addr_reg <= 13'h0000;
	end else begin
		regs[8] <= regs[8] & 8'h01;
		x2 <= !x2;
		cycle <= cycle + 2'b01;
		case(cycle)
			0: begin
				//Input phase
				i_latch <= I;
				iv_latch <= iv_in_adj;
			end
			1: begin
				if(is_ALU_op && will_output) begin
					iv_latch <= ALU_res_adj;
				end
				if(is_XMIT && will_output) begin
					iv_latch <= XMIT_res_adj;
				end
				if(is_JMP) begin
					PC <= A_field;
				end else if(is_NZT && should_branch) begin
					PC <= S_field[4] ? {PC[12:5], J_field[4:0]} : {PC[12:8], J_field};
				end else if(!is_XEC) begin
					PC <= PC + 1;
				end
			end
			2: begin
				//Instruction address changes here
				addr_reg <= is_XEC ? {PC[12:8], XEC_targ} : PC;
				if(is_ALU_op) begin
					regs[8] <= {7'h0, ALU_res[8]};
					if(!D_field[4]) begin
						regs[D_field[3:0]] <= ALU_res[7:0];
					end
				end else if(is_XMIT && !D_field[4] && !is_output_reg) begin
					regs[D_field[3:0]] <= XMIT_res_adj;
				end
			end
			3: begin
			end
		endcase
	end
end

endmodule
