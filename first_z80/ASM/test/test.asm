	org 0
code:
	ld de,text
	ld c,0
print_loop:
	ld a,(de)
	ld (24576),a
	inc de
	inc c
	ld a,c
	sub text_end-text
	jp nz,print_loop
	ld hl,16384
delay_loop:
	nop
	nop
	nop
	dec hl
	ld a,h
	sub 1
	add 1
	jp nz,delay_loop
	jp code
	
data:
text:
	db "Thorinair and Talos are both mega cuties!"
	db &D
	db &A
text_end:
	db 0
