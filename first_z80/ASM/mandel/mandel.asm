mem_start	equ 32768
mem_end		equ 34816

m_res1		equ 0+mem_start
m_res2		equ 1+mem_start
m_res3		equ 2+mem_start
m_res4		equ 3+mem_start
m_res_e1	equ 4+mem_start
m_res_e2	equ 5+mem_start
m_res_e3	equ 6+mem_start

mul_opt		equ 7+mem_start
temp		equ 8+mem_start
res_addr1	equ 9+mem_start
res_addr2	equ 10+mem_start

; Variables
c1			equ 11+mem_start
c2			equ 15+mem_start
c3			equ 19+mem_start
c4			equ 23+mem_start
curr_row	equ 27+mem_start
curr_col	equ 28+mem_start
c_im		equ 29+mem_start
c_re		equ 33+mem_start
man_x		equ 37+mem_start
man_y		equ 41+mem_start
man_xx		equ 45+mem_start
man_yy		equ 49+mem_start
iteration	equ 53+mem_start

; Pre-computed constants for w=238, h=48
width		equ 238
height		equ 48
c1_pre		equ 1101
c4_pre		equ 2730
w_d2		equ 119
h_d2		equ 24

; Settings
;zoom		equ 436208
;re			equ 4292282941
;imag		equ 17456693
;max_iter	equ 128
;zoom		equ 671
;re			equ 4291022535
;imag		equ 13878365
;max_iter	equ 2048
zoom		equ 20971520
re			equ 0
imag		equ 0
max_iter	equ 96

	org 0
code:
	di
	ld sp,mem_end
	
	ld de,mandel_chars
	ld b,18
	call print_text
	
	; Clear memory
	ld hl,mem_start
	ld de,mem_start+1
	ld (hl),0
	ld bc,mem_end-mem_start
	ldir
	
	ld l,0
	ld h,c1_pre&255
	ld e,c1_pre>>8
	ld d,0
	exx
	ld hl,zoom&65535
	ld de,zoom>>16
	exx
	ld bc,c1
	call mem_mul32
	ld hl,c1
	call print_bignum
	
	ld l,0
	ld h,c4_pre&255
	ld e,c4_pre>>8
	ld d,0
	exx
	ld hl,zoom&65535
	ld de,zoom>>16
	exx
	ld bc,c4
	call mem_mul32
	ld hl,c4
	call print_bignum
	
	ld hl,(c1)
	ld de,(c1+2)
	exx
	ld hl,0
	ld e,0
	ld d,w_d2
	exx
	ld bc,c2
	call mem_mul32
	ld hl,c2
	call print_bignum
	
	ld hl,(c4)
	ld de,(c4+2)
	exx
	ld hl,0
	ld e,0
	ld d,h_d2
	exx
	ld bc,c3
	call mem_mul32
	ld hl,c3
	call print_bignum
	
	ld a,255
	ld (curr_row),a
row_loop:
;	ld a,(curr_row)
;	bit 0,a
;	ld a,0
;	jp z,no_set_led
;	ld a,1
;no_set_led:
;	ld (18432),a
	ld a,1
	ld (mul_opt),a
	ld a,(curr_row)
	inc a
	ld (18432),a
	;
	ld hl,(c4)
	ld de,(c4+2)
	exx
	ld hl,0
	ld e,0
	ld d,a
	exx
	ld bc,c_im
	call mem_mul32
	ld a,0
	ld (mul_opt),a
	ld hl,(c_im)
	ld de,imag&65535
	add hl,de
	ld (c_im),hl
	ld hl,(c_im+2)
	ld de,imag>>16
	adc hl,de
	ld (c_im+2),hl
	ld hl,(c3)
	ld de,(c3+2)
	ld a,(c_im+0)
	sub l
	ld (c_im+0),a
	ld a,(c_im+1)
	sbc h
	ld (c_im+1),a
	ld a,(c_im+2)
	sbc e
	ld (c_im+2),a
	ld a,(c_im+3)
	sbc d
	ld (c_im+3),a
	; All of this just to calculate c_im = imag + (row * c4) - c3. Fucking hell.
	
	ld a,255
	ld (curr_col),a
