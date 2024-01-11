#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char *argv[]) {
	if(argc < 4) {
		printf("Usage:\r\n");
		printf("brp [port] [device] [file] (slow)\r\n");
		return 1;
	}
	char *portname = argv[1];
	
	int fd = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
	if(fd < 0) {
		printf("Error opening serial port: %s\r\n", strerror(errno));
		return 1;
	}
	struct termios tty;
	if(tcgetattr(fd, &tty) != 0) {
		printf("Error from tcgetattr: %s\n", strerror(errno));
		return 1;
	}
	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;
	tty.c_iflag &= ~IGNBRK;
	tty.c_lflag = 0;
	tty.c_oflag = 0;
	tty.c_cc[VMIN] = 0;
	tty.c_cc[VTIME] = 5;
	tty.c_iflag &= ~(IXON | IXOFF | IXANY);
	tty.c_cflag |= (CLOCAL | CREAD);
	tty.c_cflag &= ~(PARENB | PARODD);
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;
	
	const uint8_t slow = argc >= 5 && strcmp(argv[4], "slow") == 0;
	
	cfsetospeed(&tty, slow ? B9600 : B115200);
	cfsetispeed(&tty, slow ? B9600 : B115200);
	
	if(tcsetattr(fd, TCSANOW, &tty) != 0) {
		printf("Error from tcsetattr: %s\r\n", strerror(errno));
		close(fd);
		return 1;
	}
	
	uint32_t romSize = 0;
	char *dev = argv[2];
	uint8_t extraDelay = 0;
	if(strcmp(dev, "28C16") == 0) {
		write(fd, "1", 1);
		romSize = 2048;
	}else if(strcmp(dev, "28C64") == 0) {
		write(fd, "2", 1);
		romSize = 16384;
	}else if(strcmp(dev, "28C256") == 0) {
		write(fd, "3", 1);
		romSize = 32768;
		extraDelay = 1;
	}else if(strcmp(dev, "39SF010") == 0) {
		write(fd, "4", 1);
		romSize = 131072;
	}else if(strcmp(dev, "27C1001") == 0) {
		write(fd, "5", 1);
		romSize = 131072;
	}
	
	if(romSize == 0) {
		printf("Device name not recognized.\r\n");
		close(fd);
		return 1;
	}
	
	uint8_t *databuff = malloc(romSize);
	if(!databuff) {
		printf("Failed to allocate data buffer.\r\n");
		close(fd);
		return 1;
	}
	memset(databuff, 0, romSize);
	
	FILE *fil;
	
	fil = fopen(argv[3], "r");
	if(!fil) {
		printf("Error opening input file: %s\r\n", strerror(errno));
		close(fd);
		return 1;
	}
	
	fseek(fil, 0L, SEEK_END);
	uint64_t sz = ftell(fil);
	rewind(fil);
	
	if(sz > romSize) {
		printf("WARNING: Input file longer than device capacity (%u). It will be truncated.\r\n", romSize);
	}
	
	uint32_t targSize = sz > romSize ? romSize : sz;
	size_t recSize = fread(databuff, 1, targSize, fil);
	if(recSize != targSize) {
		printf("Failed to read data from input file.\r\n");
		close(fd);
		fclose(fil);
		return 1;
	}
	fclose(fil);
	
	fil = fopen("readback.bin", "w");
	if(!fil) {
		printf("Error opening readback file: %s\r\n", strerror(errno));
		close(fd);
		return 1;
	}
	
	uint8_t respbuff[6];
	int n = 1;
	while(n != 0) {
		nanosleep((const struct timespec[]){{0, 500000L}}, NULL);
		n = read(fd, respbuff, 1);
	}
	
	n = write(fd, "p", 1);
	if(n != 1) {
		printf("Failed to send data to programmer.\r\n");
		close(fd);
		fclose(fil);
		return 1;
	}
	
	n = read(fd, respbuff, 1);
	if(n != 1 || respbuff[0] != 'a') {
		printf("Invalid response from programmer.\r\n");
		if(n != 1) printf("%d\r\n", n);
		else printf("%c\r\n", respbuff[0]);
		close(fd);
		fclose(fil);
		return 1;
	}
	
	respbuff[0] = (targSize & 0x0F) + 'A';
	respbuff[1] = ((targSize >> 4) & 0x0F) + 'A';
	respbuff[2] = ((targSize >> 8) & 0x0F) + 'A';
	respbuff[3] = ((targSize >> 12) & 0x0F) + 'A';
	respbuff[4] = ((targSize >> 16) & 0x0F) + 'A';
	respbuff[5] = ((targSize >> 20) & 0x0F) + 'A';
	
	{
		uint8_t toSendLen = romSize > 65535 ? 6 : 4;
		n = write(fd, respbuff, toSendLen);
		if(n != toSendLen) {
			printf("Failed to send data to programmer.\r\n");
			close(fd);
			fclose(fil);
			return 1;
		}
	}
	
	if(romSize > 65535) nanosleep((const struct timespec[]){{1, 2517800}}, NULL);
	
	printf("Programmer handshake complete\r\nWrite\r\n");
	putchar('|');
	for(uint8_t i = 0; i < 98; i++) putchar('-');
	putchar('|');
	putchar('\r');
	putchar('\n');
	uint8_t currPercent = 0;
	for(uint32_t i = 0; i < targSize; i++) {
		uint8_t percent = (uint8_t)((float)i / (float)targSize * 100.0f);
		while(percent > currPercent) {
			putchar('>');
			fflush(stdout);
			currPercent++;
		}
		
		int tries = 0;
		while(1) {
			n = read(fd, respbuff, 1);
			if(n == 1 && respbuff[0] == 'n') break;
			if(n == 0 || respbuff[0] != 'n') {
				if(tries == 10 || (n == 1 && respbuff[0] != 'n')) {
					printf("\r\nInvalid response from programmer.\r\n");
					if(n == 0) printf("No Response\r\n");
					else printf("%c\r\n", respbuff[0]);
					close(fd);
					fclose(fil);
					return 1;
				}
				nanosleep((const struct timespec[]){{0, 1000000}}, NULL);
				tries++;
			}
		}
		
		respbuff[0] = databuff[i];
		n = write(fd, respbuff, 1);
		if(n == 0) {
			printf("\r\nFailed to send data to programmer.\r\n");
			close(fd);
			fclose(fil);
			return 1;
		}
	}
	for(;currPercent < 100; currPercent++) putchar('>');
	putchar('\r');
	putchar('\n');
	int tries = 0;
	while(1) {
		n = read(fd, respbuff, 1);
		if(n == 1 && respbuff[0] == 'd') break;
		if(n == 0 || respbuff[0] != 'd') {
			if(tries == 10 || (n == 1 && respbuff[0] != 'd')) {
				printf("\r\nInvalid response from programmer.\r\n");
				if(n == 0) printf("No Response\r\n");
				else printf("%c\r\n", respbuff[0]);
				close(fd);
				fclose(fil);
				return 1;
			}
			nanosleep((const struct timespec[]){{1, 1000000}}, NULL);
			tries++;
		}
	}
	
	printf("Verify\r\n");
	putchar('|');
	for(uint8_t i = 0; i < 98; i++) putchar('-');
	putchar('|');
	putchar('\r');
	putchar('\n');
	currPercent = 0;
	uint64_t delayTime = extraDelay ? 4500000UL : 3500000UL;
	nanosleep((const struct timespec[]){{0, delayTime}}, NULL);
	nanosleep((const struct timespec[]){{0, delayTime}}, NULL);nanosleep((const struct timespec[]){{0, delayTime}}, NULL);
	for(uint32_t i = 0; i < targSize; i++) {
		uint8_t percent = (uint8_t)((float)i / (float)targSize * 100.0f);
		while(percent > currPercent) {
			putchar('>');
			fflush(stdout);
			currPercent++;
		}
		
		n = write(fd, "n", 1);
		if(n == 0) {
			printf("\r\nFailed to send data to programmer.\r\n");
			close(fd);
			fclose(fil);
			return 1;
		}
		
		nanosleep((const struct timespec[]){{0, delayTime}}, NULL);
		
		n = read(fd, respbuff, 2);
		if(n != 2) {
			printf("\r\nNo response from programmer.\r\n");
			close(fd);
			fclose(fil);
			return 1;
		}
		uint8_t val = (respbuff[0] - 48) + ((respbuff[1] - 48) << 4);
		fwrite(&val, 1, 1, fil);
		if(val != databuff[i]) {
			printf("\r\n%d: %d != %d\r\n", i, val, databuff[i]);
		}
	}
	for(;currPercent < 100; currPercent++) putchar('>');
	close(fd);
	fclose(fil);
	printf("\r\nDone.\r\n");
}
