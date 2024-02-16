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
MTEMP0 equ 24
MTEMP1 equ 25
MTEMP2 equ 26
MSIGN  equ 27

C1 equ 64
C2 equ 68
C3 equ 72
C4 equ 76
C_IM equ 80
C_RE equ 84
MAN_X equ 88
MAN_Y equ 92
MAN_XX equ 96
MAN_YY equ 100
ITER_COUNT equ 200
CURR_ROW equ 201
CURR_COL equ 202

; Pre-computed constants for w=238, h=48
M_WIDTH equ 238
M_HEIGHT equ 48
M_HEIGHT_M1 equ M_HEIGHT-1
C1_PRE equ 1101
C4_PRE equ 2730
W_D2 equ 119
H_D2 equ 24

; Settings
ZOOM equ $F75B02
RE equ 0
IMAG equ 0
MAX_ITER equ 128

	org 0
	nop
	nop
	jmp start
print_hex_return:
	xec print_hex_return+1(R1)
	jmp print_hex_ret_0
	jmp print_hex_ret_1
	jmp print_hex_ret_2
	jmp print_hex_ret_3
	jmp print_hex_ret_4
	jmp print_hex_ret_5
	jmp print_hex_ret_6
	jmp print_hex_ret_7
	;jmp print_hex_ret_8
	;jmp print_hex_ret_9
	;jmp print_hex_ret_10
	;jmp print_hex_ret_11

mul_32x32_ret:
	xec mul_32x32_ret+1(R1)
	jmp mul_32x32_ret_0
	jmp mul_32x32_ret_1
	jmp mul_32x32_ret_2
	jmp mul_32x32_ret_3
	jmp mul_32x32_ret_4
	jmp mul_32x32_ret_5
	jmp mul_32x32_ret_6
	jmp mul_32x32_ret_7
	jmp mul_32x32_ret_8

newl_return:
	xec newl_return+1(R1)
	jmp newl_ret_0
	jmp newl_ret_1
	jmp newl_ret_2
	jmp newl_ret_3

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
	
	; C1 = C1_PRE * ZOOM
	; C2 = W_D2 * C1
	xmit 0, R1
	xmit MIN00, IVL
	move R1, LIV7
	xmit MIN03, IVL
	move R1, LIV7
	xmit MIN13, IVL
	move R1, LIV7
	xmit MIN01, IVL
	xmit C1_PRE&255, R1
	move R1, LIV7
	xmit MIN02, IVL
	xmit C1_PRE>>8, R1
	move R1, LIV7
	xmit MIN10, IVL
	xmit ZOOM&255, R1
	move R1, LIV7
	xmit MIN11, IVL
	xmit ( ZOOM >> 8 ) & 255, R1
	move R1, LIV7
	xmit MIN12, IVL
	xmit ( ZOOM >> 16 ) & 255, R1
	move R1, LIV7
	xmit 0, R1
	jmp mul_32x32_unsigned
mul_32x32_ret_0:
	xmit MRES3, IVL
	move LIV7, R1
	xmit MRES4, IVL
	move LIV7, R2
	xmit MRES5, IVL
	move LIV7, R3
	xmit MRES6, IVL
	move LIV7, R4
	xmit MIN00, IVL
	move R1, LIV7
	xmit C1, IVL
	move R1, LIV7
	xmit MIN01, IVL
	move R2, LIV7
	xmit C1+1, IVL
	move R2, LIV7
	xmit MIN02, IVL
	move R3, LIV7
	xmit C1+2, IVL
	move R3, LIV7
	xmit MIN03, IVL
	move R4, LIV7
	xmit C1+3, IVL
	move R4, LIV7
	xmit 0, R1
	xmit MIN10, IVL
	move R1, LIV7
	xmit MIN11, IVL
	move R1, LIV7
	xmit MIN12, IVL
	move R1, LIV7
	xmit MIN13, IVL
	xmit W_D2, R1
	move R1, LIV7
	xmit 1, R1
	jmp mul_32x32_unsigned
