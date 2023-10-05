	org 0
code:
	di
	ld sp,34816
	ld de,text1
	ld b,text1_end-text1
	call print_text
	ld de,text2
	ld b,text2_end-text2
	call print_text
	ld de,text3
	ld b,text3_end-text3
	call print_text
	ld de,text5
	; Using exx here just to test it. Obviously there is a more efficient way to copy this data.
	exx
	ld de,32768
	exx
	ld c,0
copy_loop:
	ld a,(de)
	exx
	ld (de),a
	inc de
	exx
	inc de
	inc c
	ld a,text5_end-text5
	sub c
	jp nz,copy_loop
	ld de,text4
	ld b,text4_end-text4
	call print_text
	ld de,32768
	ld b,text5_end-text5
	call print_text
	
loop_forever:
	nop
	nop
	nop
	nop
	nop
	jp loop_forever
	
print_text:
	ld c,0
print_loop:
	ld a,(de)
	ld (24576),a
	inc de
	inc c
	ld a,b
	sub c
	jp nz,print_loop
	ret
	
data:
text1:
	db "If you can read this, subroutine calls work."
	db &D
	db &A
text1_end:
text2:
	db "If you can read this, the stack works."
	db &D
	db &A
text2_end:
text3:
	db "Copying some text from ROM into RAM..."
	db &D
	db &A
text3_end:
text4:
	db "Printing text from RAM:"
	db &D
	db &A
text4_end:
text5:
	db "What the fuck did you just fucking say about me, you little bitch? I'll have you know I graduated top of my class in the Navy Seals, and I've been involved in numerous secret raids on Al-Quaeda, and I have over 300 confirmed kills. I am trained in g"
	db &D
	db &A
text5_end:
	db 0
