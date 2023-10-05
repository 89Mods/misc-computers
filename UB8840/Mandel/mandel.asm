SP equ 0xFF
RP equ 0xFD
P01M equ 0xF8
P3M equ 0xF7
P2M equ 0xF6
IPR equ 0xF9
IRQ equ 0xFA
IMR equ 0xFB
FLAGS equ 0xFC
P0 equ 0x00
P1 equ 0x01
P2 equ 0x02
P3 equ 0x03
PRE0 equ 0xF5
T0 equ 0xF4
TMR equ 0xF1
SIO equ 0xF0

RB0 equ 0
RB1 equ 16
RB2 equ 32
RB3 equ 48 ; Do not use! Stack lives here!
RB4 equ 64
RB5 equ 80
RB6 equ 96
RB7 equ 112

; Reg banks 5,6 are for subroutines

ERF0 equ 0
ERFF equ 15
ERFC equ 12
; SPI in ERFC
SCON equ 2
SDAT equ 1
SCOMP equ 0
; ERFF regs
WDTMR equ 15
SMR equ 11
PCON equ 0

; RB0
C1 equ 4
C2 equ 8
C3 equ 12

; RB1
C4 equ 16
C_IM equ 20
C_RE equ 24
MAN_X equ 28

; RB2
MAN_XX equ 32
MAN_YY equ 36

; RB3
; Stack lives here

; RB4
; Main scratch space

; RB5
MIN00 equ 80
MIN01 equ 81
MIN02 equ 82
MIN03 equ 83
MIN10 equ 84
MIN11 equ 85
MIN12 equ 86
MIN13 equ 87

; RB6
MRES0 equ 96
MRES1 equ 97
MRES2 equ 98
MRES3 equ 99
MRES4 equ 100
MRES5 equ 101
MRES6 equ 102
MRES7 equ 103
REM0 equ 104
REM1 equ 105

; RB7
; More scratch space?

; Mandel vars
M_WIDTH equ 238
M_HEIGHT equ 48
W_D2 equ 119
H_D2 equ 24

ZOOM      equ 16000000
RE        equ 0
IMAG      equ 0
MAX_ITERS equ 256

	org 0
	dw int_handler
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
start:
	nop
	srp #RB4
	ld R5, #200
abcd:
	nop
	djnz R5, abcd
	ld RP, #ERFF
	and SMR, #0b11111100
	ld IPR, #0b00010011
	ld IMR, #0b00000001
	ld IRQ, #0
	ei
	
	srp #RB0
	ld P01M, #0b00000100
	ld P3M, #0b01000001
	ld RP, #ERFF
	ld T0, #2
	ld PRE0, #0x0D
	or TMR, #3
	ld R5, IRQ
	and R5, 239
	ld IRQ, R5
	
	srp #RB0
	ld SP, #63
	ld SP-1, #0
	ld R0, #0 ; P0
	
	srp #RB4
	ld R5, #200
begin:
	nop
	djnz R5, begin
mandel_calc_constants_c1:
	inc R5
	; res = 4 / width
	clr MIN00
	clr MIN01
	clr MIN02
	ld MIN03, #4
	clr MIN10
	clr MIN11
	clr MIN12
	ld MIN13, #M_WIDTH
	call div_fixed
	; C1 = res * ZOOM
	ld MIN00, MRES0
	ld MIN01, MRES1
	ld MIN02, MRES2
	ld MIN03, MRES3
	ld MIN10, #ZOOM&255
	ld MIN11, #(ZOOM>>8)&255
	ld MIN12, #(ZOOM>>16)&255
	ld MIN13, #(ZOOM>>24)&255
	call mul_fixed
	ld C1+0, MRES0
	ld C1+1, MRES1
	ld C1+2, MRES2
	ld C1+3, MRES3
	; C2 = W_D2 * C1
	clr MIN00
	clr MIN01
	clr MIN02
	ld MIN03, #W_D2
	ld MIN10, MRES0
	ld MIN11, MRES1
	ld MIN12, MRES2
	ld MIN13, MRES3
	call mul_fixed
	ld C2+0, MRES0
	ld C2+1, MRES1
	ld C2+2, MRES2
	ld C2+3, MRES3
	cp R5, #1
	jp z, mandel_calc_constants_c1