mul_32x32_ret_1:
	xmit MRES3, IVL
	move LIV7, R1
	xmit C2, IVL
	move R1, LIV7
	xmit MRES4, IVL
	move LIV7, R1
	xmit C2+1, IVL
	move R1, LIV7
	xmit MRES5, IVL
	move LIV7, R1
	xmit C2+2, IVL
	move R1, LIV7
	xmit MRES6, IVL
	move LIV7, R1
	xmit C2+3, IVL
	move R1, LIV7

	; C4 = C4_PRE * ZOOM
	; C3 = H_D2 * C4
	xmit 0, R1
	xmit MIN00, IVL
	move R1, LIV7
	xmit MIN03, IVL
	move R1, LIV7
	xmit MIN13, IVL
	move R1, LIV7
	xmit MIN01, IVL
	xmit C4_PRE&255, R1
	move R1, LIV7
	xmit MIN02, IVL
	xmit C4_PRE>>8, R1
	move R1, LIV7
	xmit MIN10, IVL
	xmit ZOOM&255, LIV7
	xmit MIN11, IVL
	xmit ( ZOOM >> 8 ) & 255, R1
	move R1, LIV7
	xmit MIN12, IVL
	xmit ( ZOOM >> 16 ) & 255, R1
	move R1, LIV7
	xmit 2, R1
	jmp mul_32x32_unsigned
mul_32x32_ret_2:
	xmit MRES3, IVL
	move LIV7, R1
	xmit MRES4, IVL
	move LIV7, R2
	xmit MRES5, IVL
	move LIV7, R3
	xmit MRES6, IVL
	move LIV7, R4
	xmit MIN00, IVL
	move R1, LIV7
	xmit C4, IVL
	move R1, LIV7
	xmit MIN01, IVL
	move R2, LIV7
	xmit C4+1, IVL
	move R2, LIV7
	xmit MIN02, IVL
	move R3, LIV7
	xmit C4+2, IVL
	move R3, LIV7
	xmit MIN03, IVL
	move R4, LIV7
	xmit C4+3, IVL
	move R4, LIV7
	xmit 0, R1
	xmit MIN10, IVL
	move R1, LIV7
	xmit MIN11, IVL
	move R1, LIV7
	xmit MIN12, IVL
	move R1, LIV7
	xmit MIN13, IVL
	xmit H_D2, LIV7
	xmit 3, R1
	jmp mul_32x32_unsigned
mul_32x32_ret_3:
	xmit MRES3, IVL
	move LIV7, R1
	xmit C3, IVL
	move R1, LIV7
	xmit MRES4, IVL
	move LIV7, R1
	xmit C3+1, IVL
	move R1, LIV7
	xmit MRES5, IVL
	move LIV7, R1
	xmit C3+2, IVL
	move R1, LIV7
	xmit MRES6, IVL
	move LIV7, R1
	xmit C3+3, IVL
	move R1, LIV7

	xmit TO_HEX_PTR, IVL
	xmit C2+3, R1
	move R1, LIV7
	xmit 0, R1
	jmp print_hex
print_hex_ret_0:
	xmit 64, IVL
	xmit 255-'.', R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_3154151:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_3154151
	xmit TO_HEX_PTR, IVL
	xmit C2+2, R1
	move R1, LIV7
	xmit 1, R1
	jmp print_hex
print_hex_ret_1:
	xmit TO_HEX_PTR, IVL
	xmit C2+1, R1
	move R1, LIV7
	xmit 2, R1
	jmp print_hex
print_hex_ret_2:
	xmit TO_HEX_PTR, IVL
	xmit C2, R1
	move R1, LIV7
	xmit 3, R1
	jmp print_hex
print_hex_ret_3:
	xmit 0, R1
	jmp newl
newl_ret_0:

	xmit TO_HEX_PTR, IVL
	xmit C3+3, R1
	move R1, LIV7
	xmit 4, R1
	jmp print_hex
print_hex_ret_4:
	xmit 64, IVL
	xmit 255-'.', R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_3154:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_3154
	xmit TO_HEX_PTR, IVL
	xmit C3+2, R1
	move R1, LIV7
	xmit 5, R1
	jmp print_hex
print_hex_ret_5:
	xmit TO_HEX_PTR, IVL
	xmit C3+1, R1
	move R1, LIV7
	xmit 6, R1
	jmp print_hex
print_hex_ret_6:
	xmit TO_HEX_PTR, IVL
	xmit C3, R1
	move R1, LIV7
	xmit 7, R1
	jmp print_hex
print_hex_ret_7:
	xmit 1, R1
	jmp newl
