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
led_header equ $EE

; Memory locations

port_counter equ 0
delay_counter equ 1
led_counter_lo equ 2
led_counter_hi equ 3
led_loop_counter equ 4
led_time_lo equ 5
led_time_hi equ 6
irupt_skips equ 7

sk_backup equ 254
sk_temp equ 255

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
	sta sk_backup
	lda sk_temp
	sec
	sbc sk_backup
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
	sta sk_backup
	lda sk_temp
	sec
	sbc sk_backup
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
	sta sk_backup
	lda sk_temp
	sec
	sbc sk_backup
	clc
	adc #$1F
	jsr sk_led_byte
	lda led_counter_lo
	clc
	adc #55
	sta led_counter_lo
	lda led_counter_hi
	adc #0
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
	lda #$03
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
loop:
	lda #0
delay_outer:
	sta delay_counter
delay_inner:
	nop
	nop
	nop
	nop
	clc
	adc #1
	bne delay_inner
	lda delay_counter
	clc
	adc #1
	bne delay_outer
	
	lda port_counter
	ror
	ror
	clc
	and #7
	adc #'0'
	jsr uart_send

	jmp loop

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

	org $FFFA
	dw nmi
	dw startup
	dw irupt
