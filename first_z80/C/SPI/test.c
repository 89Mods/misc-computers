#include <stdio.h>
#include <string.h>

#include "z80io.h"

const uint8_t DP = 4;
const uint8_t DR = 1;

uint8_t m_data[14];

const uint8_t segment_lookup_table_size = 127;
const uint8_t segment_lookup_table[] = {
0b1011100, 0b1011100, 0b1011100, 0b1011100, 0b1011100, 0b1011100, 0b1011100, 0b1011100, 0b1011100, 0b0000000, 0b0000000, 0b1011100, 0b1011100, 0b0000000, 0b1011100 /* '\x0e' */,0b1011100 /* '\x0f' */,0b1011100 /* '\x10' */,0b1011100 /* '\x11' */,0b1011100 /* '\x12' */,0b1011100 /* '\x13' */,0b1011100 /* '\x14' */,0b1011100 /* '\x15' */,0b1011100 /* '\x16' */,0b1011100 /* '\x17' */,0b1011100 /* '\x18' */,0b1011100 /* '\x19' */,0b1011100 /* '\x1a' */,0b1011100 /* '\x1a' */,0b1011100 /* '\x1b' */,0b1011100 /* '\x1c' */,0b1011100 /* '\x1d' */,0b1011100 /* '\x1e' */,0b1011100 /* '\x1f' */,0b0000000 /*  ' '   */,0b0010010 /*  '!'   */,0b0110000 /*  '"'   */,0b1011100 /*  '#'   */,0b1011100 /*  '$'   */,0b1001001 /*  '%'   */,0b1011100 /*  '&'   */,0b0100000 /*  "'"   */,0b1100101 /*  '('   */,0b1010011 /*  ')'   */,0b1011100 /*  '*'   */,0b1011100 /*  '+'   */,0b0000010 /*  ','   */,0b0001000 /*  '-'   */,0b0000001 /*  '.'   */,0b0011100 /*  '/'   */,0b1110111 /*  '0'   */,0b0010010 /*  '1'   */,0b1011101 /*  '2'   */,0b1011011 /*  '3'   */,0b0111010 /*  '4'   */,0b1101011 /*  '5'   */,0b1101111 /*  '6'   */,0b1010010 /*  '7'   */,0b1111111 /*  '8'   */,0b1111011 /*  '9'   */,0b0001001 /*  ':'   */,0b0001010 /*  ';'   */,0b1101000 /*  '<'   */,0b0001001 /*  '='   */,0b1011000 /*  '>'   */,0b1011100 /*  '?'   */,0b1011100 /*  '@'   */,0b1111110 /*  'A'   */,0b0101111 /*  'B'   */,0b1100101 /*  'C'   */,0b0011111 /*  'D'   */,0b1101101 /*  'E'   */,0b1101100 /*  'F'   */,0b1100111 /*  'G'   */,0b0111110 /*  'H'   */,0b0100100 /*  'I'   */,0b0000010 /*  'J'   */,0b0101101 /*  'K'   */,0b0100101 /*  'L'   */,0b1110110 /*  'M'   */,0b1110110 /*  'N'   */,0b1110111 /*  'O'   */,0b1111100 /*  'P'   */,0b1111010 /*  'Q'   */,0b1111110 /*  'R'   */,0b1101011 /*  'S'   */,0b1100100 /*  'T'   */,0b0110111 /*  'U'   */,0b0110111 /*  'V'   */,0b0110111 /*  'W'   */,0b0111110 /*  'X'   */,0b0111010 /*  'Y'   */,0b1011101 /*  'Z'   */,0b1100101 /*  '['   */,0b0101010 /*  '\\'  */,0b1100101 /*  ']'   */,0b1000000 /*  '^'   */,0b0000001 /*  '_'   */,0b0010000 /*  '`'   */,0b1111110 /*  'a'   */,0b0101111 /*  'b'   */,0b0001101 /*  'c'   */,0b0011111 /*  'd'   */,0b1101101 /*  'e'   */,0b1101100 /*  'f'   */,0b1100111 /*  'g'   */,0b0101110 /*  'h'   */,0b0000100 /*  'i'   */,0b0000010 /*  'j'   */,0b0101101 /*  'k'   */,0b0100100 /*  'l'   */,0b0001110 /*  'm'   */,0b0001110 /*  'n'   */,0b0001111 /*  'o'   */,0b1111100 /*  'p'   */,0b1111010 /*  'q'   */,0b0001100 /*  'r'   */,0b1101011 /*  's'   */,0b0101100 /*  't'   */,0b0000111 /*  'u'   */,0b0000111 /*  'v'   */,0b0000111 /*  'w'   */,0b0111110 /*  'x'   */,0b0111010 /*  'y'   */,0b1011101 /*  'z'   */,0b1100101 /*  '{'   */, 0b0010010 /*  '|'   */, 0b1010011 /*  '}'   */,
};

