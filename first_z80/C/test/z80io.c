#include "z80io.h"
#include <string.h>
#include <stdio.h>
#include <math.h>

const unsigned char* gpioPntr = (unsigned char*)18432;
const unsigned char* ttyPntr = (unsigned char*)24576;
static unsigned char OUTPUT_VAL = 0;

int putchar(int c) {
	*ttyPntr = (char)c;
	return 1;
}

int puts(char *c) {
	while(*c != '\0'){
		putchar(*c);
		c++;
	}
	return 1;
}

void setOut(unsigned char x) {
	*gpioPntr = x;
}

unsigned char getIn() {
	return ~(*gpioPntr) & 0x0F;
}

void digitalOut(char bit, char state) {
	OUTPUT_VAL &= ~(1 << bit);
	if(state) OUTPUT_VAL |= (1 << bit);
	setOut(state);
}

char digitalIn(char bit) {
	return (getIn() & (1 << bit)) != 0;
}

void delay(short len) {
	for(short i = 0; i < len; i++) asm("nop");
}
