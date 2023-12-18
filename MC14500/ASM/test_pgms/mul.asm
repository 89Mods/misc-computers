COPY_TEMP equ 0
COPY_TEMP2 equ 1
MUL_SIGN equ 2
TO_HEX_PTR equ 5

MIN00 equ 8
MIN01 equ 9
MIN02 equ 10
MIN03 equ 11
MIN10 equ 12
MIN11 equ 13
MIN12 equ 14
MIN13 equ 15
MRES0 equ 16
MRES1 equ 17
MRES2 equ 18
MRES3 equ 19
MRES4 equ 20
MRES5 equ 21
MRES6 equ 22
MRES7 equ 23
MIN832 equ 24
MTMP0 equ 25
MTMP1 equ 26
MTMP2 equ 27
MTMP3 equ 28

start:
	setup

	ldmi MIN00,0x1A
	ldmi TO_HEX_PTR,MIN00
	call to_hex
	txi '*'
	ldmi MIN10,0x2E
	ldmi TO_HEX_PTR,MIN10
	call to_hex
	txi '='
	call mul_8x8
	ldmi TO_HEX_PTR,MRES1
	call to_hex
	ldmi TO_HEX_PTR,MRES0
	call to_hex
	call newl
	
	ldi dob,0
	str MRES3
	str MRES4
	str MRES5
	str MRES6
	str MRES7
	ldmi MIN832,0x1B
	ldmi TO_HEX_PTR,MIN832
	call to_hex
	txi '*'
	ldmi MTMP3,0x07
	ldmi TO_HEX_PTR,MTMP3
	call to_hex
	ldmi MTMP2,0xAC
	ldmi TO_HEX_PTR,MTMP2
	call to_hex
	ldmi MTMP1,0x3D
	ldmi TO_HEX_PTR,MTMP1
	call to_hex
	ldmi MTMP0,0x12
	ldmi TO_HEX_PTR,MTMP0
	call to_hex
	txi '='
	call mul_8x32
	ldmi TO_HEX_PTR,MRES7
	call to_hex
	ldmi TO_HEX_PTR,MRES6
	call to_hex
	ldmi TO_HEX_PTR,MRES5
	call to_hex
	ldmi TO_HEX_PTR,MRES4
	call to_hex
	ldmi TO_HEX_PTR,MRES3
	call to_hex
	call newl
	
	ldmi MIN03,0x07
	ldmi TO_HEX_PTR,MIN03
	call to_hex
	ldmi MIN02,0xAC
	ldmi TO_HEX_PTR,MIN02
	call to_hex
	ldmi MIN01,0x3D
	ldmi TO_HEX_PTR,MIN01
	call to_hex
	ldmi MIN00,0x12
	ldmi TO_HEX_PTR,MIN00
	call to_hex
	txi '*'
	ldmi MIN13,0x28
	ldmi TO_HEX_PTR,MIN13
	call to_hex
	ldmi MIN12,0xA7
	ldmi TO_HEX_PTR,MIN12
	call to_hex
	ldmi MIN11,0xC0
	ldmi TO_HEX_PTR,MIN11
	call to_hex
	ldmi MIN10,0x8B
	ldmi TO_HEX_PTR,MIN10
	call to_hex
	txi '='
	call mul_32x32_signed
	call print_long_res
	call newl
	
	txi '-'
	ldmi MIN03,0x07
	ldmi TO_HEX_PTR,MIN03
	call to_hex
	ldmi MIN02,0xAC
	ldmi TO_HEX_PTR,MIN02
	call to_hex
	ldmi MIN01,0x3D
	ldmi TO_HEX_PTR,MIN01
	call to_hex
	ldmi MIN00,0x12
	ldmi TO_HEX_PTR,MIN00
	call to_hex
	sec
	loda MIN00
	neg dia
	str
	loda MIN01
	neg dia
	str
	loda MIN02
	neg dia
	str
	loda MIN03
	neg dia
	str
	txi '*'
	ldmi MIN13,0x06
	ldmi TO_HEX_PTR,MIN13
	call to_hex
	ldmi MIN12,0xC9
	ldmi TO_HEX_PTR,MIN12
	call to_hex
	ldmi MIN11,0x18
	ldmi TO_HEX_PTR,MIN11
	call to_hex
	ldmi MIN10,0x56
	ldmi TO_HEX_PTR,MIN10
	call to_hex
	txi '='
	call mul_32x32_signed
	txi '-'
	ldmi TO_HEX_PTR,MRES0
	sec
inv_loop:
	loda TO_HEX_PTR
	ldr mar,dia
	loda
	neg dia
	ld cf
	sto 12
	str
	loda TO_HEX_PTR
	inc_nc dia
	str
	loda
	eqli dia,MIN832
	jnz inv_loop
	call print_long_res
	call newl
	
halt:
	nopo 15
	jmp halt

print_long_res:
	loda 255
	cpy dia
	str 253
	loda 254
	cpy dia
	str 252
	ldmi TO_HEX_PTR,MRES7
print_loop:
	call to_hex
	loda TO_HEX_PTR
	dec dia
	str
	loda
	eqli dia,MIN13
	jnz print_loop
	return 253,252

