COPY_TEMP equ 0
COPY_TEMP2 equ 1
MUL_SIGN equ 2
CURR_ROW equ 3
CURR_COL equ 4
TO_HEX_PTR equ 5
ITER_CTR equ 6
MAN_YY_1 equ 7

MIN00 equ 8
MIN01 equ 9
MIN02 equ 10
MIN03 equ 11
MIN10 equ 12
MIN11 equ 13
MIN12 equ 14
MIN13 equ 15
MRES3 equ 16
MRES4 equ 17
MRES5 equ 18
MRES6 equ 19
MRES7 equ 20
MTMP0 equ 21
MTMP1 equ 22
MTMP2 equ 23
MTMP3 equ 24
C1_0 equ 25
C1_1 equ 26
C1_2 equ 27
C1_3 equ 28
C2_0 equ 29
C2_1 equ 30
C2_2 equ 31
C2_3 equ 32
C3_0 equ 33
C3_1 equ 34
C3_2 equ 35
C3_3 equ 36
C4_0 equ 37
C4_1 equ 38
C4_2 equ 39
C4_3 equ 40
C_IM_0 equ 41
C_IM_1 equ 42
C_IM_2 equ 43
C_IM_3 equ 44
C_RE_0 equ 45
C_RE_1 equ 46
C_RE_2 equ 47
C_RE_3 equ 48
MAN_X_0 equ 49
MAN_X_1 equ 50
MAN_X_2 equ 51
MAN_X_3 equ 52
MAN_Y_0 equ 53
MAN_Y_1 equ 54
MAN_Y_2 equ 55
MAN_Y_3 equ 56
MAN_XX_0 equ 57
MAN_XX_1 equ 58
MAN_XX_2 equ 59
MAN_XX_3 equ 60
MAN_YY_0 equ 61

; TODO: fit into 64 bytes
; HINT: Most significant bytes of C1 / C4 need not be stored. They are both, by definition, < 1
MAN_YY_2 equ 100
MAN_YY_3 equ 101

FRES0 equ 16
FRES1 equ 17
FRES2 equ 18
FRES3 equ 19

; Pre-computed constants for w=238, h=48
M_WIDTH equ 238
M_HEIGHT equ 48
M_HEIGHT_M1 equ 47
C1_PRE equ 1101
C4_PRE equ 2730
W_D2 equ 119
H_D2 equ 24

; Settings
ZOOM_0 equ 0x02
ZOOM_1 equ 0x5B
ZOOM_2 equ 0xF7
RE_0 equ 0
RE_1 equ 0
RE_2 equ 0
IMAG_0 equ 0
IMAG_1 equ 0
IMAG_2 equ 0
MAX_ITER equ 64

start:
	setup
	
	; Startup delay
	ldmi COPY_TEMP,0
