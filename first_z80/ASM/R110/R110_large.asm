mem_start	equ 32768
mem_end		equ 34816

state_len		equ 64
state_arr_start equ mem_start
res_arr_start	equ mem_start+state_len

	org 0
code:
pattern_init:
	di
	ld sp,mem_end
	
	; Clear memory
	ld hl,mem_start
	ld de,mem_start+1
	ld (hl),0
	ld bc,512
	ldir
	
	;Init pattern
	ld hl,pattern_init
	ld de,state_arr_start
	ld bc,state_len
	ldir
	
rule_loop_setup:
	ld a,'|'
	ld (24576),a
	ld b,state_len
	ld hl,state_arr_start
state_print_loop:
	ld a,(hl)
	inc hl
	call print_byte
	djnz state_print_loop
	ld a,'|'
	ld (24576),a
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	
	ld hl,res_arr_start
	ld de,res_arr_start+1
	ld (hl),0
	ld bc,state_len
	ldir
	
	ld de,state_len
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld a,e
	sub 2
	ld e,a
	ld a,d
	sbc 0
	ld d,a
rule_loop:
	ld hl,rule_table
	ld a,(state_arr_start+state_len-1)
	and 7
	add l
	ld l,a
	ld a,(hl)
	sra a
	ld a,(res_arr_start)
	rr a
	ld (res_arr_start),a
	ld b,state_len-1
	ld hl,res_arr_start+1
shift_loop_1:
	rr (hl)
	inc hl
	djnz shift_loop_1
	ld b,state_len
	ld hl,state_arr_start
	xor a
shift_loop_2:
	rr (hl)
	inc hl
	djnz shift_loop_2
	
	dec de
	ld a,e
	sub 1
	ld a,d
	sbc 0
	jp nc,rule_loop
	
	ld b,state_len
	ld hl,res_arr_start
	xor a
shift_loop_3:
	rr (hl)
	inc hl
	djnz shift_loop_3
	
	ld a,(res_arr_start+state_len-1)
	and 254
	ld l,a
	ld a,(rule_table+7)
	add l
	ld (res_arr_start+state_len-1),a
	
	ld hl,res_arr_start
	ld de,state_arr_start
	ld bc,state_len
	ldir
	
	jp rule_loop_setup
	
print_byte:
	ld d,a
	ld e,127
print_byte_loop:
	ld a,' '
	sla d
	jr nc,print_byte_loop_not_set
	ld a,&E2
	ld (24576),a
	ld a,&96
	ld (24576),a
	ld a,&88
print_byte_loop_not_set:
	ld (24576),a
	sra e
	jr c,print_byte_loop
	ret
	
	org 240
data:
rule_table:
	db 0,1,1,1,0,1,1,0
