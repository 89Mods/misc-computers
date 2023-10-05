#ifndef Z180MINI_H_
#define Z180MINI_H_

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

#define ADDR_IRL 0x33
#define ADDR_ITC 0x34

#define ADDR_CBAR 0x3A
#define ADDR_CBR 0x38
#define ADDR_BBR 0x39

#define ADDR_TMDR0L 0x0C
#define ADDR_TMDR0H 0x0D
#define ADDR_TMDR1L 0x14
#define ADDR_TMDR1H 0x15
#define ADDR_RLDR0L 0x0E
#define ADDR_RLDR0H 0x0F
#define ADDR_RLDR1L 0x16
#define ADDR_RLDR1H 0x17
#define ADDR_TCR 0x10

#include <stdint.h>

//Specifically meant for this hardware
void io_outp(uint16_t addr, uint8_t val) __naked __preserves_regs(iyl,iyh) {
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

//Specifically meant for this hardware
unsigned char io_inp(uint16_t addr) __z88dk_fastcall __naked __preserves_regs(d,e,a,iyl,iyh) {
#asm
	ld c,l
	ld b,0
	in b,(c)
	ld h,0
	ld l,b
	ret
#endasm
}

void csio_tx(uint8_t txdat) __z88dk_fastcall __naked __preserves_regs(d,e,b,c,iyl,iyh) {
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

uint8_t csio_rx() __naked __preserves_regs(d,e,b,c,iyl,iyh) {
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
int puts(char *str) { while(*str != 0) putchar(*(str++)); return 1; }

const char hex_digits[] = "0123456789ABCDEF";
void printhex(unsigned char val) {
	putchar(hex_digits[val >> 4]);
	putchar(hex_digits[val & 0x0F]);
}

unsigned char curr_status = 0;
void rom_sel() { io_outp(ADDR_STATUS_LED, curr_status |= 1); }
void rom_desel() { io_outp(ADDR_STATUS_LED, curr_status &= 0b10); }
void set_status() { io_outp(ADDR_STATUS_LED, curr_status |= 2); }
void clear_status() { io_outp(ADDR_STATUS_LED, curr_status &= 0b01); }

void set_nmi_handler(void* funct_ptr) {
	*((unsigned char*)0x1000) = 0xC3;
	*((unsigned short*)0x1001) = funct_ptr;
}

#define INT1 0
#define INT2 1
#define INT_PRT0 2
#define INT_PRT1 3
#define INT_DMA0 4
#define INT_DMA1 5
#define INT_CSIO 6
#define INT_ASCI0 7
#define INT_ASCI1 8

void set_interrupt_handler(unsigned char interrupt, void* funct_ptr) {
	if(interrupt > 8) return;
#asm
	im 2
	ld a,0x10
	ld i,a
	ld a,0b00100000
	out0 (ADDR_IRL),a
#endasm
	unsigned short* tbl_ptr = (unsigned short *)((interrupt << 1) + 0x1020);
	*tbl_ptr = funct_ptr;
}

#define ITE0 1
#define ITE1 2
#define ITE2 4

void enable_ext_interrupts(uint8_t enable_mask) {
	uint8_t val = io_inp(ADDR_ITC);
	val &= 0b11111000;
	enable_mask &= 0b00000111;
	val |= enable_mask;
	io_outp(ADDR_ITC, val);
}

void disable_ext_interrupts(uint8_t disable_mask) {
	uint8_t val = io_inp(ADDR_ITC);
	val &= 0b11111000;
	disable_mask &= 0b00000111;
	disable_mask = ~disable_mask;
	val &= disable_mask;
	io_outp(ADDR_ITC, val);
}

void sei() { volatile asm("ei"); }
void cli() { volatile asm("di"); }

#define PORTA 0
#define PORTB 1
#define PORTC 2

#define OUTPUT 0
#define INPUT 1

#define LOW 0
#define HIGH 1

volatile uint8_t port_config = 0b10001011;

void port_mode(uint8_t port, uint8_t mode) {
	if(port > 2) return;
	if(port == PORTA) {
		port_config &= 0b11101111;
		if(mode) port_config |= 0b00010000;
	}else if(port == PORTB) {
		port_config &= 0b11111101;
		if(mode) port_config |= 0b00000010;
	}else if(port == PORTC) {
		port_config &= 0b11110110;
		if(mode) port_config |= 0b00001001;
	}
	port_config |= 128;
	io_outp(ADDR_PORT_CTRL, port_config);
}

const uint8_t port_addresses[] = {ADDR_PORTA, ADDR_PORTB, ADDR_PORTC};

uint8_t port_read(uint8_t port) {
	return io_inp(port_addresses[port]);
}

void port_write(uint8_t port, uint8_t value) {
	io_outp(port_addresses[port], value);
}

uint8_t digital_read(uint8_t port, uint8_t bit) {
	uint8_t val = io_inp(port_addresses[port]);
	return (val >> bit) & 1;
}

void digital_write(uint8_t port, uint8_t bit, uint8_t state) {
	uint8_t val = io_inp(port_addresses[port]);
	val &= ~(1 << bit);
	if(state) val |= 1 << bit;
	io_outp(port_addresses[port], val);
}

#define TIMER0 0
#define TIMER1 1

void set_timer_period(uint8_t timer, uint16_t limit) {
	if(timer > 1) return;
	io_outp(timer ? ADDR_RLDR1L : ADDR_RLDR0L, limit & 0xFF);
	io_outp(timer ? ADDR_RLDR1H : ADDR_RLDR0H, limit >> 8);
}

uint8_t timer0_val() __naked __preserves_regs(iyl,iyh) {
#asm
	
	ret
#endasm
}

uint16_t get_timer_value(uint8_t timer) {
	if(timer > 1) return 0xFFFF;
	uint16_t read1 = 0;
	uint16_t read2 = 0;
	uint8_t addrLo = timer ? ADDR_TMDR1L : ADDR_TMDR0L;
	uint8_t addrHi = timer ? ADDR_TMDR1H : ADDR_TMDR0H;
	/*while(1) {
		read1 = (uint16_t)io_inp(addrLo) | ((uint16_t)io_inp(addrHi) << 8);
		read2 = (uint16_t)io_inp(addrLo) | ((uint16_t)io_inp(addrHi) << 8);
		if(read1 - read2 < 25) return read2;
	}*/
	return (uint16_t)io_inp(addrLo) | ((uint16_t)io_inp(addrHi) << 8);
}

void set_timer_enabled(uint8_t timer, uint8_t state) {
	if(timer > 1) return;
	uint8_t val = io_inp(ADDR_TCR);
	val &= ~(1 << timer);
	if(state) val |= 1 << timer;
	io_outp(ADDR_TCR, val);
}

void set_timer_interrupt_enabled(uint8_t timer, uint8_t state) {
	if(timer > 1) return;
	uint8_t val = io_inp(ADDR_TCR);
	val &= ~(16 << timer);
	if(state) val |= 16 << timer;
	io_outp(ADDR_TCR, val);
}

uint16_t clear_timer_int(uint8_t timer) {
	io_inp(ADDR_TCR);
	return get_timer_value(timer);
}

#endif
