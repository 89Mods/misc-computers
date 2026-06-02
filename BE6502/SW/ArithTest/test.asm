via_base equ $6000
PORTB equ via_base+0
PORTA equ via_base+1
DDRB equ via_base+2
DDRA equ via_base+3
T1CL equ via_base+4
T1CH equ via_base+5
T1LL equ via_base+6
T1LH equ via_base+7
T2CL equ via_base+8
T2CH equ via_base+9
SR equ via_base+10
ACR equ via_base+11
PCR equ via_base+12
IFR equ via_base+13
IER equ via_base+14
PORTA_NO_HANDSHAKE equ via_base+15
acia_base equ $5000
TXD equ acia_base+0
RXD equ acia_base+0
ACIA_RESET equ acia_base+1
ACIA_STATUS_READ equ acia_base+1
CMD equ acia_base+2
CTRL equ acia_base+3

led_count equ 6
led_header equ $E7

; Memory locations

port_counter equ 0
delay_counter equ 1
led_counter_lo equ 2
led_counter_hi equ 3
led_loop_counter equ 4
led_time_lo equ 5
led_time_hi equ 6

sk_backup equ 254
sk_temp equ 255

mem_start equ $80
min00 equ mem_start
min01 equ mem_start+1
min02 equ mem_start+2
min03 equ mem_start+3
min10 equ mem_start+4
min11 equ mem_start+5
min12 equ mem_start+6
min13 equ mem_start+7
mres0 equ mem_start+8
mres1 equ mem_start+9
mres2 equ mem_start+10
mres3 equ mem_start+11
mres4 equ mem_start+12
mres5 equ mem_start+13
mres6 equ mem_start+14
mres7 equ mem_start+15
mtemp0 equ mem_start+16
mtemp1 equ mem_start+17
mtemp2 equ mem_start+18
mtemp3 equ mem_start+19
mtemp4 equ mem_start+20
mtemp5 equ mem_start+21
mtemp6 equ mem_start+22
rem0 equ mem_start+23
rem1 equ mem_start+24
rem2 equ mem_start+25
rem3 equ mem_start+26

temp0 equ mem_start+27

C1 equ mem_start+40
C2 equ mem_start+44
C3 equ mem_start+48
C4 equ mem_start+52
C_IM equ mem_start+56
C_RE equ mem_start+60
MAN_X equ mem_start+64
MAN_XX equ mem_start+68
MAN_Y equ mem_start+72
MAN_YY equ mem_start+76
ITERATION equ mem_start+80

irupt_skips equ mem_start+100

ZOOM equ 16000000
RE equ 0
IMAG equ 0
MAX_ITER equ 178

; Pre-computed constants for w=238, h=48
M_WIDTH equ 238
M_HEIGHT equ 48
C1_PRE equ 1101
C4_PRE equ 2730
W_D2 equ 119
H_D2 equ 24

proctype equ 0

	org $8000
irupt:
	pha
	IF proctype
	phy
	phx
	ELSEIF
	tya
	pha
	txa
	pha
	ENDIF
	lda IFR
	and #$20
	bne trupt
	jmp irupt_return
nmi:
	rti
irupt_return:
	IF proctype
	plx
	ply
	ELSEIF
	pla
	tax
	pla
	tay
	ENDIF
	pla
	rti
trupt:
	lda port_counter
	clc
	adc #1
	sta port_counter
	ror
	ror
	ror
	ror
	ror
	sta PORTA
	
	lda #$FF
	sta T2CL
	sta T2CH
	nop
	
	lda #1
	and port_counter
	beq led_time_overflow
	jmp led_time_no_overflow
led_time_overflow:
	lda irupt_skips
	beq no_led_skip
	dec irupt_skips
	jmp irupt_return
no_led_skip:
	jsr sk_led_begin
	ldy #led_count
	lda led_time_hi
	sta led_counter_hi
	lda led_time_lo
	sta led_counter_lo
leds_loop:
	sty led_loop_counter
	lda #led_header
	jsr sk_led_byte
	ldx led_counter_lo
	ldy led_counter_hi
	jsr wave_function
	;lsr
	;clc
	;adc #$7F
	sta sk_temp
	lsr
	lsr
	lsr
	sta 10
	lda sk_temp
	sec
	sbc 10
	clc
	adc #$1F
	jsr sk_led_byte
	ldx led_counter_lo
	ldy led_counter_hi
	iny
	jsr wave_function
	sta sk_temp
	lsr
	lsr
	lsr
	sta 10
	lda sk_temp
	sec
	sbc 10
	clc
	adc #$1F
	jsr sk_led_byte
	ldx led_counter_lo
	ldy led_counter_hi
	iny
	iny
	jsr wave_function
	sta sk_temp
	lsr
	lsr
	lsr
	sta 10
	lda sk_temp
	sec
	sbc 10
	clc
	adc #$1F
	jsr sk_led_byte
	lda led_counter_lo
	clc
	adc #55
	sta led_counter_lo
	lda led_counter_hi
	adc #0
	cmp #3
	bmi led_counter_no_overflow
	lda #0
