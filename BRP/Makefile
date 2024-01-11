CC = gcc
LD = gcc

CFLAGS += -O1 -g -Wall
LDFLAGS += -lm

all: brp

brp.o: brp.c
	$(CC) $(CFLAGS) -c -o $@ $<

brp: brp.o
	$(LD) -o brp $^ $(LDFLAGS)

clean:
	rm -rf *.o brp

install:
	install -m 557 brp /usr/bin

.PHONY: all echo clean