newl_ret_1:

	; Negate C2, C3 (they’re only ever subtracted, so this’ll save time later)
	xmit 255, AUX
	xmit C2, IVL
	xor LIV7, LIV7
	xmit C2+1, IVL
	xor LIV7, LIV7
	xmit C2+2, IVL
	xor LIV7, LIV7
	xmit C2+3, IVL
	xor LIV7, LIV7
	xmit C3, IVL
	xor LIV7, LIV7
	xmit C3+1, IVL
	xor LIV7, LIV7
	xmit C3+2, IVL
	xor LIV7, LIV7
	xmit C3+3, IVL
	xor LIV7, LIV7
	xmit 1, AUX
	xmit C2, IVL
	add LIV7, LIV7
	xmit C2+1, IVL
	move R10, AUX
	add LIV7, LIV7
	xmit C2+2, IVL
	move R10, AUX
	add LIV7, LIV7
	xmit C2+3, IVL
	move R10, AUX
	add LIV7, LIV7
	xmit 1, AUX
	xmit C3, IVL
	add LIV7, LIV7
	xmit C3+1, IVL
	move R10, AUX
	add LIV7, LIV7
	xmit C3+2, IVL
	move R10, AUX
	add LIV7, LIV7
	xmit C3+3, IVL
	move R10, AUX
	add LIV7, LIV7

	xmit M_HEIGHT_M1, R1
	xmit CURR_ROW, IVL
	move R1, LIV7
mandel_loop_rows:
	; res = CURR_ROW * C4
	xmit C4, IVL
	move LIV7, R1
	xmit C4+1, IVL
	move LIV7, R2
	xmit C4+2, IVL
	move LIV7, R3
	xmit C4+3, IVL
	move LIV7, R4
	xmit MIN00, IVL
	move R1, LIV7
	xmit MIN01, IVL
	move R2, LIV7
	xmit MIN02, IVL
	move R3, LIV7
	xmit MIN03, IVL
	move R4, LIV7
	xmit MIN10, IVL
	xmit 0, LIV7
	xmit MIN11, IVL
	xmit 0, LIV7
	xmit MIN12, IVL
	xmit 0, LIV7
	xmit CURR_ROW, IVL
	move LIV7, AUX
	xmit MIN13, IVL
	move AUX, LIV7
	xmit 4, R1
	jmp mul_32x32_unsigned
mul_32x32_ret_4:
	; regs = res + IMAG
	xmit MRES3, IVL
	move LIV7, R1
	xmit MRES4, IVL
	move LIV7, R2
	xmit MRES5, IVL
	move LIV7, R3
	xmit MRES6, IVL
	move LIV7, R4
	; Add
	xmit IMAG&255, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit (IMAG>>8)&255, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit (IMAG>>16)&255, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit IMAG>>24, AUX
	add R4, R4
	; C_IM = regs + (-C3)
	; Add
	xmit C3, IVL
	move LIV7, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C3+1, IVL
	move LIV7, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C3+2, IVL
	move LIV7, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit C3+3, IVL
	move LIV7, AUX
	add R4, R4
	xmit C_IM, IVL
	move R1, LIV7
	xmit C_IM+1, IVL
	move R2, LIV7
	xmit C_IM+2, IVL
	move R3, LIV7
	xmit C_IM+3, IVL
	move R4, LIV7

	xmit CURR_COL, IVL
	xmit 0, LIV7
mandel_loop_cols:
	; res = CURR_COL * C1
	xmit C1, IVL
	move LIV7, R1
	xmit C1+1, IVL
	move LIV7, R2
	xmit C1+2, IVL
	move LIV7, R3
	xmit C1+3, IVL
	move LIV7, R4
	xmit MIN00, IVL
	move R1, LIV7
	xmit MIN01, IVL
	move R2, LIV7
	xmit MIN02, IVL
	move R3, LIV7
	xmit MIN03, IVL
	move R4, LIV7
	xmit MIN10, IVL
	xmit 0, LIV7
	xmit MIN11, IVL
	xmit 0, LIV7
	xmit MIN12, IVL
	xmit 0, LIV7
	xmit CURR_COL, IVL
	move LIV7, AUX
	xmit MIN13, IVL
	move AUX, LIV7
	xmit 5, R1
	jmp mul_32x32_unsigned