mandel_calc_constants_c4:
	; res = 2 / height
	clr MIN00
	clr MIN01
	clr MIN02
	ld MIN03, #2
	clr MIN10
	clr MIN11
	clr MIN12
	ld MIN13, #M_HEIGHT
	call div_fixed
	; C3 = res * ZOOM
	ld MIN00, MRES0
	ld MIN01, MRES1
	ld MIN02, MRES2
	ld MIN03, MRES3
	ld MIN10, #ZOOM&255
	ld MIN11, #(ZOOM>>8)&255
	ld MIN12, #(ZOOM>>16)&255
	ld MIN13, #(ZOOM>>24)&255
	call mul_fixed
	ld C3+0, MRES0
	ld C3+1, MRES1
	ld C3+2, MRES2
	ld C3+3, MRES3
	; C4 = H_D2 * C1
	clr MIN00
	clr MIN01
	clr MIN02
	ld MIN03, #H_D2
	ld MIN10, MRES0
	ld MIN11, MRES1
	ld MIN12, MRES2
	ld MIN13, MRES3
	call mul_fixed
	ld C4+0, MRES0
	ld C4+1, MRES1
	ld C4+2, MRES2
	ld C4+3, MRES3
	
	ld SIO, #10
	call uart_delay
	ld SIO, #13
	call uart_delay
	ld SIO, #10
	call uart_delay
	ld SIO, #13
	call uart_delay
	clr R8
	ld R7, #C1
cs_print_loop:
	ld SIO, #'C'
	call uart_delay
	ld R1, R8
	add R1, #'1'
	ld SIO, R1
	call uart_delay
	ld SIO, #':'
	call uart_delay
	ld SIO, #' '
	call uart_delay
	ld R1, @R7
	inc R7
	ld R2, @R7
	inc R7
	ld R3, @R7
	inc R7
	ld R4, @R7
	inc R7
	call print_fixed
	
	ld SIO, #10
	call uart_delay
	ld SIO, #13
	call uart_delay
	inc R8
	cp R8, #4
	jp mi, cs_print_loop
	
	ld R15, #M_HEIGHT-1
mandel_loop_rows:
	srp #RB4
	; res = row * C3
	clr MIN00
	clr MIN01
	clr MIN02
	ld MIN03, R15
	ld MIN10, C3+0
	ld MIN11, C3+1
	ld MIN12, C3+2
	ld MIN13, C3+3
	call mul_fixed
	; regs = res + IMAG
	ld R0, MRES0
	ld R1, MRES1
	ld R2, MRES2
	ld R3, MRES3
	add R0, #IMAG&255
	adc R1, #(IMAG>>8)&255
	adc R2, #(IMAG>>16)&255
	adc R3, #(IMAG>>24)&255
	; C_IM = regs - C4
	sub R0, C4+0
	sbc R1, C4+1
	sbc R2, C4+2
	sbc R3, C4+3
	ld C_IM+0, R0
	ld C_IM+1, R1
	ld C_IM+2, R2
	ld C_IM+3, R3
	; Blink LED
	ld R0, R15
	and R0, #1
	ld P0, R0
	
	clr R14
mandel_loop_cols:
	; res = col * C1
	clr MIN00
	clr MIN01
	clr MIN02
	ld MIN03, R14
	ld MIN10, C1+0
	ld MIN11, C1+1
	ld MIN12, C1+2
	ld MIN13, C1+3
	call mul_fixed_unsigned
	; regs = res + RE
	ld R10, MRES0
	ld R11, MRES1
	ld R12, MRES2
	ld R13, MRES3
	add R10, #RE&255
	adc R11, #(RE>>8)&255
	adc R12, #(RE>>16)&255
	adc R13, #(RE>>24)&255
	; MAN_X = regs(C_RE) - C2
	sub R10, C2+0
	sbc R11, C2+1
	sbc R12, C2+2
	sbc R13, C2+3
	ld MAN_X+0, R10
	ld MAN_X+1, R11
	ld MAN_X+2, R12
	ld MAN_X+3, R13
	
	; regs(Y) = C_IM
	ld R4, C_IM+0
	ld R5, C_IM+1
	ld R8, C_IM+2
	ld R9, C_IM+3
	
	clr R6
	clr R7
