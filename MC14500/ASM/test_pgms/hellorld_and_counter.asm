start:
	setup
	ldi mar,5
	ldi wbr,0
	str
	ldi dr,loop
loop:
	txi 'H'
	txi 'e'
	txi 'l'
	txi 'l'
	txi 'o'
	txi 'r'
	txi 'l'
	txi 'd'
	txi '!'
	txi 13
	txi 10
	loda
	inca
	str
	lodb
	ld 4
	ld 4
	ld 4
	ld 4
	ld 4
	ld 4
	sto 10
	ld 4
	sto 11
	ld 4
	sto 12
	jmp
	end