mul_32x32_ret_5:
	; regs = res + RE
	xmit MRES3, IVL
	move LIV7, R1
	xmit MRES4, IVL
	move LIV7, R2
	xmit MRES5, IVL
	move LIV7, R3
	xmit MRES6, IVL
	move LIV7, R4
	; Add
	xmit RE&255, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit (RE>>8)&255, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit (RE>>16)&255, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit RE>>24, AUX
	add R4, R4
	; C_RE = MAN_X = regs + (-C2)
	; Add
	xmit C2, IVL
	move LIV7, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C2+1, IVL
	move LIV7, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C2+2, IVL
	move LIV7, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit C2+3, IVL
	move LIV7, AUX
	add R4, R4
	xmit C_RE, IVL
	move R1, LIV7
	xmit MAN_X, IVL
	move R1, LIV7
	xmit C_RE+1, IVL
	move R2, LIV7
	xmit MAN_X+1, IVL
	move R2, LIV7
	xmit C_RE+2, IVL
	move R3, LIV7
	xmit MAN_X+2, IVL
	move R3, LIV7
	xmit C_RE+3, IVL
	move R4, LIV7
	xmit MAN_X+3, IVL
	move R4, LIV7

	; MAN_Y = C_IM
	xmit C_IM, IVL
	move LIV7, R1
	xmit MAN_Y, IVL
	move R1, LIV7
	xmit C_IM+1, IVL
	move LIV7, R1
	xmit MAN_Y+1, IVL
	move R1, LIV7
	xmit C_IM+2, IVL
	move LIV7, R1
	xmit MAN_Y+2, IVL
	move R1, LIV7
	xmit C_IM+3, IVL
	move LIV7, R1
	xmit MAN_Y+3, IVL
	move R1, LIV7

	; iteration = 0
	xmit ITER_COUNT, IVL
	xmit 0, LIV7
mandel_calc_loop:
	; yy = y * y
	xmit MAN_Y, IVL
	move LIV7, R1
	xmit MIN00, IVL
	move R1, LIV7
	xmit MIN10, IVL
	move R1, LIV7
	xmit MAN_Y+1, IVL
	move LIV7, R1
	xmit MIN01, IVL
	move R1, LIV7
	xmit MIN11, IVL
	move R1, LIV7
	xmit MAN_Y+2, IVL
	move LIV7, R1
	xmit MIN02, IVL
	move R1, LIV7
	xmit MIN12, IVL
	move R1, LIV7
	xmit MAN_Y+3, IVL
	move LIV7, R1
	xmit MIN03, IVL
	move R1, LIV7
	xmit MIN13, IVL
	move R1, LIV7
	xmit 6, R1
	jmp mul_32x32_signed
mul_32x32_ret_6:
	xmit MRES3, IVL
	move LIV7, R1
	xmit MAN_YY, IVL
	move R1, LIV7
	xmit MRES4, IVL
	move LIV7, R1
	xmit MAN_YY+1, IVL
	move R1, LIV7
	xmit MRES5, IVL
	move LIV7, R1
	xmit MAN_YY+2, IVL
	move R1, LIV7
	xmit MRES6, IVL
	move LIV7, R1
	xmit MAN_YY+3, IVL
	move R1, LIV7

	; regs = x * y
	xmit MAN_X, IVL
	move LIV7, R1
	xmit MIN00, IVL
	move R1, LIV7
	xmit MAN_X+1, IVL
	move LIV7, R1
	xmit MIN01, IVL
	move R1, LIV7
	xmit MAN_X+2, IVL
	move LIV7, R1
	xmit MIN02, IVL
	move R1, LIV7
	xmit MAN_X+3, IVL
	move LIV7, R1
	xmit MIN03, IVL
	move R1, LIV7
	xmit MAN_Y, IVL
	move LIV7, R1
	xmit MIN10, IVL
	move R1, LIV7
	xmit MAN_Y+1, IVL
	move LIV7, R1
	xmit MIN11, IVL
	move R1, LIV7
	xmit MAN_Y+2, IVL
	move LIV7, R1
	xmit MIN12, IVL
	move R1, LIV7
	xmit MAN_Y+3, IVL
	move LIV7, R1
	xmit MIN13, IVL
	move R1, LIV7
	xmit 7, R1
	jmp mul_32x32_signed