led_counter_no_overflow:
	sta led_counter_hi
	ldy led_loop_counter
	dey
	bne leds_loop
	jsr sk_led_end
	
	lda led_time_lo
	clc
	adc #10
	sta led_time_lo
	lda led_time_hi
	adc #0
	sta led_time_hi
	cmp #3
	bmi led_time_no_overflow
	IF proctype
	stz led_time_hi
	ELSEIF
	lda #0
	sta led_time_hi
	ENDIF
led_time_no_overflow:
	jmp irupt_return

startup:
	sei
	cld
	ldx #$FF
	txs
	lda #$07
	sta DDRA
	IF proctype
	stz DDRB
	stz PORTA
	stz PORTB
	stz ACR
	stz irupt_skips
	ELSEIF
	lda #$00
	sta DDRB
	sta PORTA
	sta PORTB
	sta ACR
	sta irupt_skips
	ENDIF
	lda #$7F
	sta IER
	lda #%10101010
	sta PCR
	lda #$FF
	sta T1CL
	sta T1CH
	
	lda #%00011100
	sta CTRL
	lda #%11101011
	sta CMD
	
	lda #%10100000
	sta IER
	lda #$FF
	sta T2CL
	sta T2CH
	cli
	
	lda #0
	sta port_counter
	sta led_time_lo
	sta led_time_hi
	brk
	nop
	
	lda #32
wait_for_uart:
	bit ACIA_STATUS_READ
	bne wait_for_uart
	lda #'C'
	jsr uart_send
	lda #'h'
	jsr uart_send
	lda #'i'
	jsr uart_send
	lda #'r'
	jsr uart_send
	lda #'p'
	jsr uart_send
	lda #'!'
	jsr uart_send
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	ldx #0
test_loop_1:
	lda m_ins_8x8,X
	cmp #255
	beq test_loop_1_end
	inx
	jsr print_hex
	sta min00
	lda #'*'
	jsr uart_send
	lda m_ins_8x8,X
	jsr print_hex
	sta min10
	lda #'='
	jsr uart_send
	jsr mul_8x8
	lda mres1
	jsr print_hex
	lda mres0
	jsr print_hex
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	inx
	jmp test_loop_1
test_loop_1_end:
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	ldx #0
test_loop_2:
	lda div_ins_16x16,X
	sta min01
	cmp #255
	beq test_loop_2_end
	jsr print_hex
	inx
	lda div_ins_16x16,X
	jsr print_hex
	sta min00
	lda #'/'
	inx
	jsr uart_send
	lda div_ins_16x16,X
	jsr print_hex
	sta min11
	inx
	lda div_ins_16x16,X
	inx
	jsr print_hex
	sta min10
	lda #'='
	jsr uart_send
	jsr div_16x16
	lda mres1
	jsr print_hex
	lda mres0
	jsr print_hex
	lda #' '
	jsr uart_send
	lda #'R'
	jsr uart_send
	lda #':'
	jsr uart_send
	lda #' '
	jsr uart_send
	lda rem1
	jsr print_hex
	lda rem0
	jsr print_hex
	
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	jmp test_loop_2
	
test_loop_2_end:
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	ldx #0
test_loop_3:
	lda mul_ins_32x32,X
	sta min03
	cmp #255
	beq test_loop_3_end
	jsr print_hex
	inx
	lda mul_ins_32x32,X
	sta min02
	jsr print_hex
	inx
	lda mul_ins_32x32,X
	sta min01
	jsr print_hex
	inx
	lda mul_ins_32x32,X
	sta min00
	jsr print_hex
	inx
	lda #'*'
	jsr uart_send
	ldy #4
copy_loop_0:
	dey
	lda mul_ins_32x32,X
	inx
	sta min10,Y
	jsr print_hex
	tya
	bne copy_loop_0
	lda #'='
	jsr uart_send
	jsr mul_32x32
	ldy #8
print_loop_1:
	dey
	lda mres0,Y
	jsr print_hex
	tya
	bne print_loop_1
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	jmp test_loop_3
	
test_loop_3_end:
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	ldx #0
test_loop_4:
	lda div_ins_32x32,X
	sta min03
	cmp #255
	beq test_loop_4_end
	jsr print_hex
	inx
	lda div_ins_32x32,X
	sta min02
	jsr print_hex
	inx
	lda div_ins_32x32,X
	sta min01
	jsr print_hex
	inx
	lda div_ins_32x32,X
	sta min00
	jsr print_hex
	inx
	lda #'/'
	jsr uart_send
	ldy #4
copy_loop_1:
	dey
	lda div_ins_32x32,X
	inx
	sta min10,Y
	jsr print_hex
	tya
	bne copy_loop_1
	lda #'='
	jsr uart_send
	jsr div_32x32
	ldy #4
print_loop_2:
	dey
	lda mres0,Y
	jsr print_hex
	tya
	bne print_loop_2
	
	lda #' '
	jsr uart_send
	lda #'R'
	jsr uart_send
	lda #':'
	jsr uart_send
	lda #' '
	jsr uart_send
	
	ldy #4
