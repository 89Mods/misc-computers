	org 0
code:
	ld a,(16384)
	add 0
	jp z,code
	ld (16384),a
	jp code
