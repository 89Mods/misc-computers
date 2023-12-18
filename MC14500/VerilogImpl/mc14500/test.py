import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_cpu(dut):
	dut._log.info("start")
	dut.RST.value = 1
	dut.I.value = 0
	dut.DATA_in.value = 0
	clock = Clock(dut.CLK, 2, units="us")
	cocotb.start_soon(clock.start())
	await ClockCycles(dut.CLK, 5)
	dut.RST.value = 0
	
	await ClockCycles(dut.CLK, 2)
	dut.DATA_in.value = 1
	dut.I.value = 0b1010
	await ClockCycles(dut.CLK, 1)
	dut.I.value = 0b1011
	await ClockCycles(dut.CLK, 1)
	dut.I.value = 0b1111
	await ClockCycles(dut.CLK, 1)
	dut.I.value = 0b0001
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	dut.I.value = 0b0010
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	
	dut.DATA_in.value = 1
	dut.I.value = 0b0011
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	
	dut.I.value = 0b0001
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	
	dut.I.value = 0b0100
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	
	dut.I.value = 0b0101
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	
	dut.I.value = 0b0011
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	
	dut.I.value = 0b0110
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	
	dut.I.value = 0b0111
	dut.DATA_in.value = 0
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	await ClockCycles(dut.CLK, 1)
	assert dut.RR.value == 1
	await ClockCycles(dut.CLK, 1)
	assert dut.RR.value == 0
	dut.DATA_in.value = 1
	await ClockCycles(dut.CLK, 1)
	assert dut.RR.value == 1
	await ClockCycles(dut.CLK, 1)
	assert dut.RR.value == 1
	await ClockCycles(dut.CLK, 1)
	assert dut.RR.value == 1
	
	assert dut.WRITE.value == 0
	dut.I.value = 0b1000
	await ClockCycles(dut.CLK, 1)
	await Timer(1, units="us")
	assert dut.WRITE.value == 1
	assert dut.DATA_out.value == dut.RR.value
	await ClockCycles(dut.CLK, 1)
	
	dut.I.value = 0b0010
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	
	dut.I.value = 0b1000
	await ClockCycles(dut.CLK, 1)
	await Timer(1, units="us")
	assert dut.WRITE.value == 1
	assert dut.DATA_out.value == dut.RR.value
	await ClockCycles(dut.CLK, 1)
	
	dut.I.value = 0b1001
	await ClockCycles(dut.CLK, 1)
	await Timer(1, units="us")
	assert dut.WRITE.value == 1
	assert dut.DATA_out.value != dut.RR.value
	await ClockCycles(dut.CLK, 1)
	
	dut.I.value = 0b0001
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 1
	
	dut.I.value = 0b1001
	await ClockCycles(dut.CLK, 1)
	await Timer(1, units="us")
	assert dut.WRITE.value == 1
	assert dut.DATA_out.value != dut.RR.value
	await ClockCycles(dut.CLK, 1)
	
	dut.I.value = 0b1100
	await ClockCycles(dut.CLK, 2)
	assert dut.JMP == 1
	assert dut.WRITE.value == 0
	
	dut.I.value = 0b1101
	await ClockCycles(dut.CLK, 2)
	assert dut.RTN == 1
	assert dut.JMP == 0
	assert dut.WRITE.value == 0
	assert dut.FLAG_F == 0
	
	dut.I.value = 0b1111
	await ClockCycles(dut.CLK, 2)
	assert dut.FLAG_F == 1
	assert dut.RTN == 0
	assert dut.JMP == 0
	assert dut.WRITE.value == 0
	
	assert dut.RR.value == 1
	dut.DATA_in.value = 0
	dut.I.value = 0b1110
	await ClockCycles(dut.CLK, 1)
	dut.I.value = 0b0011
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	
	dut.DATA_in.value = 1
	dut.I.value = 0b1110
	await ClockCycles(dut.CLK, 1)
	dut.I.value = 0b0001
	await ClockCycles(dut.CLK, 2)
	assert dut.RR.value == 0
	await ClockCycles(dut.CLK, 1)
	assert dut.RR.value == 1
