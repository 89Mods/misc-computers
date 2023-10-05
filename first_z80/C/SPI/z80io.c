#include "z80io.h"
#include <string.h>
#include <stdio.h>
#include <math.h>

const unsigned char* gpioPntr = (unsigned char*)18432;
const unsigned char* ttyPntr = (unsigned char*)24576;
static unsigned char OUTPUT_VAL = 0;

int putchar(int c) __preserves_regs(d,e,b,c,iyl,iyh) __z88dk_fastcall __naked {
#asm
	ld a,l
	ld (24576),a
	ld hl,1
	ret
#endasm
}

int puts(char *c) __preserves_regs(d,e,b,c,iyl,iyh) __z88dk_fastcall __naked {
#asm
puts_loop:
	ld a,(hl)
	cp 0
	jr z,puts_loop_end
	ld (24576),a
	inc hl
	jr puts_loop
puts_loop_end:
	ld hl,1
	ret
#endasm
}

void setOut(unsigned char x) __preserves_regs(d,e,b,c,iyl,iyh) __z88dk_fastcall __naked {
#asm
	ld a,l
	ld (18432),a
	ld (_OUTPUT_VAL),a
	ret
#endasm
}

unsigned char getIn() __preserves_regs(d,e,b,c,iyl,iyh) __naked {
#asm
	ld a,(18432)
	cpl
	and 15
	ld h,0
	ld l,a
	ret
#endasm
}

void digitalOut(char bit, char state) {
	OUTPUT_VAL &= ~(1 << bit);
	if(state) OUTPUT_VAL |= (1 << bit);
	setOut(OUTPUT_VAL);
}

char digitalIn(char bit) {
	return (getIn() & (1 << bit)) != 0;
}

void delay(short len) {
	for(short i = 0; i < len; i++) asm("nop");
}

void SPItransfer(unsigned char x) __preserves_regs(d,e,b,c,iyl,iyh) __z88dk_fastcall __naked {
#asm
	ld a,(_OUTPUT_VAL)
	and 252
	or 2
	ld h,a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	ld a,0
	sla l
	adc a
	or h
	ld (18432),a
	and 253
	ld (18432),a
	
	nop
	nop
	nop
	ld a,h
	and 253
	ld (18432),a
	
	ret
#endasm
}

unsigned char SPIreceive() __preserves_regs(b,iyl,iyh) __naked {
#asm
	ld a,(_OUTPUT_VAL)
	and 252
	or 1
	ld (18432),a
	ld d,a
	ld e,l
	ld hl,18432
	ld a,0
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	
	res 1,d
	ld (hl),d
	ld c,(hl)
	set 1,d
	ld (hl),d
	sra c
	rla
	res 1,d
	ld (hl),d
	
	cpl
	ld l,a
	ld h,0
	ret
#endasm
}

void SPIselect() __preserves_regs(d,e,b,c,iyl,iyh) __naked {
#asm
	ld a,(_OUTPUT_VAL)
	and 251
	ld (18432),a
	ld (_OUTPUT_VAL),a
	ret
#endasm
}

void SPIdeselect() __preserves_regs(d,e,b,c,iyl,iyh) __naked {
#asm
	ld a,(_OUTPUT_VAL)
	or 4
	ld (18432),a
	ld (_OUTPUT_VAL),a
	ret
#endasm
}