mandel_calc_loop:
	; YY = regs(Y) * regs(Y)
	ld MIN00, R4
	ld MIN10, R4
	ld MIN01, R5
	ld MIN11, R5
	ld MIN02, R8
	ld MIN12, R8
	ld MIN03, R9
	ld MIN13, R9
	call mul_fixed
	ld MAN_YY+0, MRES0
	ld MAN_YY+1, MRES1
	ld MAN_YY+2, MRES2
	ld MAN_YY+3, MRES3
	
	; res = X * Y
	ld MIN00, R4
	ld MIN01, R5
	ld MIN02, R8
	ld MIN03, R9
	ld MIN10, MAN_X+0
	ld MIN11, MAN_X+1
	ld MIN12, MAN_X+2
	ld MIN13, MAN_X+3
	call mul_fixed
	
	; regs = res + res
	ld R4, MRES0
	ld R5, MRES1
	ld R8, MRES2
	ld R9, MRES3
	add R4, R4
	adc R5, R5
	adc R8, R8
	adc R9, R9
	
	; regs(Y) = regs + C_IM
	add R4, C_IM+0
	adc R5, C_IM+1
	adc R8, C_IM+2
	adc R9, C_IM+3
	
	; XX = regs = X * X
	ld R0, MAN_X+0
	ld R1, MAN_X+1
	ld R2, MAN_X+2
	ld R3, MAN_X+3
	ld MIN00, R0
	ld MIN10, R0
	ld MIN01, R1
	ld MIN11, R1
	ld MIN02, R2
	ld MIN12, R2
	ld MIN03, R3
	ld MIN13, R3
	call mul_fixed
	ld R0, MRES0
	ld R1, MRES1
	ld R2, MRES2
	ld R3, MRES3
	ld MAN_XX+0, R0
	ld MAN_XX+1, R1
	ld MAN_XX+2, R2
	ld MAN_XX+3, R3
	
	; regs = regs - YY
	sub R0, MAN_YY+0
	sbc R1, MAN_YY+1
	sbc R2, MAN_YY+2
	sbc R3, MAN_YY+3
	
	; X = regs + regs(C_RE)
	add R0, R10
	adc R1, R11
	adc R2, R12
	adc R3, R13
	ld MAN_X+0, R0
	ld MAN_X+1, R1
	ld MAN_X+2, R2
	ld MAN_X+3, R3
	
	; check if XX + YY <= 4
	ld R0, MAN_XX+0
	ld R1, MAN_XX+1
	ld R2, MAN_XX+2
	ld R3, MAN_XX+3
	add R0, MAN_YY+0
	adc R1, MAN_YY+1
	adc R2, MAN_YY+2
	adc R3, MAN_YY+3
	cp R3, #4
	jp pl, mandel_calc_loop_overflow
	
	incw RR6
	cp R7, #MAX_ITERS&255
	jp nz, mandel_calc_loop
	cp R6, #MAX_ITERS>>8
	jp nz, mandel_calc_loop
mandel_calc_loop_max_iters:
	ld SIO, #' '
	call uart_delay
	jp mandel_calc_loop_exit
mandel_calc_loop_overflow:
	ld R0, R7
	and R0, #7
	add R0, R0
	add R0, R0
	add R0, R0
	ld R7, #mandel_colors&0xFF
	ld R6, #mandel_colors>>8
	add R7, R0
	adc R6, #0
print_loop1:
	incw RR6
	ldc R1, @RR6
	cp R1, #33
	jp z, print_loop1_exit
	ld SIO, R1
	call uart_delay
	jp print_loop1
print_loop1_exit:
	ld SIO, #'#'
	call uart_delay
mandel_calc_loop_exit:
	
	inc R14
	cp R14, #M_WIDTH
	jp nz, mandel_loop_cols
debug1:
	ld SIO, #13
	call uart_delay
	ld SIO, #10
	call uart_delay
	
	dec R15
	cp R15, #255
	jp nz, mandel_loop_rows
	
	ld R7, #mandel_color_reset&0xFF
	ld R6, #mandel_color_reset>>8
print_loop2:
	ldc R1, @RR6
	cp R1, #0
	jp z, print_loop2_exit
	incw RR6
	ld SIO, R1
	call uart_delay
	jp print_loop2
print_loop2_exit:
	
	clr P0
halt:
	nop
	nop
	nop
	nop
	nop
	jp halt

uart_delay:
	push R5
uart_delay_loop:
	ld R5, IRQ
	and R5, #16
	jr z, uart_delay_loop
	ld R5, IRQ
	and R5, #239
	ld IRQ, R5
	pop R5
	ret

