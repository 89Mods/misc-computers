#pragma output REGISTER_SP = 0x1FFF
#pragma output CLIB_MALLOC_HEAP_SIZE=0
#pragma output CLIB_STDIO_HEAP_SIZE=0
#pragma output CRT_ORG_CODE=0x00A0 ; Ugly hack: put 160 bytes of padding before beginning of C code to put MMU init code into later (as well as interrupt handlers)
#pragma output CRT_ORG_DATA=0x1000