mul_32x32_ret_7:
	xmit MRES3, IVL
	move LIV7, R1
	xmit MRES4, IVL
	move LIV7, R2
	xmit MRES5, IVL
	move LIV7, R3
	xmit MRES6, IVL
	move LIV7, R4

	; regs = regs << 1
	move R4, AUX
	add R4, R4
	move R3, AUX
	add R3, R3
	move R4, AUX
	add R10, R4
	move R2, AUX
	add R2, R2
	move R3, AUX
	add R10, R3
	move R1, AUX
	add R1, R1
	move R2, AUX
	add R10, R2

	; y = regs + c_im
	; Add
	xmit C_IM, IVL
	move LIV7, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C_IM+1, IVL
	move LIV7, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C_IM+2, IVL
	move LIV7, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit C_IM+3, IVL
	move LIV7, AUX
	add R4, R4
	xmit MAN_Y, IVL
	move R1, LIV7
	xmit MAN_Y+1, IVL
	move R2, LIV7
	xmit MAN_Y+2, IVL
	move R3, LIV7
	xmit MAN_Y+3, IVL
	move R4, LIV7

	; xx = regs[1,2,3,4] = x * x
	xmit MAN_X, IVL
	move LIV7, R1
	xmit MIN00, IVL
	move R1, LIV7
	xmit MIN10, IVL
	move R1, LIV7
	xmit MAN_X+1, IVL
	move LIV7, R1
	xmit MIN01, IVL
	move R1, LIV7
	xmit MIN11, IVL
	move R1, LIV7
	xmit MAN_X+2, IVL
	move LIV7, R1
	xmit MIN02, IVL
	move R1, LIV7
	xmit MIN12, IVL
	move R1, LIV7
	xmit MAN_X+3, IVL
	move LIV7, R1
	xmit MIN03, IVL
	move R1, LIV7
	xmit MIN13, IVL
	move R1, LIV7
	xmit 8, R1
	jmp mul_32x32_signed
mul_32x32_ret_8:
	xmit MRES3, IVL
	move LIV7, R1
	xmit MAN_XX, IVL
	move R1, LIV7
	xmit MRES4, IVL
	move LIV7, R2
	xmit MAN_XX+1, IVL
	move R2, LIV7
	xmit MRES5, IVL
	move LIV7, R3
	xmit MAN_XX+2, IVL
	move R3, LIV7
	xmit MRES6, IVL
	move LIV7, R4
	xmit MAN_XX+3, IVL
	move R4, LIV7

	; regs[11,12,13,14] = -YY
	xmit 255, AUX
	xmit MAN_YY, IVL
	xor LIV7, R11
	xmit MAN_YY+1, IVL
	xor LIV7, R12
	xmit MAN_YY+2, IVL
	xor LIV7, R13
	xmit MAN_YY+3, IVL
	xor LIV7, R14
	xmit 1, AUX
	add R11, R11
	move R10, AUX
	add R12, R12
	move R10, AUX
	add R13, R13
	move R14, AUX
	add R10, R14

	; regs[1,2,3,4] = regs[1,2,3,4] + regs[11,12,13,14]
	; Add
	move R1, AUX
	add R11, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	move R2, AUX
	add R12, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	move R3, AUX
	add R13, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	move R4, AUX
	add R14, R4

	; x = regs[1,2,3,4] + c_re
	; Add
	xmit C_RE, IVL
	move LIV7, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C_RE+1, IVL
	move LIV7, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit C_RE+2, IVL
	move LIV7, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit C_RE+3, IVL
	move LIV7, AUX
	add R4, R4
	xmit MAN_X, IVL
	move R1, LIV7
	xmit MAN_X+1, IVL
	move R2, LIV7
	xmit MAN_X+2, IVL
	move R3, LIV7
	xmit MAN_X+3, IVL
	move R4, LIV7

	; regs = xx
	xmit MAN_XX, IVL
	move LIV7, R1
	xmit MAN_XX+1, IVL
	move LIV7, R2
	xmit MAN_XX+2, IVL
	move LIV7, R3
	xmit MAN_XX+3, IVL
	move LIV7, R4

	; regs = regs + yy
	; Add
	xmit MAN_YY, IVL
	move LIV7, AUX
	add R1, R1
	; Propagate carry
	move R2, AUX
	add R10, R2
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit MAN_YY+1, IVL
	move LIV7, AUX
	add R2, R2
	; Propagate carry
	move R3, AUX
	add R10, R3
	move R4, AUX
	add R10, R4
	; Add
	xmit MAN_YY+2, IVL
	move LIV7, AUX
	add R3, R3
	; Propagate carry
	move R4, AUX
	add R10, R4
	; Add
	xmit MAN_YY+3, IVL
	move LIV7, AUX
	add R4, R4

	; exit if regs > 4
	xmit 251, AUX
	add R4, R4
	nzt R10, mandel_calc_loop_overflow

	; iteration++
	xmit ITER_COUNT, IVL
	xmit 1, AUX
	add LIV7, AUX
	move AUX, LIV7

	; exit if iteration > MAX_ITER
	xmit 255-MAX_ITER, R1
	add AUX, AUX
	nzt R10, mandel_calc_loop_max_iters
	jmp mandel_calc_loop
