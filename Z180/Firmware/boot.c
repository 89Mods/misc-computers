#include "../Examples/Include/crc32.h"

#define ADDR_8255_BASE 128
#define ADDR_PORTA ADDR_8255_BASE+0
#define ADDR_PORTB ADDR_8255_BASE+1
#define ADDR_PORTC ADDR_8255_BASE+2
#define ADDR_PORT_CTRL ADDR_8255_BASE+3

#define ADDR_STATUS_LED 64

#define ADDR_ASCI_CNTLA0 0x00
#define ADDR_ASCI_CNTLA1 0x01
#define ADDR_ASCI_CNTLB0 0x02
#define ADDR_ASCI_CNTLB1 0x03
#define ADDR_ASCI_STAT0 0x04
#define ADDR_ASCI_STAT1 0x05
#define ADDR_ASCI_TDR0 0x06
#define ADDR_ASCI_TDR1 0x07
#define ADDR_ASCI_RDR0 0x08
#define ADDR_ASCI_RDR1 0x09

#define ADDR_CSIO_CNTR 0x0A
#define ADDR_CSIO_TRDR 0x0B
#define CSIO_SPEED 0b000
#define CSIO_TXE 16
#define CSIO_RXE 32

#define ASEXT0 0x12
#define ASEXT1 0x13

#define ADDR_CBAR 0x3A
#define ADDR_CBR 0x38
#define ADDR_BBR 0x39

#define ROM_SEL io_outp(ADDR_STATUS_LED, curr_status_led | 1);
#define ROM_DESEL io_outp(ADDR_STATUS_LED, curr_status_led & 0b10);

void io_outp(unsigned short addr, unsigned char val) __naked __preserves_regs(iyl,iyh) {
#asm
	ld hl,2
	add hl,sp
	ld d,(hl)
	inc hl
	inc hl
	ld c,(hl)
	ld b,0
	out (c),d
	ret
#endasm
}

void csio_tx(unsigned char txdat) __z88dk_fastcall __naked __preserves_regs(d,e,b,c,iyl,iyh) {
#asm
	ld h,0b00110000
csio_busy_wait_a:
	in0 a,(ADDR_CSIO_CNTR)
	tst h
	jp nz, csio_busy_wait_a
	out0 (ADDR_CSIO_TRDR),l
	ld a,CSIO_TXE + CSIO_SPEED
	out0 (ADDR_CSIO_CNTR),a
csio_busy_wait_d:
	in0 a,(ADDR_CSIO_CNTR)
	tst h
	jp nz, csio_busy_wait_d
	ret
#endasm
}

unsigned char csio_rx() __naked __preserves_regs(d,e,b,c,iyl,iyh) {
#asm
	ld h,0b00110000
csio_busy_wait_b:
	in0 a,(ADDR_CSIO_CNTR)
	tst h
	jp nz, csio_busy_wait_b
	ld a,CSIO_RXE + CSIO_SPEED
	out0 (ADDR_CSIO_CNTR),a
csio_busy_wait_c:
	in0 a,(ADDR_CSIO_CNTR)
	tst h
	jp nz, csio_busy_wait_c
	in0 a,(ADDR_CSIO_TRDR)
	ld h,0
	ld l,a
	ret
#endasm
}

void uart_tx(char c) __z88dk_fastcall __naked __preserves_regs(d,e,b,c,iyl,iyh) {
#asm
	ld h,0b00000010
asci_busy_wait_a:
	in0 a,(ADDR_ASCI_STAT0)
	tst h
	jp z, asci_busy_wait_a
	out0 (ADDR_ASCI_TDR0),l
	ret
#endasm
}

void short_del(void) __naked __preserves_regs(d,e,b,c,iyl,iyh) {
#asm
	ld h,8
short_del_loop:
	dec h
	jp nz,short_del_loop
	ret
#endasm	
}

int putchar(int c) { uart_tx(c); return c; }
void puts(char *str) { while(*str != 0) putchar(*(str++)); }

void printint(long val);
void printhex(unsigned char val);
unsigned char reverse(unsigned char b);
void spi_tx(unsigned char c);
unsigned char spi_rx();
unsigned long UPDC32(unsigned char octet, unsigned long crc);

const unsigned char allowed_rom_ids[] = {0xEF, 0xC2, 0xAB};
const unsigned char allowed_rom_ids_len = 3;

static unsigned char databuff[64];
const char expected_signature[] = "CHIRP!";
const unsigned char signature_len = 6;

