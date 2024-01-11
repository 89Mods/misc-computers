	; Register names in octal
	; R10 = OVF
	; R7 = LB
	; R17 = RB
	; R0 = AUX
	; R12, R13 = Special during xmit

UART_DEL_TIME equ $C1

TO_HEX_PTR equ 1
TEST_VAL equ 2

MIN00 equ 8
MIN01 equ 9
MIN02 equ 10
MIN03 equ 11
MIN10 equ 12
MIN11 equ 13
MIN12 equ 14
MIN13 equ 15
MRES0 equ 16
MRES1 equ 17
MRES2 equ 18
MRES3 equ 19
MRES4 equ 20
MRES5 equ 21
MRES6 equ 22
MRES7 equ 23

	org 0
start:
	nop
	xmit 0, R5
	move R5, R6
	move R6, R11
	
	xmit 64, IVL
	xmit 255-3, AUX ; Master reset
	move AUX, RIV7
	xmit 32, IVL
	xmit 10, RIV7
	xmit 8, RIV7
	xmit 12, RIV7
	xmit 10, RIV7
	
	xmit 64, IVL
	xmit 255-21, AUX ; div 16, 8 bits + 1 stop bit, tx int disabled, rx int disabled
	move AUX, RIV7
	xmit 32, IVL
	xmit 8, RIV7
	xmit 12, RIV7
	xmit 10, RIV7
	
loop:
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_3535:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_3535
	
	xmit MIN00, IVL
	xmit 33, R12
	xmit TO_HEX_PTR, IVL
	xmit MIN00, R12
	xmit 0, R1
	jmp print_hex
print_hex_ret_0:

	xmit 64, IVL
	xmit 255-'*', R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_13591:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_13591

	xmit MIN10, IVL
	xmit 207, R12
	xmit TO_HEX_PTR, IVL
	xmit MIN10, R12
	xmit 1, R1
	jmp print_hex
print_hex_ret_1:

	xmit 64, IVL
	xmit 255-'=', R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_13522:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_13522
	
	xmit 0, R1
	jmp mul_8x8
mul_ret_0:
	
	xmit TO_HEX_PTR, IVL
	xmit MRES1, R12
	xmit 2, R1
	jmp print_hex
print_hex_ret_2:
	xmit TO_HEX_PTR, IVL
	xmit MRES0, R12
	xmit 3, R1
	jmp print_hex
print_hex_ret_3:
	
	xmit 0, R1
	jmp newl
newl_ret_0:
	
	move R3, R3 ; Emulator breakpoint, NOP on real CPU
	jmp loop

newl:
	xmit 64, IVL
	xmit 255-13, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_315415:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_315415
	xmit 64, IVL
	xmit 255-10, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_1595154:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_1595154
newl_return:
	xec newl_return+1(R1)
	jmp newl_ret_0

	; multiplies two 8-bit numbers with 16-bit result
mul_8x8:
	xmit MIN00, IVL
	move LIV7, R3
	xmit MIN10, IVL
	move LIV7, R4
	xmit 0, R5
	xmit 0, R6
	xmit 0, R11
	xmit 128, R2
mul_8x8_loop:
	move R3(1), AUX
	move AUX, R3
	and R2, AUX
	xor R2, AUX
 	nzt AUX, mul_8x8_no_carry
	move R4, AUX
	add R6, R6
	move R11, AUX
	add R10, R11
	move R5, AUX
	add R11, R11
mul_8x8_no_carry:
	move R5, AUX
	add R5, R5
	move R4, AUX
	add R4, R4
	move R5, AUX
	add R10, R5
	xmit 127, AUX
	and R3, R3
	nzt R3, mul_8x8_loop
	xmit MRES0, IVL
	move R6, LIV7
	xmit MRES1, IVL
	move R11, LIV7
	jmp mul_return
	align 32
mul_return:
	xec mul_return+1(R1)
	jmp mul_ret_0

	; prints 8-bit number as hex
print_hex:
	xmit TO_HEX_PTR, IVL
	move LIV7, AUX
	move AUX, IVL
	move LIV7, AUX
	move AUX, R3
	
	move AUX(4), R2
	xmit 15, AUX
	and R2, R2
	xmit 255-9, AUX
	add R2, AUX
	xmit 128, R2
	and R2, AUX
	nzt AUX, hex_dec_1
hex_hex_1:
	move R3(4), AUX
	xmit 15, R2
	and R2, AUX
	xmit 'A'-10, R2
	add R2, R2
	jmp hex_cont_1
hex_dec_1:
	move R3(4), AUX
	xmit 15, R2
	and R2, AUX
	xmit '0', R2
	add R2, R2
hex_cont_1:
	xmit 255, AUX
	xor R2, R2
	xmit 64, IVL
	move R2, RIV7
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_1394814:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_1394814
	
	move R3, R2
	xmit 15, AUX
	and R2, R2
	xmit 255-9, AUX
	add R2, AUX
	xmit 128, R2
	and R2, AUX
	nzt AUX, hex_dec_2
hex_hex_2:
	move R3, AUX
	xmit 15, R2
	and R2, AUX
	xmit 'A'-10, R2
	add R2, R2
	jmp hex_cont_2
hex_dec_2:
	move R3, AUX
	xmit 15, R2
	and R2, AUX
	xmit '0', R2
	add R2, R2
hex_cont_2:
	xmit 255, AUX
	xor R2, R2
	xmit 64, IVL
	move R2, RIV7
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_1359851:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_1359851
	
	jmp print_hex_return
	
	align 16
print_hex_return:
	xec print_hex_return+1(R1)
	jmp print_hex_ret_0
	jmp print_hex_ret_1
	jmp print_hex_ret_2
	jmp print_hex_ret_3
