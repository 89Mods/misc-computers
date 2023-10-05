; 7-seg pinout
; EDCGFABE

mem_start equ 32768
mem_len equ 32
nmi_counter equ mem_start
int_counter equ mem_start+1
	
	org 0
start:
	di
	im 1
	ei
	ld sp, mem_start+mem_len-1
	
	ld a, (hex_digits)
	out 0, a
wait_for_input:
	in a, 0
	and 1
	jp nz, wait_for_input
	ld a, (hex_digits+1)
	out 0, a
	jp past_ints
	
	org 0038H
int:
	exx
	ex af,af'
	ld hl, int_counter
	inc (hl)
	nop
	nop
	nop
	nop
	ex af,af'
	exx
	ei
	reti
	org 0066H
nmi:
	exx
	ex af,af'
	ld hl, nmi_counter
	inc (hl)
	nop
	nop
	nop
	nop
	ex af,af'
	exx
	retn
	
past_ints:
	ld b, 64
delay_loop2:
	ld a, 255
delay_loop1:
	nop
	nop
	nop
	nop
	nop
	nop
	dec a
	jp nz, delay_loop1
	djnz delay_loop2

	; Memory test. First, fill all of RAM with fibonacci numbers
	ld hl, mem_start
	ld a, 1
	ld d, 1
	ld b, mem_len&0xFF
mem_test1:
	ld e, a
	add d
	ld d, e
	
	ld (hl), a
	inc hl
	djnz mem_test1

	; Now generate the fibonacci numbers again, but this time test if the generated numbers equal those in RAM
	ld hl, mem_start
	ld a, 1
	ld d, 1
	ld b, mem_len&0xFF
mem_test2:
	ld e, a
	add d
	ld d, e

	cp (hl)
	jp nz, test_fail
	inc hl
	djnz mem_test2
	
	; Fill RAM with 0s
	ld hl, mem_start
	ld de, mem_start+1
	ld bc, mem_len-1
	ld (hl), 0
	ldir
	
	ld a, (hex_digits+2)
	out 0, a
	ld hl, nmi_counter
	ld a, (hl)
wait_for_nmi:
	cp (hl)
	nop
	nop
	nop
	jp z, wait_for_nmi
	
	ld a, (hex_digits+3)
	out 0, a
	ld hl, int_counter
	ld a, (hl)
wait_for_int:
	cp (hl)
	nop
	nop
	nop
	jp z, wait_for_int
	
	ld a, (hex_digits+4)
	out 0, a
	
	
	; Do a subroutine call
	call delay
	ld a, (hex_digits+5)
	out 0, a
	
loop:
	call delay
	jp loop
	
delay:
	push hl
	ld hl, 32768
delay_loop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec hl
	ld a, l
	cp 0
	jp nz, delay_loop
	ld a, h
	cp 0
	jp nz, delay_loop
	pop hl
	ret
	
	
test_fail:
	ld a, (hex_digits+15)
	out 0, a
	jp test_fail
	
hex_digits:
	db 11101110b
	db 00100010b
	db 11010110b
	db 01110110b
	db 00111010b
	db 01111100b
	db 11111100b
	db 00100110b
	db 11111110b
	db 01111110b
	db 10111110b
	db 11111000b
	db 11001100b
	db 11110010b
	db 11011100b
	db 10011100b
