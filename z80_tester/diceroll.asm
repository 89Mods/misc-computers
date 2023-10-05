mem_start equ 32768
mem_len equ 32
int_toggle equ mem_start
lfsr equ mem_start+1
counter equ mem_start+3
rand equ mem_start+5
temp equ mem_start+7
btn equ mem_start+8

	org 0
start:
	nop
	di
	im 1
	ei
	ld sp, mem_start+mem_len-1
	ld a, (hex_digits)
	out 0, a
	jp entry

	org 0038H
int:
	exx
	ex af,af'
	jp int_handler
	org 0066H
nmi:
	exx
	ex af,af'
	jp nmi_handler

entry:
	; Fill RAM with 0s
	ld hl, mem_start
	ld de, mem_start+1
	ld bc, mem_len-1
	ld (hl), 0
	ldir
	
	ld hl, 776AH
	ld (lfsr), hl
dice_begin:
	ld de, 0
loop:
	call rng_next
	
	ld a, (btn)
	ld b, a
	in a, 0
	and 1
	ld (btn), a
	jp nz, continue_loop
	ld a, b
	cp 0
	jp nz, begin_roll
continue_loop:
	inc de
	ld a, d
	cp 20
	jp nz, loop
	ld de, 0
	ld a, (int_toggle)
	and 128
	jp z, loop

begin_roll:
	ld de, 1
roll_loop:
	call rng_next
	rra
	rra
	and 15
	ld (temp), a
	ld bc, de
roll_delay:
	ld a, 12
roll_delay_inner:
	dec a
	jp nz, roll_delay_inner
	
	dec bc
	ld a, c
	cp 0
	jp nz, roll_delay
	ld a, b
	cp 0
	jp nz, roll_delay
	
	ld a, (temp)
	add hex_digits&0xFF
	ld l, a
	xor a
	adc hex_digits>>8
	ld h, a
	ld a, (hl)
	ld (temp), a
	out 0, a
	
	inc de
	inc de
	inc de
	inc de
	
	ld a, e
	cp 1
	jp nz, roll_loop
	ld a, d
	cp 2
	jp nz, roll_loop


	ld a, (temp)
	or 1
	call delay
	call delay
	call delay
	call delay
	out 0, a
	call delay
	call delay

	xor 1
	out 0, a
	jp dice_begin
	
delay:
	push de
	ld e, 255
delay_loop:
	ld d, 8
delay_loop_inner:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec d
	jp nz, delay_loop_inner
	dec e
	jp nz, delay_loop
	pop de
	ret

	; Updates a LFSR and counter used to generate random numbers
	; Next 16-bit random number in (rand)
	; a also contains a 8-bit random number
rng_next:
	push bc
	push de
	ld bc, (counter)
	inc bc
	ld (counter), bc
	
	ld hl, (lfsr)
	ld de, hl
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	xor e
	ld l, a
	ld a, h
	xor d
	ld h, a
	
	ld de, hl
	ld h, l
	sla h
	ld a, h
	xor d
	ld h, a
	ld l, e
	
	ld de, hl
	ld l, h
	srl l
	srl l
	srl l
	srl l
	srl l
	ld a, l
	xor e
	ld l, a
	ld h, d
	
	ld (lfsr), hl
	
	add hl, bc
	ld (rand), hl
	
	ld a, l
	and 15
	ld b, a
	ld a, h
	and 240
	or b

	pop de
	pop bc
	ret

int_handler:
	ld hl, int_toggle
	ld a, (hl)
	cpl
	ld (hl), a
	call debounce
	;Do not change
	ex af,af'
	exx
	ei
	reti

nmi_handler:
	ld hl, int_toggle
	ld a, (hl)
	cpl
	ld (hl), a
	call debounce
	;Do not change
	ex af,af'
	exx
	retn

	; Actually just a really short delay loop
debounce:
	ld a, 32
debounce_loop:
	nop
	dec a
	ret z
	jp debounce_loop

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
