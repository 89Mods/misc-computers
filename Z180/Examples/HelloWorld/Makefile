CC = zcc
TARGET = z180
PRAGMAS = pragma.inc
CFLAGS = -O3 -lm -vn -clib=new -startup=0 -m -I../Include/
HOSTCC = gcc

all: hello.bin
.PHONY: all

romtool: romtool.c
	${HOSTCC} romtool.c -o ./romtool

hello.bin: hello.c pragma.inc romtool
	$(CC) +${TARGET} $(CFLAGS) -pragma-include:${PRAGMAS} hello.c -o hello -create-app
	./romtool
	rm hello_CODE.bin hello

clean:
	rm -f hello.bin FLASH.bin hello.map romtool