col_loop:
	;
	ld a,1
	ld (mul_opt),a
	ld a,(curr_col)
	inc a
	ld hl,(c1)
	ld de,(c1+2)
	exx
	ld hl,0
	ld e,0
	ld d,a
	exx
	ld bc,c_re
	call mem_mul32
	ld a,0
	ld (mul_opt),a
	ld hl,(c_re)
	ld de,re&65535
	add hl,de
	ld (c_re),hl
	ld hl,(c_re+2)
	ld de,re>>16
	adc hl,de
	ld (c_re+2),hl
	ld hl,(c2)
	ld de,(c2+2)
	ld a,(c_re+0)
	sub l
	ld (c_re+0),a
	ld a,(c_re+1)
	sbc h
	ld (c_re+1),a
	ld a,(c_re+2)
	sbc e
	ld (c_re+2),a
	ld a,(c_re+3)
	sbc d
	ld (c_re+3),a
	; c_re = re + (col * c1) - c2
	
	ld hl,c_im
	ld de,man_y
	ldi
	ldi
	ldi
	ldi
	ld de,man_x
	ldi
	ldi
	ldi
	ldi
	ld hl,0
	ld (iteration),hl
calc_loop:
	ld hl,(man_x)
	ld de,(man_x+2)
	exx
	ld hl,(man_x)
	ld de,(man_x+2)
	exx
	ld bc,man_xx
	call mem_mul32
	
	ld hl,(man_y)
	ld de,(man_y+2)
	exx
	ld hl,(man_y)
	ld de,(man_y+2)
	exx
	ld bc,man_yy
	call mem_mul32
	
	ld hl,(man_xx)
	ld de,(man_yy)
	add hl,de
	ld hl,(man_xx+2)
	ld de,(man_yy+2)
	adc hl,de
	ld a,h
	cp 4
	jp nc,calc_loop_exit_escaped
	
	ld hl,(man_x)
	ld de,(man_x+2)
	exx
	ld hl,(man_y)
	ld de,(man_y+2)
	exx
	ld bc,man_y
	call mem_mul32
	
	ld hl,(man_y)
	ld de,hl
	add hl,de
	ld bc,hl
	ld hl,(man_y+2)
	ld de,hl
	adc hl,de
	ld de,hl
	
	ld hl,(c_im)
	add hl,bc
	ld (man_y),hl
	ld hl,(c_im+2)
	adc hl,de
	ld (man_y+2),hl
	
	ld hl,(man_yy)
	ld a,(man_xx+0)
	sub l
	ld c,a
	ld a,(man_xx+1)
	sbc h
	ld b,a
	ld hl,(man_yy+2)
	ld a,(man_xx+2)
	sbc l
	ld e,a
	ld a,(man_xx+3)
	sbc h
	ld d,a
	
	ld hl,(c_re)
	add hl,bc
	ld (man_x),hl
	ld hl,(c_re+2)
	adc hl,de
	ld (man_x+2),hl
	
	ld hl,(iteration)
	inc hl
	ld (iteration),hl
	ld de,max_iter
	ld a,e
	sub l
	ld a,d
	sbc h
	jp nc,calc_loop
calc_loop_exit_max_iters:
	ld a,' '
	ld (24576),a
	jp calc_loop_end
calc_loop_exit_escaped:
	;ld hl,(iteration)
	;sra h
	;rr l
	;sra h
	;rr l
	;sra h
	;rr l
	;sra h
	;rr l
	;sra h
	;rr l
	
	ld a,(iteration)
	and 15
	ld (iteration),a
	and 7
	add a
	add a
	add a
	ld l,a
	ld h,0
	ld de,mandel_colors
	add hl,de
	ld de,24576
	
	ld a,(hl)
	inc hl
	ld (de),a
	ld a,(hl)
	inc hl
	ld (de),a
	ld a,(hl)
	inc hl
	ld (de),a
	ld a,(hl)
	inc hl
	ld (de),a
	ld a,(hl)
	inc hl
	ld (de),a
	ld a,(hl)
	inc hl
	ld (de),a
	
	;ld hl,mandel_chars
	;ld de,(iteration)
	;ld d,0
	;add hl,de
	;ld a,(hl)
	;ld (24576),a
	ld hl,24576
	ld (hl),&E2
	ld (hl),&96
	ld (hl),&88
