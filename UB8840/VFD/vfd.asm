SP equ 0xFF
RP equ 0xFD
P0 equ 0x00
P1 equ 0x01
P2 equ 0x02
P3 equ 0x03
PRE0 equ 0xF5
T0 equ 0xF4
TMR equ 0xF1
P01M equ 0xF8
P3M equ 0xF7
P2M equ 0xF6
IPR equ 0xF9
IMR equ 0xFB

RB0 equ 0
RB1 equ 16
RB2 equ 32
RB3 equ 48 ; Stack lives here
RB4 equ 64
RB5 equ 80
RB6 equ 96
RB7 equ 112

ERF0 equ 0
ERFF equ 15
ERFC equ 12
; ERFF regs
WDTMR equ 15
SMR equ 11
PCON equ 0

	org 0
	dw int_handler
	dw int_handler
	dw int_handler
	dw int_handler
	dw int_handler
	dw int_handler
start:
	nop
	ld RP, #ERFF
	and SMR, #0b11111100
	srp #RB0
	ld IPR, #0b00000011
	ld IMR, #0b00010000
	
	srp #RB7
	ld R6, #0
	srp #RB1
	ld P01M, #0b00000100 ; All outputs on Port 0, internal stack
	ld P2M, #0b00011111 ; Outputs for LEDs
	ld P3M, #0b00000001 ; Port 3 all ins (unused), Port 2 as Push-Pull
	ld P0, #0
	ld P1, #0
	ld SP, #63
	ld SP-1, #0
	
	ld T0, #0xFF
	ld PRE0, #0b10101001
	or TMR, #3
	
	ei
main:
	ld P0, #0xFF
	ld P1, #0
	ld P1, #4
	nop
	ld P1, #0
	nop
	ld P1, #2
	ld P1, #6
	nop
	ld P1, #2
	nop
	jp main

int_handler:
	push RP
	srp #RB7
	inc R6
	ld P2, R6
	nop
	nop
	pop RP
	iret
