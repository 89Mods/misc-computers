#include <stdio.h>

#include "z80io.h"

const char textBuff[32];

void main(void) {
	setOut(0);
	puts("BEANS!\r\n");
	
	float pi = 0;
	float fiba = 1;
	for(short t = 0; t < 8192; t++) {
		pi += 1.0 / fiba;
		fiba += 2;
		pi -= 1.0 / fiba;
		fiba += 2;
	}
	pi = pi * 4.0;
	sprintf(textBuff, "%f\r\n", pi);
	puts(textBuff);
	fiba = 2.0 * pi * 6357.0;
	sprintf(textBuff, "%f\r\n", fiba);
	puts(textBuff);
	
	setOut(0xAA);
	while(1) {
		while(!digitalIn(1));
		setOut(0x55);
		while(digitalIn(1));
		while(!digitalIn(1));
		setOut(0xAA);
		while(digitalIn(1));
	}
}
