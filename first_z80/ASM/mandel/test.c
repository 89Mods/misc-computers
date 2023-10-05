#include <stdio.h>

#undef nofloats

unsigned char globalsEndHere;

const char mandelSymbols[] = "..--:=itIJYVXRB#";
const char mandelColors[8][6] = {"\033[31m", "\033[31m", "\033[32m", "\033[33m", "\033[34m", "\033[35m", "\033[36m", "\033[37m"};
const char mandelColorReset[] = "\033[0m";

void main()
{
    int i = 0;
    int width;
    int height;
    float re;
    float imag;
    float r;
	unsigned int maxIters;
	float c_re;
	float c_im;
	float x,x1,x2;
	float y;
	unsigned int iteration;
    float c1,c2,c3,c4;
    signed int row;
    signed int col;
    float xx;
    float yy;
    
	for(int i2 = 0; i2 < 8; i2++) {
		printf("\tdb ");
		for(int j2 = 0; j2 < 6; j2++) {
			printf("%d,", mandelColors[i2][j2] & 0xFF);
		}
		printf("0,0\r\n");
	}
	printf("\tdb ");
	for(int j2 = 0; j2 < 6; j2++) {
		printf("%d", mandelColorReset[j2] & 0xFF);
		if(j2 != 5) printf(",");
		else printf("\r\n");
	}
    //asm("	ldAD R1,__INTS  ;.. R1 = INTERRUPT PC\n");
    //asm("   mark\n  inc R2\n    sex R2\n   ret\n");
    // char: 1
    // short: 2
    // int: 2
    // long, long long: 4
    // float, double, long double: 4
    //for(i = 0x6000; i < 0x8000; i++){
    //    *((unsigned char*)(i + 0x9000)) = *((unsigned char*)i);
    //}
    width = 238;
    height = 48;
    maxIters = 2048;
    re = -0.235125;
    imag = 0.827215;
    r = 4e-5;
	c1 = (float)4/width*r;
    c4 = (float)2/height*r;
    c2 = width/(float)2*c1;
    c3 = height/(float)2*c4;
    printf("test %d %f %d %f\r\n", height, r, maxIters, c4);
    x1 = (float)0;
    x2 = (float)0;
    x2 = x1 * x2;
    printf("%f\r\n", x2);
    for(row = 0; row < height; row++){
        c_im = imag + (row * c4) - c3;
        for(col = 0; col < width; col++){
            c_re = re + (col * c1) - c2;
            x = c_re; y = c_im;
            iteration = 0;
            do {
                xx = x*x;
                yy = y*y;
                //if(c_im < 0 && c_re < 0) printf("%f %f %f\r\n", xx, x, x*x);
                y = x*y;
				if(xx+yy >= 4) break;
                y += y;
                y += c_im;
                x = xx - yy + c_re;
                iteration++;
            }while(iteration < maxIters);
			
            if(iteration < maxIters) {
		iteration >>= 4;
                iteration %= 256;
                printf(mandelColors[iteration & 7]);
                iteration %= 16;
                //putchar(219);
		putchar(0xE2); putchar(0x96); putchar(0x88);
                //putchar(mandelSymbols[iteration]);
            }else {
                putchar(' ');
            }
        }
        printf("\r\n");
    }
}

unsigned char globalsStartHere;
