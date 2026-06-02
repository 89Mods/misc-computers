ASL = ../../../asl-avalonsemi/asl
P2BIN = ../../../asl-avalonsemi/p2bin
ARCH = 65C02

%.p: %.asm
	$(ASL) -L -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

flash: test.bin
	brp /dev/ttyUSB0 39SF010 test.bin

clean:
	rm -rf *.bin *.p *.lst

all: clean test.bin

.PHONY: all
