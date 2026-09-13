#ifndef F_CPU
#define F_CPU 20000000UL
#endif

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>

//write char over UART
static int uart_putchar(char c, FILE *stream){
	
	while(!(UCSRA & (1<<UDRE)));	//busy loop
	UDR = c;
	
	return 0;
}

//get char over UART (currently not needed)
static int uart_getchar(FILE *stream){
	if(UCSRA & (1<<RXC)) return UDR;
	return _FDEV_EOF;
}

char waitForChar(){
	int a = _FDEV_EOF;
	while(a == _FDEV_EOF){
		a = uart_getchar(NULL);
	}
	return (char)a;
}

const uint8_t stockPrescalers[] = {
	(1 << CS11) | (1 << CS10),
	(1 << CS11) | (1 << CS10),
	(1 << CS10),
	(1 << CS10),
	(1 << CS10),
	(1 << CS10),
	(1 << CS10),
};

const uint16_t stockDivisors[] = {
	15624, //10Hz
	1561, //100Hz
	9999, //1KHz
	999, //10KHz
	99, //100KHz
	9, //1MHz
	2, //3.33MHz
};

void setRomAddr(uint16_t addr);
void writeByte(uint16_t addr, uint8_t byte);
void appropriateDelay(uint8_t speedGrade);
void eraseROM();
void debugger();
void divisorSelectionMenu();

