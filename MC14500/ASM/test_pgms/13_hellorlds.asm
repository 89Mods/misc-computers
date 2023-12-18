start:
	setup
	ldi mar,5
	ldi dob,0
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
	eql dib,13
	jz
	ldi dr,halt
halt:
	nopo 15
	jmp
	end