startup_delay_loop:
	loda COPY_TEMP
	sec
	incc dia
	str
	lodb COPY_TEMP
	eqli dib,0
	jnz startup_delay_loop

	; C1 = C1_PRE * ZOOM
	; C2 = W_D2 * C1
	ldmi MIN00,0
	ldmi MIN03,0
	ldmi MIN01,0x4D
	ldmi MIN02,0x04
	ldmi MIN10,ZOOM_0
	ldmi MIN11,ZOOM_1
	ldmi MIN12,ZOOM_2
	ldmi MIN13,0
	call mul_32x32
	loda FRES0
	cpy dia
	str MIN00
	str C1_0
	loda FRES1
	cpy dia
	str MIN01
	str C1_1
	loda FRES2
	cpy dia
	str MIN02
	str C1_2
	loda FRES3
	cpy dia
	str MIN03
	str C1_3
	ldi dob,0
	str MIN10
	str MIN11
	str MIN12
	ldmi MIN13,W_D2
	call mul_32x32
	loda FRES0
	cpy dia
	str C2_0
	loda FRES1
	cpy dia
	str C2_1
	loda FRES2
	cpy dia
	str C2_2
	loda FRES3
	cpy dia
	str C2_3
	
	ldmi TO_HEX_PTR,C1_3
	call to_hex
	txi '.'
	ldmi TO_HEX_PTR,C1_2
	call to_hex
	ldmi TO_HEX_PTR,C1_1
	call to_hex
	ldmi TO_HEX_PTR,C1_0
	call to_hex
	call newl
	ldmi TO_HEX_PTR,C2_3
	call to_hex
	txi '.'
	ldmi TO_HEX_PTR,C2_2
	call to_hex
	ldmi TO_HEX_PTR,C2_1
	call to_hex
	ldmi TO_HEX_PTR,C2_0
	call to_hex
	call newl
	
	; C4 = C4_PRE * ZOOM
	; C3 = H_D2 * C4
	ldmi MIN00,0
	ldmi MIN03,0
	ldmi MIN01,0xAA
	ldmi MIN02,0x0A
	ldmi MIN10,ZOOM_0
	ldmi MIN11,ZOOM_1
	ldmi MIN12,ZOOM_2
	ldmi MIN13,0
	call mul_32x32
	loda FRES0
	cpy dia
	str MIN00
	str C4_0
	loda FRES1
	cpy dia
	str MIN01
	str C4_1
	loda FRES2
	cpy dia
	str MIN02
	str C4_2
	loda FRES3
	cpy dia
	str MIN03
	str C4_3
	ldi dob,0
	str MIN10
	str MIN11
	str MIN12
	ldmi MIN13,H_D2
	call mul_32x32
	loda FRES0
	cpy dia
	str C3_0
	loda FRES1
	cpy dia
	str C3_1
	loda FRES2
	cpy dia
	str C3_2
	loda FRES3
	cpy dia
	str C3_3
	
	ldmi TO_HEX_PTR,C4_3
	call to_hex
	txi '.'
	ldmi TO_HEX_PTR,C4_2
	call to_hex
	ldmi TO_HEX_PTR,C4_1
	call to_hex
	ldmi TO_HEX_PTR,C4_0
	call to_hex
	call newl
	ldmi TO_HEX_PTR,C3_3
	call to_hex
	txi '.'
	ldmi TO_HEX_PTR,C3_2
	call to_hex
	ldmi TO_HEX_PTR,C3_1
	call to_hex
	ldmi TO_HEX_PTR,C3_0
	call to_hex
	call newl
	
	; Negate C2, C3 (they’re only ever subtracted, so this’ll save time later)
	sec
	loda C2_0
	neg dia
	str
	loda C2_1
	neg dia
	str
	loda C2_2
	neg dia
	str
	loda C2_3
	neg dia
	str
	sec
	lodb C3_0
	neg dib
	str
	lodb C3_1
	neg dib
	str
	lodb C3_2
	neg dib
	str
	lodb C3_3
	neg dib
	str

	ldmi CURR_ROW,M_HEIGHT_M1
mandel_loop_rows:
	; res = CURR_ROW * c4
	loda C4_0
	cpy dia
	str MIN00
	loda C4_1
	cpy dia
	str MIN01
	loda C4_2
	cpy dia
	str MIN02
	loda C4_3
	cpy dia
	str MIN03
	ldi dob,0
	str MIN10
	str MIN11
	str MIN12
	loda CURR_ROW
	cpy dia
	str MIN13
	call mul_32x32
	; res = res + IMAG
	loda FRES0
	adi dia,IMAG_0
	str
	loda FRES1
	aci dia,IMAG_1
	str
	loda FRES2
	aci dia,IMAG_2
	str
	loda FRES3
	incc dia
	str
	; C_IM = res + (-C3)
	loda FRES0
	lodb C3_0
	add
	str C_IM_0
	loda FRES1
	lodb C3_1
	adc
	str C_IM_1
	loda FRES2
	lodb C3_2
	adc
	str C_IM_2
	loda FRES3
	lodb C3_3
	adc
	str C_IM_3
	
	ldmi CURR_COL,0
