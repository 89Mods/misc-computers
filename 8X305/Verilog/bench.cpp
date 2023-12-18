#include "Vtb.h"
#include "verilated.h"
#include <iostream>

static Vtb top;

void clocks(int c) {
	for(int i = 0; i < c*2; i++) {
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.clk = !top.clk;
		top.eval();
	}
}

double sc_time_stamp() { return 0; }

int main(int argc, char** argv, char** env) {
	Verilated::traceEverOn(true);
	top.clk = 0;
	top.rst = 1;
	clocks(4);
	top.rst = 0;
	int counter = 0;
	while(!Verilated::gotFinish()) {
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.clk = !top.clk;
		top.eval();
		if(counter++ == 1000) break;
	}
	printf("Failed: %u\r\n", top.failed);
	//clocks(64);
	top.final();
	return 0;
}
