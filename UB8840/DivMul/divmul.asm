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
RB7 equ 112 ; Special purpose regs only in here

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

MIN00 equ 80
MIN01 equ 81
MIN02 equ 82
MIN03 equ 83
MIN10 equ 84
MIN11 equ 85
MIN12 equ 86
MIN13 equ 87

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

TEMP0 equ 70
TEMP1 equ 71
TEMP2 equ 72
TEMP3 equ 73

AGAIN equ 127

	org 0
	dw int_handler
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
start:
	srp #RB0
	ld AGAIN, #0
	
	; Full-speed clock
	ld RP, #ERFF
	and SMR, #0b11111100
	
	; Interrupt setup
	; IPR
	ld IPR, #0b00010011
	; IMR
	ld IMR, #0b00000001
	; IRQ
	ld IRQ, #0
	ei
	
	; Set up UART for 9600 bps @ 7.3728MHz XTAL
	; Also set up P3
	srp #RB0
	ld P01M, #0b00000100
	ld P3M, #0b01000001
	ld RP, #ERFF
	ld T0, #2
	ld PRE0, #0x0D
	or TMR, #3
	; Initially clear serial write interrupt request
	ld R5, IRQ
	and R5, 239
	ld IRQ, R5
	
	; Stack setup
	srp #RB0
	ld SP, #63
	ld 0xFE, #0
	
aaaa:
	srp #RB1
	ld P0, #0
	
	ld R6, #mulvals_8x8>>8
	ld R7, #mulvals_8x8&0xFF
test_loop_1:
	ldc R5, @RR6
	cp R5, #0
	jr z, test_loop_1_end
	ld R1, R5
	ld MIN00, R1
	call print_hex
	ld SIO, #'*'
	call uart_delay
	incw RR6
	ldc R1, @RR6
	ld MIN10, R1
	call print_hex
	ld SIO, #'='
	call uart_delay
	call mul_8x8
	ld R1, MRES1
	call print_hex
	ld R1, MRES0
	call print_hex
	call newl
	jr test_loop_1
	
test_loop_1_end:
	ld R6, #mulvals_16x16>>8
	ld R7, #mulvals_16x16&0xFF
test_loop_2:
	ldc R5, @RR6
	cp R5, #0
	jr z, test_loop_2_end
	incw RR6
	ldc R5, @RR6
	ld MIN01, R5
	ld R1, R5
	call print_hex
	incw RR6
	ldc R5, @RR6
	ld MIN00, R5
	ld R1, R5
	call print_hex
	ld SIO, #'*'
	call uart_delay
	incw RR6
	ldc R5, @RR6
	ld MIN11, R5
	ld R1, R5
	call print_hex
	incw RR6
	ldc R5, @RR6
	ld MIN10, R5
	ld R1, R5
	call print_hex
	ld SIO, #'='
	call uart_delay
	call mul_16x16
	ld R1, MRES3
	call print_hex
	ld R1, MRES2
	call print_hex
	ld R1, MRES1
	call print_hex
	ld R1, MRES0
	call print_hex
	call newl
	jr test_loop_2
	
test_loop_2_end:

	ld R6, #divvals_8x8>>8
	ld R7, #divvals_8x8&0xFF
test_loop_3:
	ldc R5, @RR6
	cp R5, #255
	jr z, test_loop_3_end
	ld R1, R5
	ld MIN00, R1
	call print_hex
	ld SIO, #'/'
	call uart_delay
	incw RR6
	ldc R1, @RR6
	ld MIN10, R1
	call print_hex
	ld SIO, #'='
	call uart_delay
	call div_8x8
	ld R1, MRES0
	call print_hex
	ld SIO, #' '
	call uart_delay
	ld SIO, #'R'
	call uart_delay
	ld SIO, #':'
	call uart_delay
	ld SIO, #' '
	call uart_delay
	ld R1, REM0
	call print_hex
	call newl
	jr test_loop_3
	
test_loop_3_end:
	ld R6, #divvals_16x16>>8
	ld R7, #divvals_16x16&0xFF
