m_x1		equ 3+32768
m_x2		equ 4+32768
m_x3		equ 5+32768
m_x4		equ 6+32768

m_y1		equ 7+32768
m_y2		equ 8+32768
m_y3		equ 9+32768
m_y4		equ 10+32768

m_res1		equ 11+32768
m_res2		equ 12+32768
m_res3		equ 13+32768
m_res4		equ 14+32768
m_res_e1	equ 15+32768
m_res_e2	equ 16+32768
m_res_e3	equ 17+32768

temp		equ 18+32768
temp2		equ 19+32768
	
	org 0
	di
	ld sp,34816
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
code:
	
	ld a,6
	ld (m_x1),a
	ld a,1
	ld (m_x2),a
	ld a,8
	ld (m_x3),a
	ld a,0
	ld (m_x4),a
	
	ld a,3
	ld (m_y1),a
	ld a,6
	ld (m_y2),a
	ld a,7
	ld (m_y3),a
	ld a,0
	ld (m_y4),a
	
	call mul32
	ld hl,m_res1
	call print_bignum
	
	;ld a,155
	;ld (m_x1),a
	;ld a,2
	;ld (m_x2),a
	;ld a,1
	;ld (m_x3),a
	;ld a,155
	;ld (m_x4),a
	
	ld a,&65
	ld (m_x1),a
	ld a,&fd
	ld (m_x2),a
	ld a,&fe
	ld (m_x3),a
	ld a,&64
	ld (m_x4),a
	
	ld a,3
	ld (m_y1),a
	ld a,6
	ld (m_y2),a
	ld a,0
	ld (m_y3),a
	ld a,0
	ld (m_y4),a
	
	call mul32
	ld hl,m_res1
	call print_bignum
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	
	call delay
	call delay
	call delay
	jp code
	
delay:
	ld a,255
delay_loop:
	sub 1
	ret z
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	jp delay_loop
	
print_num:
	ld d,a
	and &F0
	srl a
	srl a
	srl a
	srl a
	add '0'
	cp ':'
	jp c,aaaa_1
	add 7
aaaa_1:
	ld (24576),a
	
	ld a,d
	and &0F
	add '0'
	cp ':'
	jp c,aaaa_2
	add 7
aaaa_2:
	ld (24576),a
	ld a,' '
	ld (24576),a
	ret

print_bignum:
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	call print_num
	dec hl
	ld a,(hl)
	call print_num
	dec hl
	ld a,(hl)
	call print_num
	dec hl
	ld a,(hl)
	call print_num
	dec hl
	ld a,(hl)
	call print_num
	dec hl
	ld a,(hl)
	call print_num
	dec hl
	ld a,(hl)
	call print_num
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	ret
	
	;18 s
	;6.5 s
mul32:
	ld a,0
	ld (m_res1),a
	ld (m_res2),a
	ld (m_res3),a
	ld (m_res4),a
	ld (m_res_e1),a
	ld (m_res_e2),a
	ld (m_res_e3),a
	ld b,0
	ld a,(m_x4)
	bit 7,a
	jp z,x_not_negative
	ld hl,(m_x1)
	ld de,(m_x3)
	ld a,l
	cpl
	add 1
	ld (m_x1),a
	ld a,h
	cpl
	adc 0
	ld (m_x2),a
	ld a,e
	cpl
	adc 0
	ld (m_x3),a
	ld a,d
	cpl
	adc 0
	ld (m_x4),a
	ld b,1
x_not_negative:
	ld a,(m_y4)
	bit 7,a
	jp z,y_not_negative
	ld hl,(m_y1)
	ld de,(m_y3)
	ld a,l
	cpl
	add 1
	ld (m_y1),a
	ld a,h
	cpl
	adc 0
	ld (m_y2),a
	ld a,e
	cpl
	adc 0
	ld (m_y3),a
	ld a,d
	cpl
	adc 0
	ld (m_y4),a
	ld a,b
	xor 1
	ld b,a
y_not_negative:
	ld a,b
	ld (temp2),a
	
	ld b,33
mul32_loop:
	djnz mul32_no_return
	ld a,(temp2)
	bit 0,a
	ret z
	; Result is negative
	ld hl,(m_res1)
	ld de,(m_res3)
	ld a,l
	cpl
	add 1
	ld (m_res1),a
	ld a,h
	cpl
	adc 0
	ld (m_res2),a
	ld a,e
	cpl
	adc 0
	ld (m_res3),a
	ld a,d
	cpl
	adc 0
	ld (m_res4),a
	ld hl,(m_res_e1)
	ld a,l
	cpl
	adc 0
	ld (m_res_e1),a
	ld a,h
	cpl
	adc 0
	ld (m_res_e2),a
	ld a,(m_res_e3)
	cpl
	adc 0
	ld (m_res_e3),a
	ret
mul32_no_return:
	
	ld hl,(m_x1)
	ld de,(m_x3)
	sla l
	rl h
	rl e
	rl d
	ld (m_x1),hl
	ld (m_x3),de
	jp nc,mul32_loop
	
	ld a,b ; Backup b
	ld (temp),a
	ld hl,(m_y1)
	ld de,(m_y3)
	ld c,0
	exx
	ld hl,0
	exx
	dec b
	jp z,shift_loop32_end
shift_loop32:
	sla l
	rl h
	rl e
	rl d
	rl c
	exx
	rl l
	rl h
	exx
	dec b
	jp nz,shift_loop32
shift_loop32_end:
	
	ld a,(temp) ; Restore backup b
	ld b,a
	ld a,(m_res1)
	add l
	ld (m_res1),a
	ld a,(m_res2)
	adc h
	ld (m_res2),a
	ld hl,(m_res3)
	ld a,l
	adc e
	ld (m_res3),a
	ld a,h
	adc d
	ld (m_res4),a
	ld a,(m_res_e1)
	adc c
	ld (m_res_e1),a
	exx
	ld de,(m_res_e2)
	ld a,e
	adc l
	ld (m_res_e2),a
	ld a,d
	adc h
	ld (m_res_e3),a
	exx
	
	jp mul32_loop
