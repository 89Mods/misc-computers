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
RB3 equ 48
RB4 equ 64
RB5 equ 80
RB6 equ 96
RB7 equ 112
RB8 equ 128
RB9 equ 144
RB10 equ 160
RB11 equ 176
RB12 equ 192
RB13 equ 208
RB14 equ 224
RB15 equ 240
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
	org 0
	dw int_handler
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
start:
	ld RP, #RB0
	
	; Full-speed clock
	ld RP, ERFF
	and SMR, #0b11111100
	
	; Interrupt setup
	; IPR
	ld IPR, #0b00010011
	; IMR
	ld IMR, #0b00000001
	; IRQ
	ld IRQ, #0
	ei
	
	; Set up UART for ~9600 bps @ 8MHz XTAL
	; Also set up P3
	ld RP, #RB0
	ld P01M, #0b00000100
	ld P3M, #0b01000001
	ld RP, ERFF
	ld T0, #7
	ld PRE0, #5
	or TMR, #3
	; Initially clear serial write interrupt request
	ld R5, IRQ
	and R5, 239
	ld IRQ, R5
	
	; Stack setup
	ld RP, #RB0
	ld SP, #64
	ld 0xFE, #0
	
	ld RP, #RB1
	ld 88, #0
	ld P0, #255
loop:
	ld R4, #218
	call long_delay
	ld P0, #0
	ld R4, #218
	call long_delay
	ld P0, #255
	
	inc 88
	ld R1, 88
	call print_hex
	
	jp loop
	
delay:
	push R5
	ld R5, #255
delay_loop:
	nop
	nop
	nop
	nop
	djnz R5, delay_loop
	pop R5
	ret

	; Delay length in R4
long_delay:
	push R4
	nop
long_delay_loop:
	nop
	call delay
	call delay
	nop
	djnz R4, long_delay_loop
	pop R4
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
	ld R6, #0xFC
	push @R6
	
	;Most-significant nibble
	push R1
	ld R7, #hex_chars&0xFF
	ld R6, #hex_chars>>8
	rr R1
	rr R1
	rr R1
	rr R1
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
	ld R6, #0xFC
	pop @R6
	pop R7
	pop R6
	pop R1
	jp uart_delay

int_handler:
	nop
	iret

hex_chars:
	db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
