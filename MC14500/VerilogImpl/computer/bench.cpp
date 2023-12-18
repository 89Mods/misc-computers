#include "Vtb.h"
#include "verilated.h"
#include <iostream>

static Vtb top;

void clocks(int c) {
	for(int i = 0; i < c*2; i++) {
		Verilated::timeInc(1);
		top.clk = !top.clk;
		top.eval();
	}
}

double sc_time_stamp() { return 0; }

int main(int argc, char** argv, char** env) {
#ifdef TRACE_ON
	printf("Warning: tracing is ON!\r\n");
	Verilated::traceEverOn(true);
#endif
	top.clk = 0;
	top.rstb = 0;
	clocks(4);
	top.rstb = 1;
	while(!Verilated::gotFinish()) {
		Verilated::timeInc(1);
		top.clk = !top.clk;
		top.eval();
	}
	top.final();
	return 0;
}
