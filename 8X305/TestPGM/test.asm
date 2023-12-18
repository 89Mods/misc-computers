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
	xmit 65, R1
	xmit 10, R0
	add R1, R1
	xmit 23, IVL
	move R1, LIV7
	
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
loop:
	;xmit 128, IVL
	;move RIV4, AUX
	;xmit 32, IVL
	;move AUX, 4, RIV7
	xmit '0', AUX
	xmit 128, IVL
	add RIV4, R1
	xmit 255, AUX
	xor R1, R1
	xmit 64, IVL
	move R1, RIV7
	xmit 32, IVL
	xmit 9, RIV7
	xmit 13, RIV7
	xmit 11, RIV7
	
	xmit 23, IVL
	xmit 1, AUX
	add LIV6, 4, LIV6
	xmit 255, AUX
	xor LIV7, AUX
	xmit 64, IVL
	move AUX, RIV7
	move R11, R11 ; Another kind of nop
	jmp loop