test_loop_4:
	ldc R5, @RR6
	cp R5, #0
	jr z, test_loop_4_end
	incw RR6
	ldc R5, @RR6
	ld MIN01, R5
	ld R1, R5
	call print_hex
	incw RR6
	ldc R5, @RR6
	ld MIN00, R5
	ld R1, R5
	call print_hex
	ld SIO, #'/'
	call uart_delay
	incw RR6
	ldc R5, @RR6
	ld MIN11, R5
	ld R1, R5
	call print_hex
	incw RR6
	ldc R5, @RR6
	incw RR6
	ld MIN10, R5
	ld R1, R5
	call print_hex
	ld SIO, #'='
	call uart_delay
	call div_16x16
	ld R1, MRES1
	call print_hex
	ld R1, MRES0
	call print_hex
	ld SIO, #' '
	call uart_delay
	ld SIO, #'R'
	call uart_delay
	ld SIO, #':'
	call uart_delay
	ld SIO, #' '
	call uart_delay
	ld R1, REM1
	call print_hex
	ld R1, REM0
	call print_hex
	call newl
	jr test_loop_4
	
test_loop_4_end:
	ld R6, #mulvals_32x32>>8
	ld R7, #mulvals_32x32&0xFF
test_loop_5:
	ldc R5, @RR6
	cp R5, #0
	jr z, test_loop_5_end
	incw RR6
	ldc R1, @RR6
	ld MIN03, R1
	ld TEMP3, R1
	incw RR6
	ldc R1, @RR6
	ld MIN02, R1
	ld TEMP2, R1
	incw RR6
	ldc R1, @RR6
	ld MIN01, R1
	ld TEMP1, R1
	incw RR6
	ldc R1, @RR6
	ld MIN00, R1
	ld TEMP0, R1
	incw RR6
	ldc R1, @RR6
	ld MIN13, R1
	incw RR6
	ldc R1, @RR6
	ld MIN12, R1
	incw RR6
	ldc R1, @RR6
	ld MIN11, R1
	incw RR6
	ldc R1, @RR6
	ld MIN10, R1
	incw RR6
	ld R0, #TEMP0
	ld R1, #4
	call print_hex_signed
	ld SIO, #'*'
	call uart_delay
	ld TEMP3, MIN13
	ld TEMP2, MIN12
	ld TEMP1, MIN11
	ld TEMP0, MIN10
	ld R0, #TEMP0
	ld R1, #4
	call print_hex_signed
	nop
	ld SIO, #'='
	call uart_delay
	call mul_32x32_signed
	nop
	ld R0, #MRES0
	ld R1, #8
	call print_hex_signed
	nop
	call newl
	jr test_loop_5
test_loop_5_end:
	
	call newl
	ld R2, #0
	ld R1, #27
	call printint16
	call newl
	ld R2, #27
	ld R1, #193
	call printint16
	call newl
	ld R2, #100
	ld R1, #0
	call printint16
	call newl
	ld R2, #240
	ld R1, #111
	call printint16
	call newl
	ld R2, #0
	ld R1, #1
	call printint16
	call newl
	xor R1, R1
	xor R2, R2
	call printint16
	call newl
	ld R2, #255
	ld R1, R2
	call printint16
	call newl
	ld R2, #127
	ld R1, #255
	call printint16
	call newl
	call newl
	
	ld R1, #33
	ld R2, #207
	ld R3, #128
	ld R4, #6
	call print_fixed
	call newl
	ld R1, #0
	ld R2, #0
	ld R3, #0
	ld R4, #0
	call print_fixed
	call newl
	ld R1, #27
	ld R2, #101
	ld R3, #200
	ld R4, #33
	call print_fixed
	call newl
	ld R4, #200
	call print_fixed
	call newl
	call newl
	
	ld R1, #33
	ld R2, #207
	ld R3, #128
	ld R4, #6
	call print_fixed
	ld SIO, #'/'
	call uart_delay
	ld R4, #33
	ld R3, #207
	ld R2, #128
	ld R1, #6
	call print_fixed
	ld SIO, #'='
	call uart_delay
	ld MIN00, #33
	ld MIN01, #207
	ld MIN02, #128
	ld MIN03, #6
	ld MIN13, #33
	ld MIN12, #207
	ld MIN11, #128
	ld MIN10, #6
	call div_fixed
	ld R1, MRES0
	ld R2, MRES1
	ld R3, MRES2
	ld R4, MRES3
	call print_fixed
	call newl
	
	ld R1, #245
	ld R2, #207
	ld R3, #128
	ld R4, #245
	call print_fixed
	ld SIO, #'/'
	call uart_delay
	ld R4, #33
	ld R3, #207
	ld R2, #128
	ld R1, #6
	call print_fixed
	ld SIO, #'='
	call uart_delay
	ld MIN00, #245
	ld MIN01, #207
	ld MIN02, #128
	ld MIN03, #245
	ld MIN13, #33
	ld MIN12, #207
	ld MIN11, #128
	ld MIN10, #6
	call div_fixed
	ld R1, MRES0
	ld R2, MRES1
	ld R3, MRES2
	ld R4, MRES3
	call print_fixed
	call newl
	call newl
	
	srp #RB0
	ld AGAIN, #0