mandel_calc_loop_max_iters:

	xmit 64, IVL
	xmit 255-' ', R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_31541511:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_31541511

	jmp mandel_calc_loop_end
mandel_calc_loop_overflow:

	xmit 64, IVL
	xmit 255-27, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_34262462:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_34262462

	xmit 64, IVL
	xmit 255-91, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_342624:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_342624

	xmit 64, IVL
	xmit 255-51, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_3426:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_3426

	xmit ITER_COUNT, IVL
	xmit 7, AUX
	and LIV7, AUX
	nzt AUX, do_not_inc
	xmit 1, AUX
	add AUX, AUX
do_not_inc:
	xmit 48, R2
	add R2, AUX
	xmit 255, R2
	xor R2, AUX

	xmit 64, IVL
	move AUX, RIV7
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_13513516:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_13513516

	xmit 64, IVL
	xmit 255-109, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_34261:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_34261

	xmit 64, IVL
	xmit 255-0, R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_34:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_34

	xmit 64, IVL
	xmit 255-'#', R13
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_31541522:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_31541522

mandel_calc_loop_end:
	; End col loop
	xmit CURR_COL, IVL
	move LIV7, AUX
	xmit 1, R11
	add R11, R11
	move R11, LIV7
	xmit M_WIDTH, AUX
	xor R11, R11
	nzt R11, mandel_loop_cols_cont
	jmp mandel_loop_cols_end
mandel_loop_cols_cont:
	jmp mandel_loop_cols
mandel_loop_cols_end:
	; End row loop
	xmit 2, R1
	jmp newl
newl_ret_2:
	xmit CURR_ROW, IVL
	xmit 255, AUX
	add LIV7, AUX
	move AUX, LIV7
	xmit 255, R11
	xor R11, AUX
	nzt AUX, mandel_loop_rows_cont
	jmp mandel_loop_rows_end
mandel_loop_rows_cont:
	jmp mandel_loop_rows
mandel_loop_rows_end:

	xmit MAN_XX, IVL
	xmit 255-27, R1
	move R1, LIV7
	xmit MAN_XX+1, IVL
	xmit 255-91, R1
	move R1, LIV7
	xmit MAN_XX+2, IVL
	xmit 255-48, R1
	move R1, LIV7
	xmit MAN_XX+3, IVL
	xmit 255-109, R1
	move R1, LIV7
	xmit MAN_XX+4, IVL
	xmit 255-68, R1
	move R1, LIV7
	xmit MAN_XX+5, IVL
	xmit 255-'D', R1
	move R1, LIV7
	xmit MAN_XX+6, IVL
	xmit 255-'o', R1
	move R1, LIV7
	xmit MAN_XX+7, IVL
	xmit 255-'n', R1
	move R1, LIV7
	xmit MAN_XX+8, IVL
	xmit 255-'e', R1
	move R1, LIV7
	xmit MAN_XX+9, IVL
	xmit 255-'.', R1
	move R1, LIV7
	xmit MAN_XX+10, IVL
	xmit 0, LIV7

	xmit MAN_XX, R1
done_loop:
	move R1, R7
	xmit 1, AUX
	add R1, R1
	move LIV7, R14
	nzt R14, done_loop_cont
	jmp done_loop_over
done_loop_cont:
	xmit 64, IVL
	move R14, RIV7
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit UART_DEL_TIME, AUX
	xmit 255, R2
uart_del_31135414:
	nop
	nop
	add R2, AUX
	nzt AUX, uart_del_31135414
	jmp done_loop
done_loop_over:

	xmit 3, R1
	jmp newl
newl_ret_3:
	nop
halt_loop:
	xmit 128, IVL
	move RIV4, R1
	xmit 255, AUX
	xor R1, R11
	xmit 1, AUX
	and R11, R1
	nzt R1, restart
	move R3, R3 ; Emulator breakpoint, NOP on real CPU
	jmp halt_loop
restart:
	jmp 0

	nop
	nop
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
	jmp newl_return

	nop
	nop
