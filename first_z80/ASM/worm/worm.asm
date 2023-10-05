	org 0
code:
	di
	ld sp,34816
	ld hl,loop_start
	ld de,&8000
	ld b,0
	ld ix,0
	ld c,24
	ldir
	jp &8000

loop_start:
	ld hl,&8008
	ld de,&8018
	nop
	nop
loop:
	inc ix
	ld a,ixl
	ld (18432),a
	ld a,'e'
	ld (24576),a
	ld c,16
	ldir