int main(void){
	//Configure UART
	UBRRH = 0;
	UBRRL = 129; //9600
	//UBRRL = 21;
	UCSRA = 0;
	UCSRC = (1 << UCSZ1) | (1 << UCSZ0) | (1 << URSEL);
	UCSRB = (1 << RXEN) | (1 << TXEN);
	
	DDRA = 0;
	PORTA = 0;
	DDRC = 0;
	PORTC = 0;
	DDRD = (1 << PD5);
	PORTD = 0;
	DDRB = 0b10100111;
	PORTB = 0b00000011;
	
	//Define stream for printf
	{
		static FILE uart_str = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);
		stdout = stderr = &uart_str;
	}
	
	printf("\033[0m");
	printf("Z80 microcomputer v1\r\n");
	_delay_ms(500);
	DDRA = 0x00;
	PORTA = 0x00;
	
	for(int i = 0; i < 16; i++){
		PORTD |= (1 << PD5);
		_delay_us(240);
		PORTD &= ~(1 << PD5);
		_delay_us(240);
	}
	
	printf("Press Enter to continue");
	while(true){
		char c = waitForChar();
		if(c == 'p'){ //ROM programming mode
			DDRA = 0x00;
			PORTA = 0xFF;
			DDRC = 0xFF;
			DDRD = 0b11111110;
			DDRB = 0b11100111;
			PORTB = 0b00000011;
			PORTB |= (1 << PB6);
			_delay_ms(8);
			
			eraseROM();
			
			uart_putchar('a', NULL);
			
			//uint16_t dataLength = waitForChar();
			//dataLength |= (waitForChar() << 8);
			uint16_t dataLength = waitForChar() - 'A';
			dataLength |= (waitForChar() - 'A') << 4;
			dataLength |= (waitForChar() - 'A') << 8;
			dataLength |= (waitForChar() - 'A') << 12;
			
			uint8_t tmp;
			for(uint16_t i = 0; i < dataLength; i++){
				uart_putchar('n', NULL);
				tmp = waitForChar();
				writeByte(i, tmp);
			}
			uart_putchar('d', NULL);
			
			DDRA = 0x00;
			PORTA = 0xFF;
			PORTB &= ~(1 << PB1);
			PORTB &= ~(1 << PB6);
			_delay_ms(1);
			for(uint16_t i = 0; i < dataLength; i++){
				waitForChar();
				setRomAddr(i);
				_delay_us(41);
				tmp = PINA;
				uart_putchar((tmp & 15) + 48, NULL);
				uart_putchar((tmp >> 4) + 48, NULL);
			}
			PORTB |= (1 << PB1) | (1 << PB6);
			PORTA = 0x00;
			
			/*DDRA = 0xFF;
			DDRC = 0xFF;
			DDRD = 0b11111110;
			DDRB = 0b00000111;
			PORTB = 0b00000011;
			uart_putchar('a', NULL);
			
			uint16_t dataLength = waitForChar();
			dataLength |= (waitForChar() << 8);
			
			uint8_t val = 0;
			uint16_t currAddr = 0;
			for(uint16_t i = 0; i < dataLength; i++){
				uart_putchar('n', NULL);
				val = waitForChar();
				
				PORTC = currAddr & 0xFF;
				PORTD &= 0b00100011;
				PORTD |= ((currAddr >> 8) & 7) << 2;
				PORTD |= ((currAddr >> 11) & 3) << 6;
				PORTA = val;
				PORTB &= ~(1 << PB0);
				_delay_us(24);
				PORTB |= (1 << PB0);
				_delay_ms(1);
				currAddr++;
			}
			uart_putchar('d', NULL);
			
			DDRA = 0x00;
			PORTA = 0x00;
			currAddr = 0;
			for(uint16_t i = 0; i < dataLength; i++){
				waitForChar();
				PORTC = currAddr & 0xFF;
				PORTD &= 0b00100011;
				PORTD |= ((currAddr >> 8) & 7) << 2;
				PORTD |= ((currAddr >> 11) & 3) << 6;
				PORTB &= ~(1 << PB1);
				_delay_us(24);
				val = PINA;
				PORTB |= (1 << PB1);
				currAddr++;
				uart_putchar((val & 15) + 48, NULL);
				uart_putchar((val >> 4) + 48, NULL);
				_delay_us(24);
			}*/
			
			goto loopForever;
		}else if(c == 'd'){ //Debug - Print first 512 bytes of ROM to console
			printf("\r\n");
			DDRC = 0xFF;
			DDRD = 0b11111110;
			DDRB = 0b11100111;
			PORTB = 0b00000011;
			DDRA = 0x00;
			PORTA = 0xFF;
			PORTB &= ~(1 << PB1);
			PORTB &= ~(1 << PB6);
			_delay_ms(1);
			for(uint16_t i = 0; i < 512; i++){
				setRomAddr(i);
				_delay_us(41);
				uint8_t a = PINA;
				printf("%02x ", a);
				if((i + 1) % 16 == 0) printf("\r\n");
			}
			PORTB |= (1 << PB1) | (1 << PB6);
			PORTA = 0x00;
			goto loopForever;
		}else if(c == '\r'){
			break;
		}
	}
	
	printf("\r\nSelect CPU speed\r\n1) Single step (debug)\r\n2) 10Hz\r\n3) 100Hz\r\n4) 1KHz\r\n5) 10KHz\r\n6) 100KHz\r\n7) 1MHz\r\n8) 3.33MHz\r\n");
	TCCR1A = (1 << COM1A0);
	TCCR1B = (1 << WGM12);
	
	uint8_t speedGrade = 0;
	while(true){
		char c = waitForChar();
		if(c == '1'){
			TCCR1A = TCCR1B = 0;
			debugger();
			goto loopForever;
		}
		if(c >= '2' && c <= '8'){
			speedGrade = c - '2';
			OCR1A = stockDivisors[speedGrade];
			TCCR1B |= stockPrescalers[speedGrade];
			break;
		}
	}
	
	//Release reset
	//Don't forget to stop pulling AD13 low!
	PORTA = 0x00;
	DDRB = 0b10000101;
	PORTB = 0b00000101;
	DDRD |= (1 << PD5);
	PORTD &= ~(1 << PD5);
	uint8_t origClockSettingsA = TCCR1A;
	uint8_t origClockSettingsB = TCCR1B;
	uint8_t b = 1;
	while(1){
		if(!(PINB & 0b1000000)){
			if(b){
				TCCR1A = 0;
				TCCR1B = 0; //Stop clock. Pretty much necesarry to catch UART ops at high CPU clock speeds.
				asm volatile("nop");
				asm volatile("nop");
				asm volatile("nop");
				asm volatile("nop");
				asm volatile("nop");
				if(!((PINB & 0b1000) >> 3)){
					DDRA = 0xFF;
					PORTA = (UCSRA & (1<<RXC)) ? UDR : 0;
					while(!((PINB & 0b1000) >> 3)){
						PORTD ^= (1 << PD5);
						appropriateDelay(speedGrade);
					}
					DDRA = 0x00;
					PORTA = 0x00;
					b = 0;
				}
				else if(!((PINB & 0b10000) >> 4)){
					DDRA = 0x00;
					uart_putchar(PINA, NULL);
					b = 0;
				}
				TCCR1A = origClockSettingsA;
				TCCR1B = origClockSettingsB;
			}
		}else b = 1;
	}
	
	loopForever:
	while(1){
		_delay_ms(500);
	}
}

void appropriateDelay(uint8_t speedGrade){
	switch(speedGrade){
		case 0:
			_delay_ms(50);
			return;
		case 1:
			_delay_ms(5);
			return;
		case 2:
			_delay_ms(0.5);
			return;
	}
	_delay_ms(0.05);
	return;
}