void disp_flush();
void disp_put(char character, char position);
void disp_set(uint8_t segment, char position);
uint8_t segmentToByte(uint8_t segment);
void enableBell();
void disableBell();
void enableMuted();
void disableMuted();
void batteryFull();
void batteryEmpty();
void batteryHalfFull();
void enableChan();
void disableChan();
void enableMem();
void disableMem();
void enableProg();
void disableProg();
void enableSec();
void disableSec();

void main(void) {
	asm("di");
	SPIselect();
	delay(100);
	memset(m_data, 0, 14);
	disp_flush();
	batteryFull();
	
	disp_put('V', 0);
	disp_put('V', 8);
	disp_put('O', 1);
	disp_put('O', 9);
	disp_put('r', 2);
	disp_put('r', 10);
	disp_put('E', 3);
	disp_put('E', 11);
	enableMem();
	enableBell();
	disp_flush();
	delay(20000);
	disableMem();
	disableBell();
	
	unsigned long cntr = 1;
	unsigned long tmp;
	char c;
	char pr = 0;
	while(1) {
		tmp = cntr;
		for (char i = 0; i < 12; i++) {
			c = '0' + (tmp % 10);
			tmp /= 10;
			disp_put(c, 11 - i);
		}
		cntr <<= 1;
		if(cntr == 0) cntr = 1;
		if(pr) {
			enableProg();
			pr = 0;
		}else {
			disableProg();
			pr = 1;
		}
		disp_flush();
		delay(7200);
	}
}

void disp_put(char character, char position) {
	character++;
	if (character > segment_lookup_table_size) {
		character = '?';
	}
	disp_set(segment_lookup_table[(uint8_t)character], position);
}

void disp_set(uint8_t segment, char position) {
	if (position < 0) position = 12 + position;
	if (position < 0 || position >= 12) return;
	if (position >= 6) position ++;
	m_data[12 - position] = segmentToByte(segment);
}

uint8_t segmentToByte(uint8_t segment) {
	uint8_t byte = 0;
	uint8_t data_offset[7] = {2, 0, 4, 3, 1, 7, 5};
	for (char i = 0; i < 7; i++) {
		uint8_t segment_mask = 1 << (6 - i);
		if (segment & segment_mask) {
			byte |=  1 << data_offset[i];
		}
	}
	return byte;
}

void disp_flush() {
	uint8_t data1[7];
	uint8_t data2[7];
	for (char i = 0; i < 7; i++) data1[i] = m_data[i];
	for (char i = 0; i < 7; i++) data2[i] = m_data[7 + i];
	data1[6] &= 248;
	data1[6] |= DP;
	data2[6] &= 248;
	data2[6] |= DR;
	SPIdeselect();
	for (char i = 0; i < 7; i++) SPItransfer(data1[i]);
	SPIselect();
	delay(50);
	SPIdeselect();
	for (char i = 0; i < 7; i++) SPItransfer(data2[i]);
	SPIselect();
}

void enableBell(){
    m_data[6] |= 1 << 7;
}

void disableBell(){
    m_data[6] &= 255 - (1 << 7);
}

void enableMuted(){
    m_data[6] |= 1 << 6;
}

void disableMuted(){
    m_data[6] &= 255 - (1 << 6);
}

void enableBattery(char side){
    if(side){
	    m_data[13] |= 1 << 5;
    }else{
	    m_data[13] |= 1 << 4;
    }
}

void disableBattery(char side){
    if(side){
	    m_data[13] &= 255 - (1 << 5);
    }else{
	    m_data[13] &= 255 - (1 << 4);
    }
}

void batteryFull(){
    enableBattery(1);
    enableBattery(0);
}

void batteryEmpty(){
    disableBattery(1);
    disableBattery(0);
}

void batteryHalfFull(){
    enableBattery(1);
    disableBattery(0);
}

void enableChan(){
    m_data[6] |= 1 << 4;
}

void disableChan(){
    m_data[6] &= 255 - (1 << 4);
}

void enableMem(){
    m_data[6] |= 1 << 5;;
}

void disableMem(){
    m_data[6] &= 255 - (1 << 5);
}

void enableProg(){
    m_data[13] |= 1 << 6;
}

void disableProg(){
    m_data[13] &= 255 - (1 << 6);
}

void enableSec(){
    m_data[13] |= 1 << 7;
}

void disableSec(){
    m_data[13] &= 255 - (1 << 7);
}