calc_loop_end:
; Col loop end
	ld a,(curr_col)
	inc a
	ld (curr_col),a
	cp width-1
	jp nz,col_loop
; Row loop end
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	ld a,(curr_row)
	inc a
	ld (curr_row),a
	cp height-1
	jp nz,row_loop
	
	ld de,mandel_color_reset
	ld b,5
	call print_text
	ld de,text1
	ld b,text1_end-text1
	call print_text
	
halt:
	ld a,&55
	ld (18432),a
	ld b,a
	call delay_loop
	ld a,b
	cpl
	ld (18432),a
	call delay_loop
	jp halt
	
delay:
	ld hl,1024
delay_loop:
	nop
	nop
	nop
	nop
	nop
	dec hl
	ld a,0
	sub l
	ld a,0
	sbc h
	jp c,delay_loop
	ret
	
mem_mul32:
	ld (res_addr1),bc
	call mul32
	ld hl,m_res4
	ld de,(res_addr1)
	ldi
	ldi
	ldi
	ldi
	ret

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
	ld a,(mul_opt)
	bit 0,a
	jp nz,unsigned_mul32
	ld a,d
	bit 7,a
	jp z,x_not_negative
	ld a,l
	cpl
	add 1
	ld l,a
	ld a,h
	cpl
	adc 0
	ld h,a
	ld a,e
	cpl
	adc 0
	ld e,a
	ld a,d
	cpl
	adc 0
	ld d,a
	ld b,1
x_not_negative:
	exx
	ld a,d
	bit 7,a
	exx
	jr z,y_not_negative
	exx
	ld a,l
	cpl
	add 1
	ld l,a
	ld a,h
	cpl
	adc 0
	ld h,a
	ld a,e
	cpl
	adc 0
	ld e,a
	ld a,d
	cpl
	adc 0
	ld d,a
	exx
	ld a,b
	xor 1
	ld b,a
y_not_negative:
unsigned_mul32:
	ld a,b
	ld (temp),a
	
	;hlde contains x
	;hl'de' contains y
	ld b,32
	ld c,0
	exx
	ld bc,0
	exx
mul32_loop:
	sra d
	rr e
	rr h
	rr l
	jr nc,mul32_add_end
	
	exx
	ld a,(m_res1)
	add l
	ld (m_res1),a
	ld a,(m_res2)
	adc h
	ld (m_res2),a
	ld a,(m_res3)
	adc e
	ld (m_res3),a
	ld a,(m_res4)
	adc d
	ld (m_res4),a
	ld a,(m_res_e1)
	adc c
	ld (m_res_e1),a
	ld a,(m_res_e2)
	adc b
	ld (m_res_e2),a
	exx
	ld a,(m_res_e3)
	adc c
	ld (m_res_e3),a
mul32_add_end:
	exx
	sla l
	rl h
	rl e
	rl d
	rl c
	rl b
	exx
	rl c
	djnz mul32_loop
	
	ld a,(temp)
	bit 0,a
	ret z
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
	
print_text:
	ld c,0
print_loop:
	ld a,(de)
	ld (24576),a
	inc de
	inc c
	ld a,b
	cp c
	jp nz,print_loop
	ret
	
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

data:
mandel_chars:
	db "..--:=itIJYVXRB#"
	db &D
	db &A
mandel_colors:
	db 27,91,51,49,109,0,0,0
	db 27,91,51,49,109,0,0,0
	db 27,91,51,50,109,0,0,0
	db 27,91,51,51,109,0,0,0
	db 27,91,51,52,109,0,0,0
	db 27,91,51,53,109,0,0,0
	db 27,91,51,54,109,0,0,0
	db 27,91,51,55,109,0,0,0
mandel_color_reset:
	db 27,91,48,109,0
text1:
	db &D
	db &A
	db "Done!"
	db &D
	db &A
text1_end:
	db 0
