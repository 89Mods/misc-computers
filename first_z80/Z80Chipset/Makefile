CC_FLAGS        = -O3 -mmcu=atmega32 -DEMBEDDED -ffunction-sections -DAVR_ASM
LD_FLAGS        = -O3 -mmcu=atmega32 -Wl,--gc-sections
CC              = avr-gcc
LD              = avr-gcc
EXTRA           = avr-size -Ax main && avr-objcopy -j .text -j .data -O ihex main main.hex

LDFLAGS = $(LD_FLAGS) -Wall -Wextra
CCFLAGS = $(CC_FLAGS) -Wall -Wextra

OBJS	= main.o

main.o: main.c
	$(CC) $(CCFLAGS) -o main.o -c main.c

out: $(OBJS)
	$(LD) -o main $(OBJS) $(LDFLAGS)
	$(EXTRA)