print_loop_3:
	dey
	lda rem0,Y
	jsr print_hex
	tya
	bne print_loop_3
	
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	jmp test_loop_4
	
test_loop_4_end:
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	ldx #0
test_loop_5:
	lda print_num_ins,X
	sta min00
	inx
	cmp #255
	beq test_loop_5_end
	lda print_num_ins,X
	sta min01
	inx
	lda print_num_ins,X
	sta min02
	inx
	lda print_num_ins,X
	sta min03
	inx
	jsr print_num
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	jmp test_loop_5
	
test_loop_5_end:
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	lda #$3F
	sta min03
	jsr print_hex
	lda #'.'
	jsr uart_send
	lda #$27
	sta min02
	jsr print_hex
	lda #$00
	sta min01
	sta min00
	jsr print_hex
	jsr print_hex
	lda #'*'
 	jsr uart_send
	lda #$00
	sta min13
	jsr print_hex
	lda #'.'
	jsr uart_send
	lda #$71
	sta min12
	jsr print_hex
	lda #$01
	sta min11
	jsr print_hex
	lda #$00
	sta min10
	jsr print_hex
	lda #'='
	jsr uart_send
	jsr mul_fixed
	
	lda mres3
	pha
	lda mres2
	pha
	lda mres1
	pha
	lda mres0
	pha
	
	lda mres3
	jsr print_hex
	lda #'.'
	jsr uart_send
	lda mres2
	jsr print_hex
	lda mres1
	jsr print_hex
	lda mres0
	jsr print_hex
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	lda #$3F
	sta min03
	lda #$27
	sta min02
	lda #$00
	sta min01
	sta min00
	jsr print_fixed
	lda #'*'
	jsr uart_send
	lda #$00
	sta min03
	lda #$71
	sta min02
	lda #$01
	sta min01
	lda #$00
	sta min00
	jsr print_fixed
	lda #'='
	jsr uart_send
	pla
	sta min00
	pla
	sta min01
	pla
	sta min02
	pla
	sta min03
	jsr print_fixed
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	lda #$29
	sta min03
	lda #$C6
	sta min02
	lda #$88
	sta min01
	sta min00
	jsr print_fixed
	lda #'/'
	jsr uart_send
	lda #$01
	sta min03
	lda #$3A
	sta min02
	lda #$1D
	sta min01
	lda #$0F
	sta min00
	jsr print_fixed
	lda #'='
	jsr uart_send
	lda #$01
	sta min13
	lda #$3A
	sta min12
	lda #$1D
	sta min11
	lda #$0F
	sta min10
	lda #$29
	sta min03
	lda #$C6
	sta min02
	lda #$88
	sta min01
	sta min00
	jsr div_fixed
	lda mres0
	sta min00
	lda mres1
	sta min01
	lda mres2
	sta min02
	lda mres3
	sta min03
	jsr print_fixed
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	; c1 = C1_PRE * ZOOM
	; c2 = W_D2 * c1
	lda #0
	sta min00
	sta min03
	lda #C1_PRE&255
	sta min01
	lda #C1_PRE>>8
	sta min02
	lda #ZOOM&255
	sta min10
	lda #(ZOOM>>8)&255
	sta min11
	lda #(ZOOM>>16)&255
	sta min12
	lda #(ZOOM>>24)&255
	sta min13
	jsr mul_fixed
	lda mres0
	sta C1
	sta min00
	lda mres1
	sta C1+1
	sta min01
	lda mres2
	sta C1+2
	sta min02
	lda mres3
	sta C1+3
	sta min03
	lda #W_D2
	sta min13
	lda #0
	sta min10
	sta min11
	sta min12
	jsr mul_fixed
	lda mres0
	sta C2
	sta min00
	lda mres1
	sta C2+1
	sta min01
	lda mres2
	sta C2+2
	sta min02
	lda mres3
	sta C2+3
	sta min03
	jsr print_fixed
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	; c4 = C4_PRE * ZOOM
	; c3 = H_D2 * c4
	lda #0
	sta min00
	sta min03
	lda #C4_PRE&255
	sta min01
	lda #C4_PRE>>8
	sta min02
	lda #ZOOM&255
	sta min10
	lda #(ZOOM>>8)&255
	sta min11
	lda #(ZOOM>>16)&255
	sta min12
	lda #(ZOOM>>24)&255
	sta min13
	jsr mul_fixed
	lda mres0
	sta C4
	sta min00
	lda mres1
	sta C4+1
	sta min01
	lda mres2
	sta C4+2
	sta min02
	lda mres3
	sta C4+3
	sta min03
	lda #H_D2
	sta min13
	IF proctype
	stz min10
	stz min11
	stz min12
	ELSEIF
	lda #0
	sta min10
	sta min11
	sta min12
	ENDIF
	jsr mul_fixed
	lda mres0
	sta C3
	sta min00
	lda mres1
	sta C3+1
	sta min01
	lda mres2
	sta C3+2
	sta min02
	lda mres3
	sta C3+3
	sta min03
	jsr print_fixed
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	
	ldx #M_HEIGHT-1