void main() {
	//Clear status LED and SPI flash CS
	unsigned char curr_status_led = 0;
	io_outp(ADDR_STATUS_LED, 0);
	ROM_DESEL
	
	//PORTA is output port by default, others are inputs, with no special modes
	io_outp(ADDR_PORT_CTRL, 0b10001011);
	io_outp(ADDR_PORTA, 0);
	
	io_outp(ADDR_ASCI_CNTLA1, 0); //Disable second UART (not wired up on board)
	io_outp(ADDR_ASCI_STAT0, 0); //Clear UART status
	io_outp(ADDR_ASCI_STAT1, 0); //Clear UART status
	io_outp(ADDR_ASCI_CNTLA0, 0b01100100); //Enable TX & RX, 8-bit data, no parity, 1 stop bit
	io_outp(ADDR_ASCI_CNTLB0, 0b00000010); //UART clock configured here. There is 3 prescalers. Baud rate is 6000000 / 10 / 4 / 16 = 9375
	
	//CSIO is basically a SPI port, so the SPI flash is connected here
	io_outp(ADDR_CSIO_CNTR, 0x00 | CSIO_SPEED);
	//Force EF high by triggering a CSIO transmit while SPI flash is de-selected
	io_outp(ADDR_CSIO_CNTR, CSIO_TXE | CSIO_SPEED);
	
	puts("Z180 Bootloader 2023-10-04\r\n");
	
	ROM_SEL
	csio_tx(0xFF);
	ROM_DESEL
	short_del();
	ROM_SEL
	spi_tx(0xAB);
	ROM_DESEL
	short_del();
	ROM_SEL
	spi_tx(0x90);
	csio_tx(0x00);
	csio_tx(0x00);
	csio_tx(0x00);
	unsigned char id0 = spi_rx();
	unsigned char id1 = spi_rx();
	ROM_DESEL
	puts("SPI Flash ID: ");
	printhex(id0);
	putchar(' ');
	printhex(id1);
	putchar('\r');
	putchar('\n');
	
	id1 = 1;
	for(unsigned char i = 0; i < allowed_rom_ids_len; i++) {
		if(allowed_rom_ids[i] == id0) {
			id1 = 0;
			break;
		}
	}
	if(id1) {
		curr_status_led = 2;
		io_outp(ADDR_STATUS_LED, 2);
		puts("FATAL: SPI Flash missing or not recognized!\r\n");
		while(1) {}
	}
	
	ROM_SEL
	spi_tx(0x03);
	csio_tx(0x00);
	csio_tx(0x00);
	csio_tx(0x00);
	for(unsigned char i = 0; i < signature_len; i++) databuff[i] = spi_rx();
	id1 = 0;
	for(unsigned char i = 0; i < signature_len; i++) {
		if(databuff[i] != expected_signature[i]) {
			id1 = 1;
			break;
		}
	}
	if(id1) {
		ROM_DESEL
		curr_status_led = 2;
		io_outp(ADDR_STATUS_LED, 2);
		puts("FATAL: Invalid boot signature!\r\n");
		while(1) {}
	}
	unsigned short pgm_len = spi_rx();
	pgm_len |= (unsigned short)spi_rx() << 8;
	puts("Loading ");
	printint(pgm_len);
	puts(" bytes of binary executable\r\n");
	
	unsigned long corr_crc32 = spi_rx();
	corr_crc32 |= (unsigned long)spi_rx() << 8UL;
	corr_crc32 |= (unsigned long)spi_rx() << 16UL;
	corr_crc32 |= (unsigned long)spi_rx() << 24UL;
	
	/*
	 * CA1 is pointing to the last 4KiB of virtual address space
	 * This code uses that window to copy up to 32KiB from the SPI flash into the beginning of program area in SRAM (0x41000).
	 * The physical address offset for that window is initially set to begin at address 0x41000 of SRAM
	 * then gets pushed forward every 4096 bytes until the copy is done
	 */
	unsigned char *wptr = (unsigned char*)0x2000;
	unsigned char mmu_page = 0x3F;
	io_outp(ADDR_CBR, mmu_page);
	unsigned char val;
	unsigned long oldcrc32 = 0xFFFFFFFF;
	for(unsigned short i = 0; i < pgm_len; i++) {
		val = spi_rx();
		oldcrc32 = UPDC32(val, oldcrc32);
		*wptr = val;
		if(wptr == 0x2FFF) {
			wptr = (unsigned char*)0x2000;
			mmu_page++;
			io_outp(ADDR_CBR, mmu_page);
		}else wptr++;
	}
	oldcrc32 = ~oldcrc32;
	ROM_DESEL
	short_del();
	puts("CRC32: ");
	for(unsigned char i = 0; i < 4; i++) {
		printhex((unsigned char)(oldcrc32 >> ((3 - i) * 8)) & 0xFF);
		putchar(' ');
	}
	putchar('\r');
	putchar('\n');
	if(oldcrc32 != corr_crc32) {
		curr_status_led = 2;
		io_outp(ADDR_STATUS_LED, 2);
		puts("CRC mismatch, cannot boot!\r\n");
		while(1);
	}
	
	//Default MMU setup for user programs:
	//0x0000 - 0x0FFF: CA0 going to 0x00000 - 0x00FFF in ROM
	//0x1000 - 0xDFFF: BA going to 0x41000 - 0x4DFFF in RAM, contains interrupt table, CODE, BSS and DATA
	//0xE000 - 0xFFFF: CA1 going to 0x4E000 - 0x4FFFF in RAM by default, may be moved, and segments assigned different memory spaces in accordance with z88dk’s memory paging support
#asm
	xor a
	ld (0x1003),a
	ld a,0b11100001
	out0 (ADDR_CBAR),a
	ld a,0x40
	out0 (ADDR_BBR),a
	ld a,0x40
	out0 (ADDR_CBR),a
	jp 0x1040
#endasm
	while(1);	
}

const long printint_divs[] = {1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1};
void printint(long val) {
	if(val < 0) {
		putchar('-');
		val = -val;
	}
	char flag = 0;
	for(short i = 0; i < 10; i++) {
		long div = val / printint_divs[i];
		val = val % printint_divs[i];
		if(div != 0 || flag || i == 31) {
			flag = 1;
			putchar((char)div + '0');
		}
	}
}

const char hex_digits[] = "0123456789ABCDEF";
void printhex(unsigned char val) {
	putchar(hex_digits[val >> 4]);
	putchar(hex_digits[val & 0x0F]);
}

unsigned char reverse(unsigned char b) {
   b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
   b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
   b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
   return b;
}

void spi_tx(unsigned char c) { csio_tx(reverse(c)); }
unsigned char spi_rx() { return reverse(csio_rx()); }