void debugger(){
	DDRB = 0b10000101;
	PORTB = 0b00000001;
	PORTA = 0x00;
	_delay_ms(1);
	for(uint8_t i = 0; i < 6; i++){
		PORTD |= (1 << PD5);
		_delay_us(240);
		PORTD &= ~(1 << PD5);
		_delay_us(240);
	}
	PORTB |= (1 << PB2);
	printf("\r\nEntered system debugger\r\nPress Enter to single-step\r\n");
	uint16_t currAddr;
	uint8_t currVal;
	uint32_t cycleCntr = 0;
	uint8_t read,write;
	uint8_t uartRead = 0;
	while(true){
		char c = waitForChar();
		if(c == '\r'){
			if(uartRead){
				DDRA = 0xFF;
				PORTA = 'a';
			}
			PORTD |= (1 << PD5);
			_delay_us(240);
			PORTD &= ~(1 << PD5);
			_delay_us(240);
			cycleCntr++;
			if(uartRead){
				DDRA = 0x00;
				PORTA = 0x00;
				uartRead = 0;
			}
			
			currVal = PINA;
			currAddr = PINC;
			currAddr |= (PIND & 0b00011100) << 6;
			currAddr |= (PIND & 0b11000000) << 5;
			currAddr |= (PINB & 0b11100000) << 8;
			read = !((PINB & 0b1000) >> 3);
			write = !((PINB & 0b10000) >> 4);
			printf("%04lx\t%02x %04u %01d", cycleCntr, currVal, currAddr, currAddr >> 13);
			if(read) printf(" R");
			if(write) printf(" W");
			printf("\r\n");
			if(!(PINB & 0b1000000)){
				if(read || write) printf("CPU requests UART");
				if(read){
					printf(" read.\r\n");
					uartRead = 1;
				}else if(write){
					printf(" write. It says: '%c'.\r\n", currVal);
				}
			}
		}
	}
}

void setRomAddr(uint16_t addr) {
	PORTC = addr & 0xFF;
	PORTD = 0;
	PORTD |= ((addr >> 8) & 7) << 2;
	PORTD |= ((addr >> 11) & 3) << 6;
	PORTB &= 0b01011111;
	if((addr >> 13) & 1) PORTB |= (1 << PB5);
	if((addr >> 14) & 1) PORTB |= (1 << PB7);
}

void writeByte(uint16_t addr, uint8_t byte) {
	DDRA = 0xFF;
	PORTB &= ~(1 << PB6);
	setRomAddr(0x5555);
	PORTA = 0xAA;
	PORTB &= ~(1 << PB0);
	_delay_us(1);
	PORTB |= (1 << PB0);
	_delay_us(1);
	setRomAddr(0x2AAA);
	PORTA = 0x55;
	PORTB &= ~(1 << PB0);
	_delay_us(1);
	PORTB |= (1 << PB0);
	_delay_us(1);
	setRomAddr(0x5555);
	PORTA = 0xA0;
	PORTB &= ~(1 << PB0);
	_delay_us(1);
	PORTB |= (1 << PB0);
	_delay_us(1);
	setRomAddr(addr);
	PORTA = byte;
	PORTB &= ~(1 << PB0);
	_delay_us(1);
	PORTB |= (1 << PB0);
	_delay_us(30);
	PORTB |= (1 << PB6);
	_delay_us(1);
	DDRA = 0x00;
	PORTA = 0xFF;
}

void eraseROM(){
	setRomAddr(0x5555);
	DDRA = 0xFF;
	PORTA = 0xAA;
	PORTB &= ~(1 << PB6);
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x2AAA);
	PORTA = 0x55;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x5555);
	PORTA = 0x80;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x5555);
	PORTA = 0xAA;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x2AAA);
	PORTA = 0x55;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x5555);
	PORTA = 0x10;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	for(int i = 0; i < 50; i++) _delay_ms(10);
	DDRA = 0x00;
	PORTA = 0xFF;
	setRomAddr(0x5555);
	DDRA = 0xFF;
	PORTA = 0xAA;
	PORTB &= ~(1 << PB6);
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x2AAA);
	PORTA = 0x55;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x5555);
	PORTA = 0x80;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x5555);
	PORTA = 0xAA;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x2AAA);
	PORTA = 0x55;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	_delay_us(2);
	setRomAddr(0x5555);
	PORTA = 0x10;
	PORTB &= ~(1 << PB0);
	_delay_us(2);
	PORTB |= (1 << PB0);
	for(int i = 0; i < 50; i++) _delay_ms(10);
	PORTB |= (1 << PB6);
	DDRA = 0x00;
	PORTA = 0xFF; 
}