loop:
	ld R0, #3
	nop
	and AGAIN, #1
	jp z, loop
	nop
	call newl
	call newl
	jp aaaa

newl:
	ld SIO, #10
	call uart_delay
	ld SIO, #13
	call uart_delay
	ret

mul_8x8:
	push RP
	srp #RB5
	
	ld R8, #0
	ld R9, R8
	ld R10, R9
	ld R15, R4
	ld R14, R0
	rcf
mul_8x8_loop:
	rrc R0
	jr nc, mul_8x8_no_carr
	add R8, R4
	adc R9, R10
mul_8x8_no_carr:
	rlc R4
	rlc R10
	and R0, R0
	jr nz, mul_8x8_loop
mul_8x8_finished:
	ld MRES0, R8
	ld MRES1, R9
	ld R4, R15
	ld R0, R14
	pop RP
	ret

mul_16x16:
	push RP
	srp #RB5
	
	ld R12,R0
	ld R13,R1
	ld R14, R4
	ld R15, R5
	ld R2, #0
	ld R3, R2
	ld R6, R2
	ld R7, R2
	ld R8, R2
	ld R9, R2
	ld R10, R2
	ld R11, R2
mul_16x16_loop:
	rcf
	rrc R1
	rrc R0
	jr nc, mul_16x16_no_carr
	add R8, R4
	adc R9, R5
	adc R10, R6
	adc R11, R7
mul_16x16_no_carr:
	rlc R4
	rlc R5
	rlc R6
	rlc R7
	ld R15, R1
	or R15, R0
	jr nz, mul_16x16_loop
	ld MRES0, R8
	ld MRES1, R9
	ld MRES2, R10
	ld MRES3, R11
	ld R1, R13
	ld R0, R12
	ld R5, R15
	ld R4, R14
	pop RP
	ret

mul_32x32_signed:
	push RP
	srp #RB5
	
	xor R10, R10
	xor R11, R11
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
	
	xor R9, R9
	ld MRES0, R9
	ld MRES1, R9
	ld MRES2, R9
	ld MRES3, R9
	ld MRES4, R9
	ld MRES5, R9
	ld MRES6, R9
	ld MRES7, R9
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
	ld MRES7, #0
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
	xor R11, R11
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
	xor R15, R15
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

div_fixed:
	push RP
	srp #RB5
	
	xor R15, R15
	xor R11, R11
	cp R3, #0
	jr pl, div_fixed_not_neg_1
	com R0
	add R0, #1
	com R1
	adc R1, R11
	com R2
	adc R2, R11
	com R3
	adc R3, R11
	inc R15
div_fixed_not_neg_1:
	cp R7, #0
	jr pl, div_fixed_not_neg_2
	com R4
	add R4, #1
	com R5
	adc R5, R11
	com R6
	adc R6, R11
	com R7
	adc R7, R11
	inc R15
