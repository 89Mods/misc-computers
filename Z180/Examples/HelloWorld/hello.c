#include <z180mini.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

/*
 * Non-maskable interrupt handler (TRAP button)
 * Despite what the name suggests, this interrupt too can be masked (though in software)
 * set_nmi_handler(NULL); will disable it
 * Toggles Flag LED
 */
static volatile bool status = false;
void nmi_handler(void) __z88dk_fastcall {
	status = !status;
	if(status) set_status();
	else clear_status();
	for(uint8_t i = 75; i != 0; i--); //Crude software de-bounce
}

/*
 * Timer 0 interrupt handler
 * Prints a CHIRP! every one second
 */
static volatile uint8_t int_counter = 0;
static volatile uint16_t chirp_counter = 0;
void trupt_handler(void) __z88dk_fastcall __critical __interrupt(0) {
	//Timer interrupt requests need to be cleared manually. Its just how this CPU works.
	//Function returns current timer value, as reading it is required for clearing the interrupt request
	clear_timer_int(TIMER0);
	
	//Only once a second, please
	int_counter++;
	if(int_counter == 10) {
		chirp_counter++;
		char strbuff[20];
		sprintf(strbuff, "CHIRP! #%u\r\n", chirp_counter);
		puts(strbuff);
		int_counter = 0;
	}
}

void main(void) {
	clear_status(); //Clear status LED
	set_nmi_handler(&nmi_handler); //Set up pointer to our NMI handler
	
	//Set up timer interrupt
	cli(); //Global interrupt disable
	set_timer_period(TIMER0, 30000); //6MHz / 20 / 30,000 = 10 reloads per second (the prescaler of 20 is fixed)
	set_timer_enabled(TIMER0, true); //Enable timer, note: its a DOWN-counter that reloads with the period value on reaching 0
	set_timer_interrupt_enabled(TIMER0, true); //Enable interrupt when timer reaches 0
	set_interrupt_handler(INT_PRT0, &trupt_handler); //INT_PRT0 is interrupt for TIMER0
	sei(); //Global interrupt enable
	
	port_mode(PORTA, OUTPUT);
	uint16_t counter = 0;
	while(1) {
		counter++;
		port_write(PORTA, counter >> 7);
		//Can also do things like digital_write(PORTA, 5, HIGH); for more granular control
	}
}