mandel_loop_rows:
	; res = row * c4
	stx min13
	IF proctype
	stz min12
	stz min11
	stz min10
	ELSEIF
	lda #0
	sta min12
	sta min11
	sta min10
	ENDIF
	lda C4
	sta min00
	lda C4+1
	sta min01
	lda C4+2
	sta min02
	lda C4+3
	sta min03
	jsr mul_fixed
	; c_im = res + IMAG
	clc
	lda #IMAG&255
	adc mres0
	sta C_IM
	lda #(IMAG>>8)&255
	adc mres1
	sta C_IM+1
	lda #(IMAG>>16)&255
	adc mres2
	sta C_IM+2
	lda #(IMAG>>24)&255
	adc mres3
	sta C_IM+3
	; c_im = c_im - c3
	sec
	lda C_IM
	sbc C3
	sta C_IM
	lda C_IM+1
	sbc C3+1
	sta C_IM+1
	lda C_IM+2
	sbc C3+2
	sta C_IM+2
	lda C_IM+3
	sbc C3+3
	sta C_IM+3
	
	ldy #0
mandel_loop_cols:
	; res = col * C1
	sty min13
	IF proctype
	stz min12
	stz min11
	stz min10
	ELSEIF
	lda #0
	sta min12
	sta min11
	sta min10
	ENDIF
	lda C1
	sta min00
	lda C1+1
	sta min01
	lda C1+2
	sta min02
	lda C1+3
	sta min03
	jsr mul_fixed_unsigned
	; c_re = res + RE
	clc
	lda #RE&255
	adc mres0
	sta C_RE
	lda #(RE>>8)&255
	adc mres1
	sta C_RE+1
	lda #(RE>>16)&255
	adc mres2
	sta C_RE+2
	lda #(RE>>24)&255
	adc mres3
	sta C_RE+3
	; c_re = x = c_re - c2
	sec
	lda C_RE
	sbc C2
	sta C_RE
	sta MAN_X
	lda C_RE+1
	sbc C2+1
	sta C_RE+1
	sta MAN_X+1
	lda C_RE+2
	sbc C2+2
	sta C_RE+2
	sta MAN_X+2
	lda C_RE+3
	sbc C2+3
	sta C_RE+3
	sta MAN_X+3
	
	; y = c_im
	lda C_IM
	sta MAN_Y
	lda C_IM+1
	sta MAN_Y+1
	lda C_IM+2
	sta MAN_Y+2
	lda C_IM+3
	sta MAN_Y+3
	
	; iteration = 0
	IF proctype
	stz ITERATION
	stz ITERATION+1
	ELSEIF
	lda #0
	sta ITERATION
	sta ITERATION+1
	ENDIF
mandel_calc_loop:
	; yy = y * y
	lda MAN_Y
	sta min00
	sta min10
	lda MAN_Y+1
	sta min01
	sta min11
	lda MAN_Y+2
	sta min02
	sta min12
	lda MAN_Y+3
	sta min03
	sta min13
	jsr mul_fixed
	lda mres0
	sta MAN_YY
	lda mres1
	sta MAN_YY+1
	lda mres2
	sta MAN_YY+2
	lda mres3
	sta MAN_YY+3
	; res = x * y
	lda MAN_X
	sta min00
	lda MAN_X+1
	sta min01
	lda MAN_X+2
	sta min02
	lda MAN_X+3
	sta min03
	lda MAN_Y
	sta min10
	lda MAN_Y+1
	sta min11
	lda MAN_Y+2
	sta min12
	lda MAN_Y+3
	sta min13
	jsr mul_fixed
	; res = res << 1
	asl mres0
	rol mres1
	rol mres2
	rol mres3
	; Y = res + c_im
	clc
	lda mres0
	adc C_IM
	sta MAN_Y
	lda mres1
	adc C_IM+1
	sta MAN_Y+1
	lda mres2
	adc C_IM+2
	sta MAN_Y+2
	lda mres3
	adc C_IM+3
	sta MAN_Y+3
	; res = X * X
	lda MAN_X
	sta min00
	sta min10
	lda MAN_X+1
	sta min01
	sta min11
	lda MAN_X+2
	sta min02
	sta min12
	lda MAN_X+3
	sta min03
	sta min13
	jsr mul_fixed
	; XX = res
	; res = res - YY
	sec
	lda mres0
	sta MAN_XX
	sbc MAN_YY
	sta mres0
	lda mres1
	sta MAN_XX+1
	sbc MAN_YY+1
	sta mres1
	lda mres2
	sta MAN_XX+2
	sbc MAN_YY+2
	sta mres2
	lda mres3
	sta MAN_XX+3
	sbc MAN_YY+3
	sta mres3
	; X = res + C_RE
	clc
	lda mres0
	adc C_RE
	sta MAN_X
	lda mres1
	adc C_RE+1
	sta MAN_X+1
	lda mres2
	adc C_RE+2
	sta MAN_X+2
	lda mres3
	adc C_RE+3
	sta MAN_X+3
	; check if xx + yy <= 4
	clc
	lda MAN_XX
	adc MAN_YY
	lda MAN_XX+1
	adc MAN_YY+1
	lda MAN_XX+2
	adc MAN_YY+2
	lda MAN_XX+3
	adc MAN_YY+3
	cmp #4
	bpl mandel_calc_loop_overflow
	
	; iteration++
	clc
	lda ITERATION
	adc #1
	sta ITERATION
	lda ITERATION+1
	adc #0
	sta ITERATION+1
	; check if iteration == max_iter
	cmp #MAX_ITER>>8
	beq mandel_check1
	jmp mandel_calc_loop
