	; Register names in octal
	; R10 = OVF
	; R7 = LB
	; R17 = RB
	; R0 = AUX
	; R12, R13 = Special during xmit
	
	org 0
start:
	nop
	xmit 0, R5
	move R5, R6
	move R6, R11
	
	xmit 64, IVL
	xmit 255-3, AUX ; Master reset
	move AUX, RIV7
	xmit 32, IVL
	xmit 10, RIV7
	xmit 8, RIV7
	xmit 12, RIV7
	xmit 10, RIV7
	
	xmit 64, IVL
	xmit 255-21, AUX ; div 16, 8 bits + 1 stop bit, tx int disabled, rx int disabled
	move AUX, RIV7
	xmit 32, IVL
	xmit 8, RIV7
	xmit 12, RIV7
	xmit 10, RIV7
hellorld_begin:
	xmit 0, R1
loop:
	xec xec_targ(R1)
	xmit 64, IVL
	move R0, RIV7
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	xmit 1, AUX
	add R1, R1
	jmp loop
xec_targ:
	xmit 255-'H', R0
	xmit 255-'e', R0
	xmit 255-'l', R0
	xmit 255-'l', R0
	xmit 255-'o', R0
	xmit 255-'r', R0
	xmit 255-'l', R0
	xmit 255-'d', R0
	xmit 255-'!', R0
	xmit 255-13, R0
	xmit 255-10, R0
	jmp hellorld_begin
