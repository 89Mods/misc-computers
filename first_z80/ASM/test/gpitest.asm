	org 0
code:
	di
	ld sp,34816
	ld b,0
	ld a,b
	ld (18432),a
loop:
	ld a,(18432)
	and 2
	xor 2
	jp z,no_increment
	inc b
	ld a,b
	ld (18432),a
wait_loop:
	nop
 	nop
	ld a,(18432)
	and 2
	xor 2
	jp nz,wait_loop
no_increment:
	nop
	nop
	jp loop
