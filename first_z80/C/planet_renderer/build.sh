zcc +z80 -vn -O3 -startup=1 -clib=new z80io.c SD.c renderer.c -o renderer -lm -create-app -pragma-include:pragma.inc
