start:
	setup
	ldi mar,5
	ldi dob,0
	str
loop:
	loda
	inca
	str
	lodb
	ld 4
	sto 9
	ld 4
	sto 10
	ld 4
	sto 11
	ld 4
	sto 12
	jmp loop
	end
