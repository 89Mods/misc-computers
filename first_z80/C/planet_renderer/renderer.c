#include <stdio.h>
#include <math.h>

#include "z80io.h"
#include "SD.h"

const char textBuff[32];

void raySphereIntersection(float posX, float posY, float posZ, float origX, float origY, float origZ, float dirX, float dirY, float dirZ, float radius, float* restrict t0, float* restrict t1);
void latlon(float x, float y, float z, float* restrict lat, float* restrict lon);
void heightmapTexNormal(float lat, float lon, float* restrict x, float* restrict y, float* restrict z, uint8_t* restrict r, uint8_t* restrict g, uint8_t* restrict b);

//const char brightnessSymbols[] = ".=x#";
//const char brightnessSymbols[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefg";

const int width = 32;
const int height = 32;

void main(void) {
	setOut(0);
	
	float rayX,rayY,rayZ,length,t0,t1,origX,origY,origZ,posX,posY,posZ,normalX,normalY,normalZ,lat,lon;
	uint8_t r,g,b;
	char pRes;
	
	if(sizeof(long long) != 8) {
		puts("long long isn’t 8 bytes!\r\n");
		goto abort;
	}
	
	char err_ret = SDinit();
	sprintf(textBuff, "0x%02x\r\n", err_ret);
	puts(textBuff);
	if(err_ret != 0) {
		puts("SD init failed\r\n");
		while(1) asm("nop");
	}
	
	puts("Pre-run test: Does ray-sphere-intersection function work?");
	raySphereIntersection(0.02, 0.02, 3.0, 0.01, 0.01, 0.01, -0.231, 0.033, 0.972, 1.0, &t0, &t1);
	if((long)(t0 * 1000.0) != 2200 || (long)(t1 * 1000.0) != 3607) {
		puts("\tNo\r\n");
		goto abort;
	}
	raySphereIntersection(0.02, 0.02, 3.0, 0.01, 0.01, 0.01, -0.231, -0.601, 0.765, 1.0, &t0, &t1);
	if(t0 == 10000.0 && t1 == 10000.0) puts("\tYes\r\n");
	else {
		puts("\tNo\r\n");
		goto abort;
	}
	while(digitalIn(1) == 0) delay(32);
	puts("\r\nBEGIN RENDER\r\n@");
	for(uint16_t i = 0; i < width; i++) putchar('-');
	putchar('\r');
	putchar('\n');
	
	float toSunX = -1.0;
	float toSunY = 0.02;
	float toSunZ = -0.64;
	length = sqrt(toSunX * toSunX + toSunY * toSunY + toSunZ * toSunZ);
	toSunX /= length;
	toSunY /= length;
	toSunZ /= length;
	toSunX *= 1.25;
	toSunY *= 1.25;
	toSunZ *= 1.25;
	
	for(short i = 0; i < height; i++) {
		//setOut(i << 3);
		setOut(i & 0b11111000);
		for(short j = 0; j < width; j++) {
			pRes = ' ';
			rayX = (float)j / (float)(width - 1) - 0.5;
			rayY = (float)(height - 1 - i) / (float)(height - 1) - 0.5;
			//rayY *= 0.8;
			rayZ = 1.0;
			
			origX = origY = origZ = 0.0;
			
			length = sqrt(rayX * rayX + rayY * rayY + rayZ * rayZ);
			rayX /= length;
			rayY /= length;
			rayZ /= length;
			
			raySphereIntersection(0, 0, 2.4, origX, origY, origZ, rayX, rayY, rayZ, 1.0, &t0, &t1);
			if(t0 < 9000) {
				normalX = (origX + t0 * rayX) - 0;
				normalY = (origY + t0 * rayY) - 0;
				normalZ = (origZ + t0 * rayZ) - 2.4;
				latlon(normalX, normalY, normalZ, &lat, &lon);
				heightmapTexNormal(lat, lon, &normalX, &normalY, &normalZ, &r, &g, &b);
				
				//length = -normalX * normalX + (6000.0 - normalY) * normalY + (-4500.0 - normalZ) * normalZ;
				//length /= 2000.0;
				length = normalX * toSunX + normalY * toSunY + normalZ * toSunZ;
				length *= 0.75;
				//if(length >= 1.0) length = 0.995;
				if(length > 1) length = 1;
				if(length < 0) length = 0;
				r = (uint8_t)((float)r * length);
				g = (uint8_t)((float)g * length);
				b = (uint8_t)((float)b * length);
				putchar('0' + (r >> 4));
				putchar('0' + (r & 0x0F));
				putchar('0' + (g >> 4));
				putchar('0' + (g & 0x0F));
				putchar('0' + (b >> 4));
				putchar('0' + (b & 0x0F));
				//pRes = brightnessSymbols[(char)(length * 32.0)];
			}else putchar(' ');
			
			//putchar(pRes);
		}
		putchar('\r');
		putchar('\n');
	}
	putchar('@');
	for(uint16_t i = 0; i < width; i++) putchar('-');
	putchar('\r');
	putchar('\n');
	SDskip(512);
	SPIdummy();
	while(1) {
		setOut((0x55 & 0b11111000) | (1 << 2));
		delay(6400);
		setOut((0xAA & 0b11111000) | (1 << 2));
		delay(6400);
	}
	
	abort:
		puts("Abort!\r\n");
		asm("halt");
		while(1) {}
}

