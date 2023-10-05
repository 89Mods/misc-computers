	org 0
code:
	di
	ld sp,34816
	ld a,0
loop:
	add 1
	ld (18432),a
	nop
	jp loop
