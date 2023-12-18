testval1 equ 170
testval2  equ 85
testval3 equ 115

start:
	setup
	ldi rr,1
	sti 1,8
	sti 0,9
	sti 1,10
	sti 1,11
	sti 0,12
	sti 1,13
	sti 0,14
	ldi dr,loop
loop:
	txi 72
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
	jmp
	end