newl:
	txi 13
	txi 10
	return

mul_8x8:
	ldmi MRES0,0
	ldi mar,MRES1
	str
	ldi mar,COPY_TEMP
	str
	ldi mar,MIN00
mul_8x8_loop:
	loda
	lsr dia
	str
	jnc mul_8x8_no_carry
	loda MIN10
	lodb MRES0
	add
	str
	loda COPY_TEMP
	lodb MRES1
	adc
	str
mul_8x8_no_carry:
	loda MIN10
	lsl dia
	str
	loda COPY_TEMP
	rlc dia
	str
	loda MIN00
	eqli dia,0
	jnz mul_8x8_loop
	return

mul_32x32_signed:
	ldmi MUL_SIGN,0
	loda MIN03
	ani dia,128
	nopo 14
	jz mul_32x32_a_not_neg
	sec
	loda MIN00
	neg dia
	str
	loda MIN01
	neg dia
	str
	loda MIN02
	neg dia
	str
	loda MIN03
	neg dia
	str
	ldmi MUL_SIGN,1
mul_32x32_a_not_neg:
	loda MIN13
	ani dia,128
	jz mul_32x32_b_not_neg
	sec
	loda MIN10
	neg dia
	str
	loda MIN11
	neg dia
	str
	loda MIN12
	neg dia
	str
	loda MIN13
	neg dia
	str
	loda MUL_SIGN
	xri dia,1
	str
mul_32x32_b_not_neg:
	jmp mul_32x32_a
mul_32x32:
	ldmi MUL_SIGN,0
mul_32x32_a:
	loda 255
	cpy dia
	str 253
	loda 254
	cpy dia
	str 252
	ldi dob,0
	str MRES3
	str MRES4
	str MRES5
	str MRES6
	str MRES7
	ldmi TO_HEX_PTR,MIN00
mul_32x32_loop:
	loda MIN10
	ldr dob,dia
	str MTMP0
	loda MIN11
	ldr dob,dia
	str MTMP1
	loda MIN12
	ldr dob,dia
	str MTMP2
	loda MIN13
	ldr dob,dia
	str MTMP3
	; res = res >> 8
	loda MRES1
	cpy dia
	str MRES0
	loda MRES2
	cpy dia
	str MRES1
	loda MRES3
	cpy dia
	str MRES2
	loda MRES4
	cpy dia
	str MRES3
	lodb MRES5
	cpy dib
	str MRES4
	lodb MRES6
	cpy dib
	str MRES5
	lodb MRES7
	cpy dib
	str MRES6
	ldmi MRES7,0
	; res += (MIN0[ptr] * MIN1) << 24
	loda TO_HEX_PTR
	ldr mar,dia
	loda
	cpy dia
	str MIN832
	call mul_8x32
	; ptr = ptr + 1
	lodb TO_HEX_PTR
	inc dib
	str
	loda
	eqli dia,MIN10
	jnz mul_32x32_loop
	loda MUL_SIGN
	eqli dia,0
	jz mul_32x32_res_not_neg
	ldmi TO_HEX_PTR,MRES0
	sec
mul_32x32_res_inv_loop:
	loda TO_HEX_PTR
	ldr mar,dia
	loda
	neg dia
	str
	loda TO_HEX_PTR
	inc_nc dia
	str
	loda
	eqli dia,MIN832
	jnz mul_32x32_res_inv_loop
mul_32x32_res_not_neg:
	return 253,252
	
mul_8x32:
	ldmi COPY_TEMP,0
mul_8x32_loop:
	loda MIN832
	lsr dia
	str
	jnc mul_8x32_no_carry
	loda MTMP0
	lodb MRES3
	add
	str
	loda MTMP1
	lodb MRES4
	adc
	str
	loda MTMP2
	lodb MRES5
	adc
	str
	loda MTMP3
	lodb MRES6
	adc
	str
	loda COPY_TEMP
	lodb MRES7
	adc
	str
mul_8x32_no_carry:
	loda MTMP0
	lsl dia
	str
	loda MTMP1
	rlc dia
	str
	loda MTMP2
	rlc dia
	str
	loda MTMP3
	rlc dia
	str
	loda COPY_TEMP
	rlc dia
	str
	loda MIN832
	eqli dia,0
	jnz mul_8x32_loop
mul_8x32_end:
	return
	
to_hex:
	loda TO_HEX_PTR
	ldr mar,dia
	loda
	ld dia
	ld dia
	ld dia
	ld dia
	ldr dob,dia
	str COPY_TEMP2
	loda
	sui dia,10
	jnc th_below_10_1
	tfr dia
	adi dia,17 ; 'A' - '0'
	str
th_below_10_1:
	loda
	adi dia,48 ; '0'
	tfr dia
	txd
	loda TO_HEX_PTR
	ldr mar,dia
	loda
	ani dia,15
	str COPY_TEMP2
	loda
	sui dia,10
	jnc th_below_10_2
	tfr dia
	adi dia,17 ; 'A' - '0'
	str
th_below_10_2:
	loda
	adi dia,48 ; '0'
	tfr dia
	txd
	return
	end
