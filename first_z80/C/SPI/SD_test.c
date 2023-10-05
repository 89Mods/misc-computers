#include <stdio.h>
#include <string.h>

#include "z80io.h"
#include "SD.h"

char textBuff[48];

char toHex(unsigned char a) {
	if(a < 10) return '0' + a;
	return 'A' + (a - 10);
}

void main(void) {
	asm("di");
	SPIdeselect();
	
	char err_ret = SDinit();
	sprintf(textBuff, "0x%02x\r\n", err_ret);
	puts(textBuff);
	if(err_ret != 0) while(1) asm("nop");
	float size = (float)SDsize() / 2.0f / 1024.0f / 1024.0f;
	sprintf(textBuff, "SD capacity: %fGB\r\n", size);
	puts(textBuff);
	
	err_ret = SDbeginRead(2048);
	sprintf(textBuff, "0x%02x\r\n", err_ret);
	puts(textBuff);
	if(err_ret != 0) while(1) asm("nop");
	for(int i = 0; i < 512; i++) {
		err_ret = SDreadByte();
		putchar(toHex((err_ret & 0xF0) >> 4));
		putchar(toHex(err_ret & 0x0F));
		putchar(' ');
		if(((i + 1) & 15) == 0) {
			putchar('\r');
			putchar('\n');
		}
	}
	
	while(1) {
		asm("nop");
	}
}