mandel_check1:
	lda ITERATION
	cmp #MAX_ITER&255
	beq mandel_max_iters
	jmp mandel_calc_loop
mandel_max_iters:
	; max iters exit
	lda #' '
	jsr uart_send
	IF proctype
	bra mandel_calc_loop_exit
	ELSEIF
	clc
	bcc mandel_calc_loop_exit
	ENDIF
mandel_calc_loop_overflow:
	; Overflow exit
	IF proctype
	phx
	ELSEIF
	txa
	pha
	ENDIF
	lda ITERATION
	and #7
	asl
	asl
	asl
	tax
print_loop1:
	inx
	lda mandel_colors,X
	cmp #33
	beq print_loop1_exit
	jsr uart_send
	IF proctype
	bra print_loop1
	ELSEIF
	sec
	bcs print_loop1
	ENDIF
print_loop1_exit:
	lda #'#'
	jsr uart_send
	IF proctype
	plx
	ELSEIF
	pla
	tax
	ENDIF

mandel_calc_loop_exit:
	; End col loop
	iny
	tya
	cmp #M_WIDTH
	beq mandel_col_loop_over
	jmp mandel_loop_cols
mandel_col_loop_over:
	; End row loop
	lda #10
	jsr uart_send
	lda #13
	jsr uart_send
	dex
	beq mandel_row_loop_over
	jmp mandel_loop_rows
mandel_row_loop_over:
	ldy #0
print_loop2:
	lda mandel_color_reset,Y
	beq print_loop2_exit
	iny
	jsr uart_send
	IF proctype
	bra print_loop2
	ELSEIF
	clc
	bcc print_loop2
	ENDIF
print_loop2_exit:

loop:
	jmp loop

mul_8x8:
	IF proctype
	stz mres0
	stz mres1
	stz mtemp0
	ELSEIF
	lda #0
	sta mres0
	sta mres1
	sta mtemp0
	ENDIF
mul_8x8_loop:
	lsr min00
	bcc mul_8x8_no_carry
	clc
	lda mres0
	adc min10
	sta mres0
	lda mres1
	adc mtemp0
	sta mres1
mul_8x8_no_carry:
	asl min10
	rol mtemp0
	lda min00
	bne mul_8x8_loop
	rts
	
mul_32x32:
	IF proctype
	stz mres0
	stz mres1
	stz mres2
	stz mres3
	stz mres4
	stz mres5
	stz mres6
	stz mres7
	phy
	phx
	ELSEIF
	lda #0
	sta mres0
	sta mres1
	sta mres2
	sta mres3
	sta mres4
	sta mres5
	sta mres6
	sta mres7
	tya
	pha
	txa
	pha
	ENDIF
	ldy #0
	ldx #0
mul_32x32_loop:
	tya
	lda min00,Y
	iny
	sta mtemp0
	jsr mul_8x32
	
	clc
	lda mtemp2
	adc mres0,X
	sta mres0,X
	lda mtemp3
	adc mres1,X
	sta mres1,X
	lda mtemp4
	adc mres2,X
	sta mres2,X
	lda mtemp5
	adc mres3,X
	sta mres3,X
	lda mtemp6
	adc mres4,X
	sta mres4,X
	inx
	
	tya
	cmp #4
	bne mul_32x32_loop
	
	IF proctype
	plx
	ply
	ELSEIF
	pla
	tax
	pla
	tay
	ENDIF
	
	rts
	
mul_8x32:
	IF proctype
	stz mtemp1
	stz mtemp2
	stz mtemp3
	stz mtemp4
	stz mtemp5
	stz mtemp6
	ELSEIF
	lda #0
	sta mtemp1
	sta mtemp2
	sta mtemp3
	sta mtemp4
	sta mtemp5
	sta mtemp6
	ENDIF
	lda mtemp0
	bne mul_8x32_nonzero
	rts
mul_8x32_nonzero:
	lda min13
	pha
	lda min12
	pha
	lda min11
	pha
	lda min10
	pha
mul_8x32_loop:
	lsr mtemp0
	bcc mul_8x32_no_carry
	clc
	lda mtemp2
	adc min10
	sta mtemp2
	lda mtemp3
	adc min11
	sta mtemp3
	lda mtemp4
	adc min12
	sta mtemp4
	lda mtemp5
	adc min13
	sta mtemp5
	lda mtemp6
	adc mtemp1
	sta mtemp6
