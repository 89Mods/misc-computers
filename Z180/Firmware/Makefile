CC = zcc
TARGET = z180
PRAGMAS = pragma.inc
CFLAGS = -O3 -lm -vn -clib=new -startup=1 -m
HOSTCC = gcc

all: boot.bin
.PHONY: all

mmu.bin: mmu.asm
	z88dk-z80asm -m=z180 -b mmu.asm
	rm mmu.o

nmi.bin: nmi.asm
	z88dk-z80asm -m=z180 -b nmi.asm
	rm nmi.o

romtool: romtool.c
	${HOSTCC} romtool.c -o ./romtool

boot.bin: boot.c pragma.inc romtool mmu.bin nmi.bin
	$(CC) +${TARGET} $(CFLAGS) -pragma-include:${PRAGMAS} boot.c -o boot -create-app
	rm boot_BSS.bin boot_CODE.bin boot boot_DATA.bin
	./romtool

clean:
	rm -f boot.bin EPROM.bin mmu.bin boot.map nmi.bin romtool
