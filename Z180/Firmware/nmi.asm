org 0x0066
nmi:
	push af
	; Stop cascading NMIs!
	ld a,(0x1003)
	cp 0
	jp nz, panic
	ld a,88
	ld (0x1003),a
	push bc
	push de
	push hl
	push ix
	push iy
	; Check if user-defined nmi handler is present
	; Should be a jump instruction with non-zero target
	; Allows disabling of NMI handling by doing set_nmi_handler(NULL);
	ld hl,0x1000
	ld a,(hl)
	xor 0xC3
	jp nz,no_handler
	inc hl
	ld a,(hl)
	inc hl
	or a,(hl)
	call nz,0x1000
no_handler:
	xor a
	ld (0x1003),a
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	retn
panic:
	pop af
	ret
