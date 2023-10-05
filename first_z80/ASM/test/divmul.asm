m_x		equ 3+32768
d_x		equ 3+32768
m_y		equ 4+32768
d_y		equ 4+32768
m_res	equ 5+32768
d_res	equ 5+32768
	
	org 0
code:
	di
	ld sp,34816
	ld a,6
	ld (m_x),a
	ld a,9
	ld (m_y),a
	call mul
	ld a,(m_res)
	and &F0
	srl a
	srl a
	srl a
	srl a
	add '0'
	ld (24576),a
	
	ld a,(m_res)
	and &0F
	add '0'
	ld (24576),a
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	
	ld a,(m_res)
	and &0F
	sla a
	sla a
	sla a
	sla a
	ld (18432),a
	call delay
	
	ld a,(m_res)
	and &F0
	or 8
	ld (18432),a
	call delay
	ld a,0
	ld (18432),a
	
	ld a,52
	ld (d_x),a
	ld a,3
	ld (d_y),a
	call div
	ld a,(d_res)
	and &F0
	srl a
	srl a
	srl a
	srl a
	add '0'
	ld (24576),a
	
	ld a,(d_res)
	and &0F
	add '0'
	ld (24576),a
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	
	ld a,(d_res)
	and &0F
	or 8
	sla a
	sla a
	sla a
	sla a
	ld (18432),a
	
	ld a,(d_res)
	and &F0
	ld (18432),a
	call delay
	call delay
	ld a,0
	ld (18432),a
	
halt:
	nop
	nop
	nop
	jp halt
	
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
	
	;18 s
	;6.5 s
mul:
	ld a,0
	ld (m_res),a
	ld b,9
	ld a,(m_x)
	ld h,a
mul_loop:
	djnz mul_no_return
	ret
mul_no_return:
	;ld a,b
	;add '0'
	;ld (24576),a
	
	sla h
	jp nc,mul_loop
	
	ld l,b
	ld a,(m_y)
	dec b
	jp z,shift_loop_end
shift_loop:
	add a
	dec b
	jp nz,shift_loop
shift_loop_end:
	
	ld b,l
	ld l,a
	ld a,(m_res)
	add l
	ld (m_res),a
	
	jp mul_loop

div:
	ld d,0
	ld h,0
	ld b,9
	ld a,(d_x)
	ld l,a
div_loop:
	djnz div_no_return
	ld a,d
	ld (d_res),a
	ret
div_no_return:
	;ld a,b
	;add '0'
	;ld (24576),a
	
	sla d
	
	sla l
	rl h
	ld a,h
	
	ld e,a
	ld a,(d_y)
	cp e
	jp z,test
	jp nc,div_loop
test:
	
	ld e,a
	ld a,h
	sub e
	ld h,a
	
	inc d
	
	jp div_loop