div_16x16:
	push RP
	srp #RB5
	
	ld R8, #0
	ld R9, R8
	ld R10, R9
	ld R11, R10
	ld R15, #16
div_16x16_loop:
	add R10, R10
	adc R11, R11
	add R0, R0
	adc R1, R1
	adc R8, R8
	adc R9, R9
	ld R13, R9
	cp R8, R4
	sbc R9, R5
	ld R9, R13
	jr c, div_16x16_continue
	or R10, #1
	sub R8, R4
	sbc R9, R5
div_16x16_continue:
	djnz R15, div_16x16_loop
	ld MRES0, R10
	ld MRES1, R11
	ld REM0, R8
	ld REM1, R9
	pop RP
	ret

print_hex:
	;Back-up shit
	push R1
	push R6
	push R7
	push 0xFC
	
	;Most-significant nibble
	push R1
	ld R7, #hex_chars&0xFF
	ld R6, #hex_chars>>8
	swap R1
	and R1, #15
	add R7, R1
	adc R6, #0
	ldc R1, @RR6
	ld SIO, R1
	
	;Last-significant nibble
	pop R1
	and R1, #15
	ld R7, #hex_chars&0xFF
	ld R6, #hex_chars>>8
	add R7, R1
	adc R6, #0
	ldc R1, @RR6
	call uart_delay
	ld SIO, R1
	
	;Return
	pop 0xFC
	pop R7
	pop R6
	pop R1
	jp uart_delay

mul_32x32_unsigned:
	push RP
	srp #RB5
	clr R10
	jp mul_32x32_not_neg_2
mul_32x32_signed:
	push RP
	srp #RB5
	
	clr R10
	clr R11
	cp R3, #0
	jr pl, mul_32x32_not_neg_1
	com R0
	add R0, #1
	com R1
	adc R1, R11
	com R2
	adc R2, R11
	com R3
	adc R3, R11
	inc R10
mul_32x32_not_neg_1:
	cp R7, #0
	jr pl, mul_32x32_not_neg_2
	com R4
	add R4, #1
	com R5
	adc R5, R11
	com R6
	adc R6, R11
	com R7
	adc R7, R11
	inc R10
mul_32x32_not_neg_2:
	push R10
	
	clr MRES0
	clr MRES1
	clr MRES2
	clr MRES3
	clr MRES4
	clr MRES5
	clr MRES6
	clr MRES7
	ld R9, #5
	xor R10, R10
mul_32x32_loop:
	dec R9
	jr z, mul_32x32_end
	ld MRES0, MRES1
	ld MRES1, MRES2
	ld MRES2, MRES3
	ld MRES3, MRES4
	ld MRES4, MRES5
	ld MRES5, MRES6
	ld MRES6, MRES7
	clr MRES7
	ld R8, MIN00(R10)
	inc R10
	and R8, R8
	jr z, mul_32x32_loop
	call mul_8x32
	jr mul_32x32_loop
mul_32x32_end:
	pop R10
	and R10, #1
	jr z, mul_32x32_not_neg_res
	clr R11
	com MRES0
	add MRES0, #1
	com MRES1
	adc MRES1, R11
	com MRES2
	adc MRES2, R11
	com MRES3
	adc MRES3, R11
	com MRES4
	adc MRES4, R11
	com MRES5
	adc MRES5, R11
	com MRES6
	adc MRES6, R11
	com MRES7
	adc MRES7, R11
mul_32x32_not_neg_res:
	pop RP
	ret

	; Muls R8 by MIN1x, adds result onto MRES3 - MRES7
mul_8x32:
	ld R11, R4
	ld R12, R5
	ld R13, R6
	ld R14, R7
	clr R15
	rcf
mul_8x32_loop:
	rrc R8
	jr nc, mul_8x32_no_carr
	add MRES3, R11
	adc MRES4, R12
	adc MRES5, R13
	adc MRES6, R14
	adc MRES7, R15
mul_8x32_no_carr:
	rlc R11
	rlc R12
	rlc R13
	rlc R14
	rlc R15
	and R8, R8
	jr nz, mul_8x32_loop
mul_8x32_finished:
	ret

mul_fixed:
	call mul_32x32_signed
	ld MRES0, MRES3
	ld MRES1, MRES4
	ld MRES2, MRES5
	ld MRES3, MRES6
	ret