mul_8x32_no_carry:
	asl min10
	rol min11
	rol min12
	rol min13
	rol mtemp1
	lda mtemp0
	bne mul_8x32_loop
mul_8x32_end:
	pla
	sta min10
	pla
	sta min11
	pla
	sta min12
	pla
	sta min13
	rts

mul_fixed_unsigned:
	jsr mul_32x32
	
	lda mres3
	sta mres0
	lda mres4
	sta mres1
	lda mres5
	sta mres2
	lda mres6
	sta mres3
	rts

mul_fixed:
	IF proctype
	stz temp0
	phx
	ELSEIF
	lda #0
	sta temp0
	txa
	pha
	ENDIF
	lda min03
	bpl mul_fixed_not_neg_1
	
	sec
	ldx #0
mul_fixed_inv_loop_0:
	lda min00,X
	eor #255
	adc #0
	sta min00,X
	inx
	txa
	cmp #4
	bne mul_fixed_inv_loop_0
	lda #1
	eor temp0
	sta temp0
	
mul_fixed_not_neg_1:
	lda min13
	bpl mul_fixed_not_neg_2
	
	sec
	ldx #0
mul_fixed_inv_loop_1:
	lda min10,X
	eor #255
	adc #0
	sta min10,X
	inx
	txa
	cmp #4
	bne mul_fixed_inv_loop_1
	lda #1
	eor temp0
	sta temp0
	
mul_fixed_not_neg_2:
	IF proctype
	plx
	ELSEIF
	pla
	tax
	ENDIF
	
	lda temp0
	pha
	jsr mul_32x32
	
	lda mres3
	sta mres0
	lda mres4
	sta mres1
	lda mres5
	sta mres2
	lda mres6
	sta mres3
	
	pla
	beq mul_fixed_not_neg_3
	
	stx temp0
	sec
	ldx #0
mul_fixed_inv_loop_2:
	lda mres0,X
	eor #255
	adc #0
	sta mres0,X
	inx
	txa
	cmp #4
	bne mul_fixed_inv_loop_2
	lda temp0
	tax
	
mul_fixed_not_neg_3:
	IF proctype
	stz mres7
	stz mres6
	stz mres5
	stz mres4
	ELSEIF
	lda #0
	sta mres7
	sta mres6
	sta mres5
	sta mres4
	ENDIF
	rts

div_16x16:
	IF proctype
	stz mres0
	stz mres1
	stz mtemp0
	stz mtemp1
	ELSEIF
	lda #0
	sta mres0
	sta mres1
	sta mtemp0
	sta mtemp1
	ENDIF
	lda #16
	sta mtemp2
div_16x16_loop:
	asl mres0
	rol mres1
	asl min00
	rol min01
	rol mtemp0
	rol mtemp1
	sec
	lda mtemp0
	sbc min10
	lda mtemp1
	sbc min11
	bcc div_16x16_continue
	sec
	lda mtemp0
	sbc min10
	sta mtemp0
	lda mtemp1
	sbc min11
	sta mtemp1
	inc mres0
div_16x16_continue:
	dec mtemp2
	bne div_16x16_loop
	lda mtemp0
	sta rem0
	lda mtemp1
	sta rem1
	rts

div_32x32:
	IF proctype
	stz mres0
	stz mres1
	stz mres2
	stz mres3
	stz mtemp0
	stz mtemp1
	stz mtemp2
	stz mtemp3
	ELSEIF
	lda #0
	sta mres0
	sta mres1
	sta mres2
	sta mres3
	sta mtemp0
	sta mtemp1
	sta mtemp2
	sta mtemp3
	ENDIF
	lda #32
	sta mtemp4
div_32x32_loop:
	asl mres0
	rol mres1
	rol mres2
	rol mres3
	
	asl min00
	rol min01
	rol min02
	rol min03
	rol mtemp0
	rol mtemp1
	rol mtemp2
	rol mtemp3
	
	sec
	lda mtemp0
	sbc min10
	lda mtemp1
	sbc min11
	lda mtemp2
	sbc min12
	lda mtemp3
	sbc min13
	bcc div_32x32_continue
	
	sec
	lda mtemp0
	sbc min10
	sta mtemp0
	lda mtemp1
	sbc min11
	sta mtemp1
	lda mtemp2
	sbc min12
	sta mtemp2
	lda mtemp3
	sbc min13
	sta mtemp3
	
	inc mres0
div_32x32_continue:
	dec mtemp4
	bne div_32x32_loop
	
	lda mtemp0
	sta rem0
	lda mtemp1
	sta rem1
	lda mtemp2
	sta rem2
	lda mtemp3
	sta rem3
	
	rts

div_fixed:
	IF proctype
	phx
	stz temp0
	ELSEIF
	txa
	pha
	lda #0
	sta temp0
	ENDIF
	lda min03
	bpl div_fixed_pos_0
	
	sec
	ldx #0
div_fixed_inv_loop_0:
	lda min00,X
	eor #255
	adc #0
	sta min00,X
	inx
	txa
	cmp #4
	bne div_fixed_inv_loop_0
	lda #1
	eor temp0
	sta temp0
	