mandel_loop_cols:
	; res = CURR_COL * C1
	loda C1_0
	cpy dia
	str MIN00
	loda C1_1
	cpy dia
	str MIN01
	loda C1_2
	cpy dia
	str MIN02
	loda C1_3
	cpy dia
	str MIN03
	ldi dob,0
	str MIN10
	str MIN11
	str MIN12
	loda CURR_COL
	cpy dia
	str MIN13
	call mul_32x32
	; res = res + RE
	loda FRES0
	adi dia,RE_0
	str
	loda FRES1
	aci dia,RE_1
	str
	loda FRES2
	aci dia,RE_2
	str
	loda FRES3
	incc dia
	str
	; C_RE = MAN_X = res + (-C2)
	loda FRES0
	lodb C2_0
	add_nz
	str C_RE_0
	str MAN_X_0
	loda FRES1
	lodb C2_1
	adc_nz
	str C_RE_1
	str MAN_X_1
	loda FRES2
	lodb C2_2
	adc_nz
	str C_RE_2
	str MAN_X_2
	loda FRES3
	lodb C2_3
	adc_nz
	str C_RE_3
	str MAN_X_3
	
	; MAN_Y = C_IM
	loda C_IM_0
	cpy dia
	str MAN_Y_0
	loda C_IM_1
	cpy dia
	str MAN_Y_1
	loda C_IM_2
	cpy dia
	str MAN_Y_2
	loda C_IM_3
	cpy dia
	str MAN_Y_3
	; iteration = 0
	ldmi ITER_CTR,0
mandel_calc_loop:
	; yy = y * y
	loda MAN_Y_0
	cpy dia
	str MIN00
	str MIN10
	loda MAN_Y_1
	cpy dia
	str MIN01
	str MIN11
	loda MAN_Y_2
	cpy dia
	str MIN02
	str MIN12
	loda MAN_Y_3
	cpy dia
	str MIN03
	str MIN13
	call mul_32x32_signed
	loda FRES0
	cpy dia
	str MAN_YY_0
	loda FRES1
	cpy dia
	str MAN_YY_1
	loda FRES2
	cpy dia
	str MAN_YY_2
	loda FRES3
	cpy dia
	str MAN_YY_3
	; res = x * y
	loda MAN_Y_0
	cpy dia
	str MIN00
	loda MAN_Y_1
	cpy dia
	str MIN01
	loda MAN_Y_2
	cpy dia
	str MIN02
	loda MAN_Y_3
	cpy dia
	str MIN03
	loda MAN_X_0
	cpy dia
	str MIN10
	loda MAN_X_1
	cpy dia
	str MIN11
	loda MAN_X_2
	cpy dia
	str MIN12
	loda MAN_X_3
	cpy dia
	str MIN13
	call mul_32x32_signed
	; res = res << 1
	loda FRES0
	lsl dia
	str
	loda FRES1
	rlc dia
	str
	loda FRES2
	rlc dia
	str
	loda FRES3
	rlc dia
	str
	; y = res + c_im
	loda FRES0
	lodb C_IM_0
	add_nz
	str MAN_Y_0
	loda FRES1
	lodb C_IM_1
	adc_nz
	str MAN_Y_1
	loda FRES2
	lodb C_IM_2
	adc_nz
	str MAN_Y_2
	loda FRES3
	lodb C_IM_3
	adc_nz
	str MAN_Y_3
	; xx = res = x * x
	loda MAN_X_0
	cpy dia
	str MIN00
	str MIN10
	loda MAN_X_1
	cpy dia
	str MIN01
	str MIN11
	loda MAN_X_2
	cpy dia
	str MIN02
	str MIN12
	loda MAN_X_3
	cpy dia
	str MIN03
	str MIN13
	call mul_32x32_signed
	loda FRES0
	cpy dia
	str MAN_XX_0
	loda FRES1
	cpy dia
	str MAN_XX_1
	loda FRES2
	cpy dia
	str MAN_XX_2
	loda FRES3
	cpy dia
	str MAN_XX_3
	; res = res - yy
	lodb MAN_YY_0
	loda FRES0
	sub
	str
	lodb MAN_YY_1
	loda FRES1
	suc
	str
	lodb MAN_YY_2
	loda FRES2
	suc
	str
	lodb MAN_YY_3
	loda FRES3
	suc
	str
	; x = res + c_re
	loda FRES0
	lodb C_RE_0
	add
	str MAN_X_0
	loda FRES1
	lodb C_RE_1
	adc
	str MAN_X_1
	loda FRES2
	lodb C_RE_2
	adc
	str MAN_X_2
	loda FRES3
	lodb C_RE_3
	adc
	str MAN_X_3
	; check if xx + yy <= 4
	loda MAN_XX_0
	lodb MAN_YY_0
	add_nz
	loda MAN_XX_1
	lodb MAN_YY_1
	adc_nz
	loda MAN_XX_2
	lodb MAN_YY_2
	adc_nz
	loda MAN_XX_3
	lodb MAN_YY_3
	adc_nz
	str COPY_TEMP
	loda COPY_TEMP
	sui dia,4
	jc mandel_calc_loop_overflow
	; iteration++
	loda ITER_CTR
	inc dia
	str
	; Max iters exit
	lodb
	eqli dib,MAX_ITER
	jnz mandel_calc_loop
