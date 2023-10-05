#ifndef Z80IO_H_
#define Z80IO_H_

void setOut(unsigned char x);
unsigned char getIn();
void digitalOut(char bit, char state);
char digitalIn(char bit);
void delay(short len);

#endif