div_fixed_pos_0:
	lda min13
	bpl div_fixed_pos_1
	
	sec
	ldx #0
div_fixed_inv_loop_1:
	lda min10,X
	eor #255
	adc #0
	sta min10,X
	inx
	txa
	cmp #4
	bne div_fixed_inv_loop_1
	lda #1
	eor temp0
	sta temp0
	
div_fixed_pos_1:
	IF proctype
	stz mres0
	stz mres1
	stz mres2
	stz mres3
	stz mtemp0
	stz mtemp1
	stz mtemp2
	stz mtemp3
	ELSEIF
	lda #0
	sta mres0
	sta mres1
	sta mres2
	sta mres3
	sta mtemp0
	sta mtemp1
	sta mtemp2
	sta mtemp3
	ENDIF
	lda #56
	sta mtemp4
div_fixed_loop:
	asl mres0
	rol mres1
	rol mres2
	rol mres3
	
	asl min00
	rol min01
	rol min02
	rol min03
	rol mtemp0
	rol mtemp1
	rol mtemp2
	rol mtemp3
	
	sec
	lda mtemp0
	sbc min10
	lda mtemp1
	sbc min11
	lda mtemp2
	sbc min12
	lda mtemp3
	sbc min13
	bcc div_fixed_continue
	
	sec
	lda mtemp0
	sbc min10
	sta mtemp0
	lda mtemp1
	sbc min11
	sta mtemp1
	lda mtemp2
	sbc min12
	sta mtemp2
	lda mtemp3
	sbc min13
	sta mtemp3
	
	inc mres0
div_fixed_continue:
	dec mtemp4
	bne div_fixed_loop
	
	lda temp0
	beq div_fixed_pos_2
	
	sec
	ldx #0
div_fixed_inv_loop_2:
	lda mres0,X
	eor #255
	adc #0
	sta mres0,X
	inx
	txa
	cmp #4
	bne div_fixed_inv_loop_2
	
div_fixed_pos_2:
	IF proctype
	plx
	ELSEIF
	pla
	tax
	ENDIF
	rts

print_num_divs:
	db $01,0,0,0
	db $0A,0,0,0
	db $64,0,0,0
	db $E8,$03,0,0
	db $10,$27,0,0
	db $A0,$86,$01,0
	db $40,$42,$0F,0
	db $80,$96,$98,0
	db 0,$E1,$F5,$05
	db 0,$CA,$9A,$3B
print_num:
	IF proctype
	phx
	phy
	ELSEIF
	txa
	pha
	tya
	pha
	ENDIF
	lda min03
	bpl print_num_pos
	lda #'-'
	jsr uart_send
	sec
	ldx #4
	ldy #0
print_num_inv_loop_0:
	lda min00,Y
	eor #$FF
	adc #0
	sta min00,Y
	iny
	dex
	bne print_num_inv_loop_0
print_num_pos:
	lda #0
	sta temp0
	ldx #10
print_num_loop:
	dex
	
	txa
	asl
	asl
	tay
	
	lda print_num_divs,Y
	sta min10
	iny
	lda print_num_divs,Y
	sta min11
	iny
	lda print_num_divs,Y
	sta min12
	iny
	lda print_num_divs,Y
	sta min13
	
	jsr div_32x32
	lda temp0
	bne print_num_print
	lda mres0
	bne print_num_print
	txa
	beq print_num_print
	jmp print_num_noprint
print_num_print:
	lda mres0
	clc
	adc #'0'
	jsr uart_send
	sta temp0
print_num_noprint:
	lda rem0
	sta min00
	lda rem1
	sta min01
	lda rem2
	sta min02
	lda rem3
	sta min03
	txa
	bne print_num_loop
	
	IF proctype
	ply
	plx
	ELSEIF
	pla
	tay
	pla
	tax
	ENDIF
	rts

print_fixed:
	IF proctype
	phx
	phy
	ELSEIF
	txa
	pha
	tya
	pha
	ENDIF
	lda min03
	bpl print_fixed_pos
	lda #'-'
	jsr uart_send
	sec
	ldx #4
	ldy #0
print_fixed_inv_loop_0:
	lda min00,Y
	eor #$FF
	adc #0
	sta min00,Y
	iny
	dex
	bne print_fixed_inv_loop_0
print_fixed_pos:
	lda min02
	pha
	lda min01
	pha
	lda min00
	pha
	lda min03
	sta min00
	lda #0
	sta min01
	sta min02
	sta min03
	jsr print_num
	lda #'.'
	jsr uart_send
	lda #0
	sta min03
	pla
	sta min00
	pla
	sta min01
	pla
	sta min02
	
	ldx #8
	lda #10
	sta min13
	lda #0
	sta min12
	sta min11
	sta min10
print_fixed_loop:
	jsr mul_fixed
	lda mres3
	clc
	adc #'0'
	jsr uart_send
	lda mres2
	sta min02
	lda mres1
	sta min01
	lda mres0
	sta min00
	dex
	bne print_fixed_loop
	
	IF proctype
	ply
	plx
	ELSEIF
	pla
	tay
	pla
	tax
	ENDIF
	rts