mul_32x32_signed:
	xmit MSIGN, IVL
	xmit 0, LIV7
	xmit MIN03, IVL
	move LIV7, R3
	xmit 128, AUX
	and R3, R4
	nzt R4, mul_32x32_neg_a
	jmp mul_32x32_not_neg_a
mul_32x32_neg_a:
	xmit 255, AUX
	xmit MIN00, IVL
	xor LIV7, LIV7
	xmit MIN01, IVL
	xor LIV7, LIV7
	xmit MIN02, IVL
	xor LIV7, LIV7
	xmit MIN03, IVL
	xor LIV7, LIV7

	xmit 1, AUX
	xmit MIN00, IVL
	add LIV7, LIV7
	xmit MIN01, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MIN02, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MIN03, IVL
	move LIV7, AUX
	add R10, LIV7

	xmit MSIGN, IVL
	xmit 1, AUX
	move AUX, LIV7
mul_32x32_not_neg_a:
	xmit MIN13, IVL
	move LIV7, R3
	xmit 128, AUX
	and R3, R5
	nzt R5, mul_32x32_neg_b
	jmp mul_32x32_not_neg_b
mul_32x32_neg_b:
	xmit 255, AUX
	xmit MIN10, IVL
	xor LIV7, LIV7
	xmit MIN11, IVL
	xor LIV7, LIV7
	xmit MIN12, IVL
	xor LIV7, LIV7
	xmit MIN13, IVL
	xor LIV7, LIV7

	xmit 1, AUX
	xmit MIN10, IVL
	add LIV7, LIV7
	xmit MIN11, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MIN12, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MIN13, IVL
	move LIV7, AUX
	add R10, LIV7

	xmit MSIGN, IVL
	xmit 1, AUX
	xor LIV7, R2
	move R2, LIV7
mul_32x32_not_neg_b:
	jmp mul_32x32_start

mul_32x32_unsigned:
	xmit MSIGN, IVL
	xmit 0, R3
	move R3, LIV7
	jmp mul_32x32_start

mul_32x32_start:
	xmit MTEMP1, IVL
	move R1, LIV7
	xmit 0, R1
	xmit MRES3, IVL
	move R1, LIV7
	xmit MRES4, IVL
	move R1, LIV7
	xmit MRES5, IVL
	move R1, LIV7
	xmit MRES6, IVL
	move R1, LIV7
	xmit MRES7, IVL
	move R1, LIV7
	xmit MTEMP2, IVL
	move R1, LIV7
mul_32x32_loop:
	xmit MTEMP2, IVL
	move LIV7, R1
	xmit MIN00, AUX
	add R1, R1
	move R1, R7
	move LIV7, R1
	xmit MTEMP0, IVL
	move R1, LIV7

	xmit MRES1, IVL
	move LIV7, R1
	xmit MRES0, IVL
	move R1, LIV7
	xmit MRES2, IVL
	move LIV7, R1
	xmit MRES1, IVL
	move R1, LIV7
	xmit MRES3, IVL
	move LIV7, R1
	xmit MRES2, IVL
	move R1, LIV7
	xmit MRES4, IVL
	move LIV7, R1
	xmit MRES3, IVL
	move R1, LIV7
	xmit MRES5, IVL
	move LIV7, R1
	xmit MRES4, IVL
	move R1, LIV7
	xmit MRES6, IVL
	move LIV7, R1
	xmit MRES5, IVL
	move R1, LIV7
	xmit MRES7, IVL
	move LIV7, R1
	xmit MRES6, IVL
	move R1, LIV7
	xmit 0, R1
	xmit MRES7, IVL
	move R1, LIV7
	; multiplies a 8-bit number with a 32-bit number with 40-bit result
	; I’ll inline this later
mul_8x32:
	xmit MTEMP0, IVL
	move LIV7, R1
	xmit 0, R2
	move R2, R3
	move R3, R4
	move R4, R5
	move R5, R6
	xmit 128, R11
	xmit MIN10, IVL
	move LIV7, R12
	xmit MIN11, IVL
	move LIV7, R13
	xmit MIN12, IVL
	move LIV7, R14
	xmit MIN13, IVL
	move LIV7, R15
	xmit 0, R16
mul_8x32_loop:
	move R1(1), AUX
	move AUX, R1
	and R11, AUX
	xor R11, AUX
	nzt AUX, mul_8x32_no_carry_cont
	jmp mul_8x32_yes_carry
mul_8x32_no_carry_cont:
	jmp mul_8x32_no_carry
