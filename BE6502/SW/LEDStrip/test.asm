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

CKI equ (1<<0)
SDI equ (1<<1)
NUM_LEDS equ 30
; 0 = OFF
; 31 = FULL BRIGHTNESS
LED_BRIGHTNESS equ 10

led_time_lo equ 248
led_time_hi equ 249
led_loop_counter equ 250
led_counter_lo equ 251
led_counter_hi equ 252
counter_direction equ 253
counter equ 254
led_temp equ 255

	org $8000
irupt:
	rti
nmi:
	rti
startup:
	sei
	cld
	ldx #$FF
	txs
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
	
	lda #CKI|SDI
	sta DDRB
	lda #3
	sta DDRA
	lda #0
	sta PORTB
	
	lda #0
	sta counter
	sta counter_direction
	sta led_counter_hi
	sta led_counter_lo
	sta led_time_hi
	sta led_time_lo
loop:
	jsr start_frame
	
	ldy #NUM_LEDS
	lda led_time_lo
	sta led_counter_lo
	lda led_time_hi
	sta led_counter_hi
leds_loop:
	lda #LED_BRIGHTNESS
	ora #%11100000
	jsr tx_byte
	
	sty led_loop_counter
	
	ldx led_counter_lo
	ldy led_counter_hi
	jsr wave_function
	jsr tx_byte
	
	ldx led_counter_lo
	ldy led_counter_hi
	iny
	jsr wave_function
	jsr tx_byte
	
	ldx led_counter_lo
	ldy led_counter_hi
	iny
	iny
	jsr wave_function
	jsr tx_byte
	
	clc
	lda led_counter_lo
	adc #60
	sta led_counter_lo
	lda led_counter_hi
	adc #0
	cmp #3
	bmi leds_loop_no_overflow
	lda #0
leds_loop_no_overflow:
	sta led_counter_hi
	
	ldy led_loop_counter
	dey
	bne leds_loop
	
	jsr end_frame
	
	clc
	lda led_time_lo
	adc #7
	sta led_time_lo
	lda led_time_hi
	adc #0
	cmp #3
	bmi led_time_no_overflow
	lda #0
led_time_no_overflow:
	sta led_time_hi
	
	inc PORTA
	lda counter_direction
	beq counter_down
	inc counter
	bne counter_up
	dec counter
	jmp direction_change
counter_down:
	dec counter
	beq direction_change
counter_up:
	jmp no_direction_change
	
direction_change:
	lda counter_direction
	eor #1
	sta counter_direction
no_direction_change:
	
	ldy #255
short_del:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dey
	bne short_del
	jmp loop

start_frame:
	tya
	pha
	lda PORTB
	and #~(CKI|SDI)
	sta PORTB
frame_loop:
	ldy #32
start_frame_loop:
	ora #CKI
	sta PORTB
	and #~CKI
	sta PORTB
	dey
	bne start_frame_loop
	pla
	tay
	rts

end_frame:
	tya
	pha
	lda PORTB
	and #~CKI
	ora #SDI
	sta PORTB
	jmp frame_loop

tx_byte:
	sta led_temp
	tya
	pha
	txa
	pha
	lda PORTB
	and #~(CKI|SDI)
	sta PORTB
	ldy led_temp
	ldx #8
tx_byte_loop:
	tya
	asl
	tay
	lda PORTB
	bcc tx_bit_zero
	ora #SDI
tx_bit_zero:
	sta PORTB
	ora #CKI
	sta PORTB
	and #~(CKI|SDI)
	sta PORTB
	dex
	bne tx_byte_loop
	pla
	tax
	pla
	tay
	rts

	; X - LSB
	; Y - MSB
wave_function:
	tya
	; ---- Not initially
	cmp #3
	bmi wave_function_no_overflow
	sec
	sbc #3
wave_function_no_overflow:
	; ----
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

	org $FFFA
	dw nmi
	dw startup
	dw irupt