uint32_t lastSector = 0;
signed char readBuff[6];

void heightmapTexNormal(float lat, float lon, float* restrict x, float* restrict y, float* restrict z, uint8_t* restrict r, uint8_t* restrict g, uint8_t* restrict b) {
	int imgX = (int)((lon / 360.0 + 0.5) * 1024) & 1023;
	int imgY = (int)(lat / 180.0 * 512.0);
	if(imgX >= 1024 || imgX < 0 || imgY >= 512 || imgY < 0) {
		puts("\r\nError: image coords out of bounds\r\n");
		asm("halt");
		while(1) {}
	}
	
	uint32_t imgAddr = imgY * 1024UL * 6UL + imgX * 6UL;
	uint32_t sector = imgAddr / 512 + 2048;
	int16_t sectorAddr = (int16_t)(imgAddr & 511);
	char err_ret;
	if(sector != lastSector || sectorAddr < SDreadPos()) {
		if(lastSector != 0) {
			SDskip(512);
		}
		err_ret = SDbeginRead(sector);
		if(err_ret != 0) {
			sd_read_err:
			sprintf(textBuff, "\r\nSD read error %02x\r\n", err_ret);
			puts(textBuff);
			sprintf(textBuff, "At sector %ld\r\n", sector);
			puts(textBuff);
			asm("halt");
			while(1) {}
		}
		lastSector = sector;
		SDskip(sectorAddr);
	}else {
		if(sectorAddr != SDreadPos()) SDskip(sectorAddr - SDreadPos());
	}
	
	char read = SDread(readBuff, 6);
	if(read != 6) {
		sector++;
		err_ret = SDbeginRead(sector);
		if(err_ret != 0) {
			sector = 69;
			goto sd_read_err;
		}
		lastSector = sector;
		SDread(readBuff + read, 6 - read);
	}
	
	*x = (float)readBuff[0] / 126.0f;
	*y = (float)readBuff[1] / 126.0f;
	*z = (float)readBuff[2] / 126.0f;
	*r = (uint8_t)readBuff[3];
	*g = (uint8_t)readBuff[4];
	*b = (uint8_t)readBuff[5];
}

void latlon(float x, float y, float z, float* restrict lat, float* restrict lon) {
	float len = sqrt(x*x + y*y + z*z);
	x /= len;
	y /= len;
	z /= len;
	*lat = acos(y) * 57.29577951308232;
	*lon = 270 + (atan2(x, z) * (180.0 / 3.14159));
	if(*lon >= 360.0) *lon -= 360.0;
	if(*lon <= -360.0) *lon += 360.0;
	*lon -= 180;
}

void raySphereIntersection(float posX, float posY, float posZ, float origX, float origY, float origZ, float dirX, float dirY, float dirZ, float radius, float* restrict t0, float* restrict t1) {
	float Lx,Ly,Lz,tca,L_2,d,thc;
	
	*t0 = 10000.0;
	*t1 = 10000.0;
	
	Lx = posX - origX;
	Ly = posY - origY;
	Lz = posZ - origZ;
	
	tca = dirX * Lx;
	tca += dirY * Ly;
	tca += dirZ * Lz;
	L_2 = Lx * Lx + Ly * Ly + Lz * Lz;
	if(tca <= 0 && sqrt(L_2) >= radius) return;
	
	d = L_2 - tca * tca;
	if(sqrt(d) >= radius) return;
	
	thc = radius * radius - d;
	thc = sqrt(thc);
	
	*t0 = tca - thc;
	*t1 = tca + thc;
}