mandel_calc_loop_max_iters:
	txi 32
	jmp mandel_calc_loop_exit
mandel_calc_loop_overflow:
	txi 27
	txi 91
	txi 51
	loda ITER_CTR
	ani dia,7
	str
	jnz do_not_inc
	loda
	inc dia
	str
do_not_inc:
	loda
	adi dia,48
	str
	loda
	txd
	txi 109
	txi 0
	txi '#'
mandel_calc_loop_exit:
	; End col loop
	loda CURR_COL
	inc dia
	str
	loda
	eqli dia,M_WIDTH
	jnz mandel_loop_cols
debug_1:
	; End row loop
	call newl
	loda CURR_ROW
	dec dia
	str
	loda
	eqli dia,255
	jnz mandel_loop_rows
	
halt:
	nopf 14
	nopo 15
	jmp halt

newl:
	txi 13
	txi 10
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
	ldmi COPY_TEMP2,0
mul_32x32_a:
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
	loda MRES3
	sui dia,1
	loda COPY_TEMP2
	rlc dia
	str
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
	str MIN00
	
	; BEGIN MUL_8X32
mul_8x32:
	ldmi COPY_TEMP,0
mul_8x32_loop:
	loda MIN00
	lsr dia
	str
	jnc mul_8x32_no_carry
	loda MTMP0
	lodb MRES3
	add_nz
	str
	loda MTMP1
	lodb MRES4
	adc_nz
	str
	loda MTMP2
	lodb MRES5
	adc_nz
	str
	loda MTMP3
	lodb MRES6
	adc_nz
	str
	loda COPY_TEMP
	lodb MRES7
	adc_nz
	str
mul_8x32_no_carry:
	loda MTMP0
	lsl_nz dia
	str
	loda MTMP1
	rlc_nz dia
	str
	loda MTMP2
	rlc_nz dia
	str
	loda MTMP3
	rlc_nz dia
	str
	loda COPY_TEMP
	rlc_nz dia
	str
	loda MIN00
	eqli dia,0
	jnz mul_8x32_loop
mul_8x32_end:
	; END MUL_8X32
	
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
	ldmi TO_HEX_PTR,MRES3
	loda COPY_TEMP2
	eqli dia,0
	ld zf
	sto cf
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
	eqli dia,MTMP0
	jnz mul_32x32_res_inv_loop
mul_32x32_res_not_neg:
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