mul_8x32_yes_carry:
	; Add R12 to R2
	move R12, AUX
	add R2, R2
	; Propagate carry
	move R10, AUX
	add R3, R3
	move R10, AUX
	add R4, R4
	move R10, AUX
	add R5, R5
	move R10, AUX
	add R6, R6
	; Add R13 to R3
	move R13, AUX
	add R3, R3
	; Propagate carry
	move R10, AUX
	add R4, R4
	move R10, AUX
	add R5, R5
	move R10, AUX
	add R6, R6
	; Add R14 to R4
	move R14, AUX
	add R4, R4
	; Propagate carry
	move R10, AUX
	add R5, R5
	move R10, AUX
	add R6, R6
	; Add R15 to R5
	move R15, AUX
	add R5, R5
	; Propagate carry
	move R10, AUX
	add R6, R6
	; Add R16 to R6
	move R16, AUX
	add R6, R6
mul_8x32_no_carry:
	move R16, AUX
	add R16, R16
	move R15, AUX
	add R15, R15
	move R10, AUX
	add R16, R16
	move R14, AUX
	add R14, R14
	move R10, AUX
	add R15, R15
	move R13, AUX
	add R13, R13
	move R10, AUX
	add R14, R14
	move R12, AUX
	add R12, R12
	move R10, AUX
	add R13, R13

	xmit 127, AUX
	and R1, R1
	nzt R1, mul_8x32_loop_cont
	jmp mul_8x32_done
mul_8x32_loop_cont:
	jmp mul_8x32_loop
mul_8x32_done:
	; Add result onto MRES3 - MRES7
	; Add R2 to MRES3
	xmit MRES3, IVL
	move R2, AUX
	add LIV7, R2
	move R2, LIV7
	; Propagate Carry
	move R10, AUX
	add R3, R3
	move R10, AUX
	add R4, R4
	move R10, AUX
	add R5, R5
	move R10, AUX
	add R6, R6
	; Add R3 to MRES4
	xmit MRES4, IVL
	move LIV7, AUX
	add R3, R3
	move R3, LIV7
	; Propagate Carry
	move R10, AUX
	add R4, R4
	move R10, AUX
	add R5, R5
	move R10, AUX
	add R6, R6
	; Add R4 to MRES5
	xmit MRES5, IVL
	move LIV7, AUX
	add R4, R4
	move R4, LIV7
	; Propagate Carry
	move R10, AUX
	add R5, R5
	move R10, AUX
	add R6, R6
	; Add R5 to MRES6
	xmit MRES6, IVL
	move LIV7, AUX
	add R5, R5
	move R5, LIV7
	; Propagate Carry
	move R10, AUX
	add R6, R6
	; Add R6 to MRES7
	xmit MRES7, IVL
	move LIV7, AUX
	add R6, R6
	move R6, LIV7
mul_8x32_actually_done:
	xmit MTEMP2, IVL
	xmit 1, AUX
	add LIV7, LIV7
	move LIV7, R1
	xmit 4, AUX
	xor R1, R1
	nzt R1, mul_32x32_loop_cont
	jmp mul_32x32_finished
mul_32x32_loop_cont:
	jmp mul_32x32_loop
mul_32x32_finished:
	xmit MTEMP1, IVL
	move LIV7, R1
	xmit MSIGN, IVL
	nzt LIV7, mul_32x32_res_neg
	jmp mul_32x32_res_not_neg
mul_32x32_res_neg:
	xmit 255, AUX
	xmit MRES0, IVL
	xor LIV7, LIV7
	xmit MRES1, IVL
	xor LIV7, LIV7
	xmit MRES2, IVL
	xor LIV7, LIV7
	xmit MRES3, IVL
	xor LIV7, LIV7
	xmit MRES4, IVL
	xor LIV7, LIV7
	xmit MRES5, IVL
	xor LIV7, LIV7
	xmit MRES6, IVL
	xor LIV7, LIV7
	xmit MRES7, IVL
	xor LIV7, LIV7

	xmit 1, AUX
	xmit MRES0, IVL
	add LIV7, LIV7
	xmit MRES1, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MRES2, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MRES3, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MRES4, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MRES5, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MRES6, IVL
	move LIV7, AUX
	add R10, LIV7
	xmit MRES7, IVL
	move LIV7, AUX
	add R10, LIV7

mul_32x32_res_not_neg:

	jmp mul_32x32_ret

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
