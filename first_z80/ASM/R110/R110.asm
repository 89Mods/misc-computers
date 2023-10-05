mem_start	equ 32768
mem_end		equ 34816

	org 0
code:
	di
	ld sp,mem_end
	
	ld de,13653 ; Automaton state in de,bc
	ld bc,35789
	ld hl,rule_table
	
rule_loop_setup:
	exx
	ld l,30
	ld de,0
	ld bc,0
	exx
	
	ld a,'|'
	ld (24576),a
	ld h,d
	ld ix,print_ret_1
	jr print
print_ret_1:
	ld h,e
	ld ix,print_ret_2
	jr print
print_ret_2:
	ld h,b
	ld ix,print_ret_3
	jr print
print_ret_3:
	ld h,c
	ld ix,print_ret_4
	jr print
print_ret_4:
	ld a,'|'
	ld (24576),a
	ld a,&D
	ld (24576),a
	ld a,&A
	ld (24576),a
	ld hl,rule_table
	
rule_loop:
	ld a,c
	and 7
	add l
	ld l,a
	ld a,(hl)
	ld l,rule_table&255
	sra a
	exx
	rr d
	rr e
	rr b
	rr c
	
	dec l
	ld a,l
	cp 0
	jr z,rule_loop_exit
	exx
	sra d
	rr e
	rr b
	rr c
	jr rule_loop
rule_loop_exit:
	xor a
	rr d ; One final time
	rr e
	rr b
	rr c
	ld a,c
	and 254 ; Clear bit 0
	ld l,a
 	ld a,(rule_table+7)
	add l
	ld c,a ; Set bit 0 according to pattern 7 of the rule
	jr rule_loop_setup
	
print:
	ld l,127
print_loop:
	ld a,' '
	sla h
	jr nc,print_loop_not_set
	ld a,&E2
	ld (24576),a
	ld a,&96
	ld (24576),a
	ld a,&88
print_loop_not_set:
	ld (24576),a
	sra l
	jr c,print_loop
	jp (ix)
	
	;org 164
data:
rule_table:
	db 0,1,1,1,0,1,1,0