mul_fixed_unsigned:
	call mul_32x32_unsigned
	ld MRES0, MRES3
	ld MRES1, MRES4
	ld MRES2, MRES5
	ld MRES3, MRES6
	ret

div_fixed:
	push RP
	srp #RB5
	
	clr R9
	clr R10
	clr R11
	clr R12
	clr MRES0
	clr MRES1
	clr MRES2
	clr MRES3
	ld R14, #56
div_fixed_loop:
	add MRES0, MRES0
	adc MRES1, MRES1
	adc MRES2, MRES2
	adc MRES3, MRES3
	
	add R0, R0
	adc R1, R1
	adc R2, R2
	adc R3, R3
	adc R8, R8
	adc R9, R9
	adc R10, R10
	adc R11, R11
	adc R12, R12
	
	ld R13, R8
	sub R8, R4
	ld R8, R13
	ld R13, R9
	sbc R9, R5
	ld R9, R13
	ld R13, R10
	sbc R10, R6
	ld R10, R13
	ld R13, R11
	sbc R11, R7
	ld R11, R13
	ld R13, R12
	sbc R12, #0
	ld R12, R13
	jr mi, div_fixed_continue
	sub R8, R4
	sbc R9, R5
	sbc R10, R6
	sbc R11, R7
	sbc R12, #0
	inc MRES0
div_fixed_continue:
	djnz R14, div_fixed_loop
	
	pop RP
	ret

printint16_divs:
	dw 1, 10, 100, 1000, 10000
	; Number in R1, R2
printint16:
	push R4
	push R5
	push R6
	cp R2, #0
	jr pl, printint16_no_neg
	com R1
	add R1, #1
	com R2
	adc R2, #0
	ld SIO, #'-'
	call uart_delay
printint16_no_neg:
	ld MIN00, R1
	ld MIN01, R2
	ld R1, #5
	clr R2
print16_loop:
	ld R5, R1
	dec R5
	add R5, R5
	add R5, #printint16_divs&0xFF
	ld R4, #printint16_divs>>8
	adc R4, #0
	ldc R6, @RR4
	ld MIN11, R6
	incw RR4
	ldc R6, @RR4
	ld MIN10, R6
	call div_16x16
	ld MIN00, REM0
	ld MIN01, REM1
	ld R4, MRES0
	cp R2, #0
	jr ne, print16_put_num
	cp R4, #0
	jr ne, print16_put_num
	cp R1, #1
	jr ne, print16_no_put_num
print16_put_num:
	inc R2
	add R4, #'0'
	ld SIO, R4
	call uart_delay
print16_no_put_num:
	djnz R1, print16_loop
	pop R6
	pop R5
	pop R4
	ret

	; Number in R1, R2, R3, R4
print_fixed:
	push R5
	push R6
	cp R4, #0
	jr pl, print_fixed_no_neg
	com R1
	add R1, #1
	com R2
	adc R2, #0
	com R3
	adc R3, #0
	com R4
	adc R4, #0
	ld SIO, #'-'
	call uart_delay
print_fixed_no_neg:
	ld R5, R1
	ld R6, R2
	ld R1, R4
	clr R2
	call printint16
	ld SIO, #'.'
	call uart_delay
	ld MIN00, R5
	ld MIN01, R6
	ld MIN02, R3
	ld MIN03, #0
	ld MIN10, #0
	ld MIN11, #0
	ld MIN12, #0
	ld MIN13, #10
	ld R5, #6
print_fixed_loop:
	call mul_fixed
	ld MIN00, MRES0
	ld MIN01, MRES1
	ld MIN02, MRES2
	ld MIN03, #0
	ld R6, MRES3
	add R6, #'0'
	ld SIO, R6
	call uart_delay
	djnz R5, print_fixed_loop
	pop R6
	pop R5
	ret

int_handler:
	nop
	nop
	iret

hex_chars:
	db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
mandel_colors:
	db 33,27,91,51,49,109,0,33
	db 33,27,91,51,49,109,0,33
	db 33,27,91,51,50,109,0,33
	db 33,27,91,51,51,109,0,33
	db 33,27,91,51,52,109,0,33
	db 33,27,91,51,53,109,0,33
	db 33,27,91,51,54,109,0,33
	db 33,27,91,51,55,109,0,33
mandel_color_reset:
	db 27,91,48,109
	db 'Done.'
	db 0x0D
	db 0x0A
	db 0
	end
