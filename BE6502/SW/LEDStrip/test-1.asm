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
loop:
	jsr start_frame
	
	ldy #NUM_LEDS
leds_loop:
	lda #LED_BRIGHTNESS
	ora #%11100000
	jsr tx_byte
	lda counter
	eor #$FF
	jsr tx_byte
	lda counter
	jsr tx_byte
	tya
	rol
	rol
	jsr tx_byte
	dey
	bne leds_loop
	
	jsr end_frame
	
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

	org $FFFA
	dw nmi
	dw startup
	dw irupt
