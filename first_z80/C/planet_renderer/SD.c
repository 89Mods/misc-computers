#include "SD.h"
#include "z80io.h"

#include <stdio.h>
#include <stdint.h>

static uint32_t numBlocks = 0;
static uint8_t HC = 0;
static uint8_t SD = 0;
static uint8_t crcBuff[5];

uint8_t sdCrc7(uint8_t* restrict chr,uint8_t cnt,uint8_t crc){
	uint8_t i, a;
	uint8_t Data;
	
	for(a = 0; a < cnt; a++){
		
		Data = chr[a];
		
		for(i = 0; i < 8; i++){
			
			crc <<= 1;

			if( (Data & 0x80) ^ (crc & 0x80) ) crc ^= 0x09;
			
			Data <<= 1;
		}
	}

	return crc & 0x7F;
}

void sendCMD(uint8_t cmd, uint32_t param, uint8_t crc){
	SPItransfer(cmd | 0x40);
	SPItransfer(param >> 24UL);
	SPItransfer(param >> 16UL);
	SPItransfer(param >> 8UL);
	SPItransfer(param);
	if(crc){
		crcBuff[0] = cmd | 0x40;
		crcBuff[1] = param >> 24UL;
		crcBuff[2] = param >> 16UL;
		crcBuff[3] = param >> 8UL;
		crcBuff[4] = param;
		SPItransfer((sdCrc7(crcBuff, 5, 0) << 1) | 1);
	}else SPItransfer(0x00);
}

void waitReady(){
	uint8_t i = 0;
	uint8_t j;
	SPIdummy();
	do {
		j = SPIreceive(0xFF);
	}while(i++ <= 200 && j != 0xFF);
}

uint8_t SD_CMD(uint8_t cmd, uint32_t param, uint8_t crc){
	SPIselect();
	uint8_t ret;
	uint8_t i = 0;
	waitReady();
	
	sendCMD(cmd, param, crc);
	
	i = 0;
	do {
		
		ret = SPIreceive();
		
	}while(i++ < 250 && (ret == 0xFF));

	if(cmd == 8 || cmd == 58){
		SPIdummy();
		SPIdummy();
		SPIdummy();
		SPIdummy();
	}
	
	if(cmd != 55 && cmd != 9 && cmd != 17 && cmd != 24) SPIdeselect();
	return ret;
}

uint8_t SD_ACMD(uint8_t acmd, uint32_t param, uint8_t crc){
	uint8_t ret = 0;
	
	ret = SD_CMD(55, 0, crc);
	if(ret == 0xFF || (ret & 0x04)) {
		SPIdeselect();
		return ret;
	}
		
	uint8_t ret2 = SD_CMD(acmd, param, crc);
	return ret2;
}

uint8_t SD_readBuffer(uint8_t* restrict buff, uint16_t len){
	uint8_t ret;
	uint16_t tries = 32000;

	do {
		ret = SPIreceive();
		if((ret & 0xF0) == 0x00){
			return ret; //fail
		}
		if(ret == 0xFE) break;
		tries--;
	}while(tries);

	if(!tries) return 0xFF;

	//*buff = ret;

	ret = 0;

	tries = 0;
	while(len--){
		buff[tries++] = SPIreceive();
	}
	SPIdummy();
	SPIdummy();
	ret = 0;

	SPIdeselect();

	return ret;
}

