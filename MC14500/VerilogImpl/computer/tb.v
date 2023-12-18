module tb(
	input clk,
	input rstb
);

reg [7:0] ROM [32767:0];

initial begin
	for(integer i = 0; i < 32767; i++) begin
		ROM[i] = 0;
	end
	
	/*ROM[0] = 8'b00001010;
	ROM[1] = 8'b00001011;
	ROM[2] = 8'b00001010;
	ROM[3] = 8'b00001011;
	ROM[4] = 8'b00000010;
	
	ROM[5] = 8'b00101000;
	ROM[6] = 8'b00101001;
	ROM[7] = 8'b00101001;
	ROM[8] = 8'b00101000;
	ROM[9] = 8'b00101000;
	ROM[10] = 8'b00101000;
	ROM[11] = 8'b00101001;
	ROM[12] = 8'b00101001;
	
	ROM[13] = 8'b00001101;
	
	ROM[13] = 8'b00011001;
	ROM[14] = 8'b00011000;
	ROM[15] = 8'b00011001;
	ROM[16] = 8'b00011000;
	ROM[17] = 8'b00011001;
	ROM[18] = 8'b00011000;
	ROM[19] = 8'b00011001;
	ROM[20] = 8'b00011000;
	
	ROM[21] = 8'b00001111;
	ROM[22] = 8'b00001010;
	ROM[23] = 8'b00000000;
	ROM[24] = 8'b00001010;
	
	ROM[25] = 8'b00110001;
	ROM[26] = 8'b11111000;
	ROM[27] = 8'b00110001;
	ROM[28] = 8'b11101000;
	ROM[29] = 8'b00110001;
	ROM[30] = 8'b11011000;
	ROM[31] = 8'b00110001;
	ROM[32] = 8'b11001000;
	ROM[33] = 8'b00110001;
	ROM[34] = 8'b10111000;
	ROM[35] = 8'b00110001;
	ROM[36] = 8'b10101000;
	ROM[37] = 8'b00110001;
	ROM[38] = 8'b10011000;
	ROM[39] = 8'b00110001;
	ROM[40] = 8'b10001000;*/
	$readmemh("../test.txt", ROM);
end

`ifdef TRACE_ON
initial begin
	$dumpfile("tb.vcd");
	$dumpvars(0, tb);
	#1;
end
`endif

wire [14:0] rom_addr;
wire [7:0] rom_val = ROM[rom_addr];
wire UART_tx;
wire UART_clk;

reg receiving = 0;
reg [7:0] rec_buff = 0;
reg [3:0] uart_ctr = 0;

wire [7:0] next_rec_buff = {UART_tx, rec_buff[7:1]};

always @(posedge UART_clk) begin
	if(!receiving) begin
		receiving <= 1'b1;
		uart_ctr <= 4'h0;
		rec_buff <= 8'h00;
		if(UART_tx) $display("Invalid start bit on UART.");
	end else begin
		uart_ctr <= uart_ctr + 1'b1;
		rec_buff <= next_rec_buff;
		if(uart_ctr == 8) begin
			receiving <= 1'b0;
			if(!rec_buff[7] && rec_buff != 0) begin
				$write("%c", rec_buff);
				$fflush();
			end
		end
	end
end

computer computer(
	.rom_addr(rom_addr),
	.rom_val(rom_val),
	.UART_tx(UART_tx),
	.UART_clk(UART_clk),
	.rst(rstb),
	.clk(clk)
);

endmodule
