#include <stdio.h>
#include <stdlib.h>

void main() {
    FILE *fptr = fopen("mmu.bin", "rb");
    if(!fptr) {
        printf("Couldn’t open mmu.bin");
        exit(1);
    }
    unsigned char buff[160];
    for(int i = 0; i < 128; i++) buff[i] = 0;
    int read = fread(buff, 1, 0x66, fptr);
    fclose(fptr);
    
    fptr = fopen("nmi.bin", "rb");
    if(!fptr) {
        printf("Couldn’t open nmi.bin");
        exit(1);
    }
    read = fread(buff+0x66, 1, 0x3A, fptr);
    fclose(fptr);
    for(int i = read; i < 0x3A; i++) buff[0x66+i] = 0;

    fptr = fopen("boot.bin", "rb");
    if(!fptr) {
        printf("Couldn’t open boot.bin");
        exit(1);
    }

    FILE *fptrO = fopen("EPROM.bin", "wb");
    fwrite(buff, 1, 160, fptrO);
    while(1) {
        read = fread(buff, 1, 128, fptr);
        if(read > 0) fwrite(buff, 1, read, fptrO);
        if(read != 128) break;
    }

    fclose(fptr);
    fclose(fptrO);
}