div_fixed_not_neg_2:
	
	xor R8, R8
	ld R9, R8
	ld R10, R8
	ld R11, R8
	ld R12, R8
	ld MRES0, R8
	ld MRES1, R8
	ld MRES2, R8
	ld MRES3, R8
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
	
	and R15, #1
	jr z, div_fixed_not_neg_res
	xor R11, R11
	com MRES0
	add MRES0, #1
	com MRES1
	adc MRES1, R11
	com MRES2
	adc MRES2, R11
	com MRES3
	adc MRES3, R11
div_fixed_not_neg_res:
	
	pop RP
	ret
	
div_8x8:
	push RP
	srp #RB5
	
	ld R2, #0
	ld R10, R2
	ld R11, #8
div_8x8_loop:
	add R2, R2
	add R0, R0
	adc R10, R10
	cp R10, R4
	jr c, div_8x8_continue
	or R2, #1
	sub R10, R4
div_8x8_continue:
	djnz R11, div_8x8_loop
	ld MRES0, R2
	ld REM0, R10
	pop RP
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

	; Pointer in R0, length in R1
print_hex_signed:
	push R2
	ld R2, R0
	add R2, R1
	dec R2
	ld R2, @R2
	cp R2, #0
	jr pl, print_hex_signed_no_neg
	db 0xDF ; src
	push 0xFC
	ld R3, R0
	ld R4, R0
	add R4, R1
print_hex_signed_inv_loop:
	ld R2, @R3
	com R2
	pop 0xFC
	adc R2, #0
	push 0xFC
	ld @R3, R2
	inc R3
	cp R3, R4
	jr ne, print_hex_signed_inv_loop
	pop 0xFC
	ld SIO, #'-'
	call uart_delay
print_hex_signed_no_neg:
	ld R4, R0
	add R4, R1
	dec R4
print_hex_signed_print_loop:
	ld R1, @R4
	call print_hex
	dec R4
	cp R4, R0
	jr uge, print_hex_signed_print_loop
	pop R2
	ret

uart_wait_for_char:
	push R5
uart_wait_for_char_loop:
	ld R5, IRQ
	and R5, #8
	jr z, uart_wait_for_char_loop
	ld R5, IRQ
	and R5, #247
	ld IRQ, R5
	pop R5
	ret

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
	xor R2, R2
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
	xor R2, R2
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
	ld AGAIN, #1
	nop
	iret

hex_chars:
	db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

mulvals_8x8:
	db 5,6
	db 13,10
	db 27,8
	db 108,13
	db 255,255
	db 12,0
	db 0

mulvals_16x16:
	db 1
	dw 1048
	dw 33
	db 1
	dw 19481
	dw 22768
	db 1
	dw 3
	dw 9
	db 1
	dw 20000
	dw 0
	db 1
	dw 65535
	dw 65535
	db 0

mulvals_32x32:
	db 1
	dw 22
	dw 19481
	dw 0
	dw 1931
	db 1
	dw 60000
	dw 10193
	dw 0
	dw 55
	db 1
	dw 0
	dw 55
	dw 60000
	dw 10193
	db 1
	dw 60000
	dw 10193
	dw 60000
	dw 10193
	db 1
	dw 0
	dw 0
	dw 192
	dw 33
	db 1
	dw 192
	dw 33
	dw 0
	dw 0
	db 1
	dw 30000
	dw 3019
	dw 1939
	dw 99
	db 1
	dw 57680
	dw 0
	dw 1919
	dw 3301
	db 0

divvals_8x8:
	db 200,3
	db 57,8
	db 8,57
	db 3,3
	db 0,7
	db 0,0
	db 10,5
	db 255

divvals_16x16:
	db 1
	dw 1048
	dw 33
	db 1
	dw 27668
	dw 305
	db 1
	dw 333
	dw 0
	db 1
	dw 0
	dw 333
	db 1
	dw 65535
	dw 65535
	db 1
	dw 7688
	dw 3
	db 0