print_hex:
	sta temp0
	tya
	pha
	lda temp0
	pha
	ror
	ror
	ror
	ror
	and #15
	tay
	lda hex_digits,Y
	jsr uart_send
	pla
	and #15
	tay
	lda hex_digits,Y
	jsr uart_send
	pla
	tay
	lda temp0
	rts

sk_led_wait:
	lda ACIA_STATUS_READ
	and #16
	beq sk_led_wait
	ldy #4
sk_led_short_del:
	nop
	nop
	dey
	bne sk_led_short_del
	clc
	bcc sk_led_continue
sk_led_begin:
	IF proctype
	phy
	ELSEIF
	tya
	pha
	ENDIF
	lda ACIA_STATUS_READ
	and #16
	beq sk_led_wait
sk_led_continue:
	lda CMD
	sta sk_backup
	and #%11110010
	ora #8
	sta sk_temp
	bne sk_led_32
sk_led_end:
	IF proctype
	phy
	ELSEIF
	tya
	pha
	ENDIF
	lda CMD
	sta sk_backup
	and #%11110010
	sta sk_temp
sk_led_32:
	ora #1
	sta CMD
	ldy #32
sk_led_32_loop:
	lda sk_temp
	sta CMD
	ora #1
	sta CMD
	dey
	bne sk_led_32_loop
	lda sk_backup
	sta CMD
	IF proctype
	ply
	ELSEIF
	pla
	tay
	ENDIF
	rts

sk_led_byte:
	IF proctype
	phy
	phx
	ELSEIF
	sta sk_backup
	tya
	pha
	txa
	pha
	lda sk_backup
	ENDIF
	tay
	lda CMD
	sta sk_backup
	and #%11110010
	ora #1
	sta sk_temp
	ldx #8
sk_led_byte_loop:
	tya
	asl
	tay
	lda sk_temp
	bcs sk_led_byte_not_zero
	ora #8
sk_led_byte_not_zero:
	sta CMD
	eor #1
	sta CMD
	eor #1
	sta CMD
	dex
	bne sk_led_byte_loop
	lda sk_backup
	sta CMD
	IF proctype
	plx
	ply
	ELSEIF
	pla
	tax
	pla
	tay
	ENDIF
	rts

	; X - LSB
	; Y - MSB
wave_function:
	tya
	cmp #3
	bmi wave_function_no_overflow
	sec
	sbc #3
wave_function_no_overflow:
	cmp #1
	beq wave_function_one
	cmp #2
	beq wave_function_two
wave_function_zero:
	; c = counter
	txa
	rts
wave_function_one:
	; c = 255 - (counter - 256)
	; c = 255 - X
	txa
	eor #$FF
	rts
wave_function_two:
	lda #0
	rts

uart_send:
	pha
	lda #32
	bit ACIA_STATUS_READ
	bne uart_not_connected
	lda #16
uart_send_wait:
	bit ACIA_STATUS_READ
	beq uart_send_wait
	lda #2
	sta irupt_skips
	pla
	sta TXD
	rts
uart_not_connected:
	pla
	rts

m_ins_8x8:
	db 5,6,57,8,233,108,0,3,25,8,255
div_ins_16x16:
	db 1,33,0,25
	db 23,78,3,108
	db 0,28,1,1
	db 200,55,0,0
	db 0,8,0,2
	db 0,2,200,55
	db 200,55,0,88
	db 255
mul_ins_32x32:
	db 0,0,37,200,0,0,245,99
	db 0,23,57,68,0,0,88,69
	db 55,29,87,33,229,1,58,108
	db 0,0,0,0,23,158,10,58
	db 0,0,0,55,23,158,10,58
	db 0,23,57,68,0,0,0,0
	db 255
div_ins_32x32:
	db 0,0,0,200,0,0,0,50
	db 27,38,201,208,0,29,31,0
	db 108,37,19,111,33,11,60,183
	db 108,37,19,111,0,0,0,0
	db 0,0,0,0,33,11,60,183
	db 18,91,102,111,0,37,131,19
	db 255
print_num_ins:
	db $66,$91,0,0
	db $C0,$8B,$A9,$01,0
	db $1A,$47,$6F,$69
	db 1,0,0,0
	db 0,0,0,0
	db $FB,$FF,$FF,$FF
	db 255
hex_digits:
	db "0123456789ABCDEF"
	
mandel_colors:
	db 33,27,91,51,49,109,0,33
	db 33,27,91,51,49,109,0,33
	db 33,27,91,51,50,109,0,33
	db 33,27,91,51,51,109,0,33
	db 33,27,91,51,52,109,0,33
	db 33,27,91,51,53,109,0,33
	db 33,27,91,51,54,109,0,33
	db 33,27,91,51,55,109,0,33
mandel_color_reset:
	db 27,91,48,109
	db "Done."
	db $0D
	db $0A
	db 0
	
	db 'E','O','F'

	org $FFFA
	dw nmi
	dw startup
	dw irupt