char SDinit() {
	SPIdeselect();
	delay(250);
	int i,j;
	for(i = 0; i < 24; i++) SPIdummy();
	
	int tries = 0;
	do {
		SPIdummy();
		i = SD_CMD(0, 0, 1);
		tries++;
		if(tries > 50){
			return 0x01;
		}
	} while(i != 0x01);
	j = 0;
	uint8_t ret;
	
	ret = SD_CMD(8, 0x000001AAUL, 1);
	if(ret & 0x80) return 0x06;
	HC = !(ret & 0b11111110);
	ret = SD_CMD(55, 0, 1);
	if(ret & 0x80) return 0x06;
	SD = !(ret & 0x04);
	SPIdeselect();
	SPItransfer(0xFF);
	
	ret = SD_CMD(58, 0x000001AAUL, 1);
	
	if(SD) {
		try_init:
		j = 0;
		do {
			ret = SD_ACMD(41, (HC ? (1UL << 30) : 0) | (j == 0 ? 0 : 0x00200000UL), 1);
			if(!(ret & 1)) break;
		}while(j++ < 100);
		if(ret & 1) {
			if(HC) {        // Maybe not actually an HC
				HC = 0;
				goto try_init;
			}else return 0x02;
		}
	}else {
		j = 0;
		do {
			ret = SD_CMD(1, (HC ? (1ULL<< 30) : 0) | (j == 0 ? 0 : 0x00200000UL), 1);
			if(!(ret & 1)) break;
		}while(j++ < 100);
		if(ret & 1) return 0x02;
	}
	puts("SD: ");
	if(SD) putchar('1');
	else putchar('0');
	puts(", HC: ");
	if(HC) putchar('1');
	else putchar('0');
	putchar('\r');
	putchar('\n');
	ret = SD_CMD(59, 0, 1);
	if(ret) return 0x03;
	ret = SD_CMD(16, 512, 0);
	if(ret) return 0x04;
	
	ret = SD_CMD(9, 0, 0);
	if(ret){
		SPIdeselect();
		return 0x05;
	}
	uint8_t buff[16];
	ret = SD_readBuffer(buff, 16);
	if(ret){
		SPIdeselect();
		return 0x07;
	}
	if((buff[0] >> 6) == 1) {
		numBlocks = 0;
		numBlocks = buff[9] + (buff[8] << 8UL) + ((unsigned long)(buff[7] & 63) << 16UL) + 1UL;
		numBlocks <<= 10UL;
	} else{
		uint32_t n = (buff[5] & 15) + ((buff[10] & 128) >> 7UL) + ((buff[9] & 3) << 1UL) + 2UL;
		numBlocks = (buff[8] >> 6UL) + (buff[7] << 2UL) + ((buff[6] & 3) << 10UL) + 1;
		numBlocks <<= (unsigned int)(n - 9);
	}
	
	return 0;
}

static int streamPos = -1;

int SDreadPos() {
	return streamPos;
}

char SDbeginRead(unsigned long sec) {
	uint8_t ret;
	uint16_t retry = 0;
	uint8_t readTries;
	
	do {
		SPIselect();
		ret = SD_CMD(17, HC ? sec : sec << 9UL, 0);
		if(ret & 0x80){
			if(ret == 0xff) goto read_retry;
			SPIdeselect();
			SPIdummy();
			return ret;
		}
		
		readTries = 128;
		do {
			ret = SPIreceive();
			if((ret & 0xF0) == 0x00){
				SPIdeselect();
				SPIdummy();
				return ret;
			}
			if(ret == 0xFE) {
				streamPos = 0;
				return 0;
			}
			readTries--;
		}while(readTries);
		
		read_retry:
		SPIdummy();
		SPIdummy();
		SPIdummy();
		SPIdeselect();
		SPIdummy();
		SPIdummy();
	}while(++retry <= 5);
	
	SPIdeselect();
	SPIdummy();
	return 1;
}

void SDskip(int skip) {
	if(streamPos < 0) return;
	for(int i = 0; i < skip; i++) {
		SPIreceive();
		streamPos++;
		if((streamPos & 511) == 0) {
			SDendRead();
			return;
		}
	}
}

unsigned char SDreadByte() {
	if(streamPos < 0) return 255;
	unsigned char res = SPIreceive();
	streamPos++;
	if((streamPos & 511) == 0) SDendRead();
	return res;
}

int SDread(unsigned char* restrict buff, int count) {
	if(streamPos < 0) return 0;
	int pos = 0;
	while(count--) {
		buff[pos++] = SPIreceive();
		streamPos++;
		if((streamPos & 511) == 0) {
			SDendRead();
			return pos;
		}
	}
	return pos;
}

void SDendRead() {
	SPIdummy();
	SPIdummy();
	SPIdeselect();
	streamPos = -1;
}

unsigned long SDsize() {
    return numBlocks;
}
