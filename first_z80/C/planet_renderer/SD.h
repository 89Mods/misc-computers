#ifndef SD_H_
#define SD_H_

char SDinit();
unsigned long SDsize();
char SDbeginRead(unsigned long sec);
void SDskip(int skip);
unsigned char SDreadByte();
int SDread(unsigned char* restrict buff, int count);
int SDreadPos();
void SDendRead();

#endif
