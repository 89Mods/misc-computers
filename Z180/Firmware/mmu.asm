ADDR_CBAR equ 0x3A
ADDR_CBR equ 0x38
ADDR_BBR equ 0x39

init:
	di
	;Starting up, the system has access to no RAM (all addresses map to ROM). So, this first bit is in assembly. C cannot handle this.
	;Relocate internal I/O addresses to the very bottom. Will collide with external I/O address asignments otherwise
	ld a,0b00000000
	out0 (0x3F),a
	;MMU configuration
	;Starting at address 0x1000, there shall be RAM
	
	ld a,0b00100001 ;Start BA at second 4K block (address 0x1000)
					;Start CA1 at third 4K block (enforcing only 4KiB of RAM for bootloader)
					;CA0 is now used to access this ROM code
	out0 (ADDR_CBAR),a
	
	;Physical base address for bank accesses
	;Set to overlap with beginning of RAM at 0x40000
	ld a,0x3F
	out0 (ADDR_BBR),a
	
	; Just making sure this does not interfer
	ld a,0x00
	out0 (ADDR_CBR),a
	
	;We now have RAM from 0x2000 to 0xF000 (CA1 blocks the rest and will be used by the bootloader), and can continue in C land
	;Actually, only 4096 bytes of RAM (up to 0x3000) should be used, as everything above overlaps with the user program area
	jp 0x00A0
