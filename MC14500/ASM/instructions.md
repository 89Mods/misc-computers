# Registers

To make processing of 8-bit words possible, several 8-bit wide shift-registers exist in this MC14500 computer. Accessing them will shift in or out data one bit at a time, LSB first, allowing for bit-serial processing of data. These are:

`dia` - Data In A (read-only)
`dib` - Data In B (read-only)
`mar` - Memory Address Register (write-only)
`dob` - Data Out Buffer (write-only)
`dr` - Destination Register (write-only)

There are also two flags "registers", which are actually locations in the 8-bit scratchpad memory.

`zf` - Zero Flag
`cf` - Carry Flag

Most of these registers act as a way to access data in the 256-byte RAM. The mar holds an address to use during load and store instructions. dia and dib are used to hold data read from RAM before processing, and dob is used to buffer data before being written into RAM. All store instructions implicitly use mar and dob as the address and value for the operation.

Most instructions will write their result into dob, though mar is also a possible destination.

As data is processed serially by shifting it out of dia and dib one bit at a time, and the shifted-in bits are considered undefined, dia and/or dib are considered to be "used up" by instructions that operate on them, meaning they no longer contain defined values after the operation.

Future revisions of this computer may use ring-shifters for dia and dib to preserve their original values.

The Destination Register, dr, is special as it is 15, 16 or 17 bits wide, depending on the implementation, and bits need to be shifted in MSB first. It buffers the value the program counter will be set to when a `jmp` is executed by the MC14500.

The `rtn` instruction of the MC14500 has been wired to clear the mar to 0, to make address setup faster, though the macro assembler currently does not yet use this in any way. Theoretically, it is possible to use this to skip shifting in the leading zeroes of an address.

## ldi [reg],[imm]

Loads immediate value into specified register. Immediate value is 8-bits wide, unless the register is the Destination Register.

Valid Registers: dr, mar, dob

Example: `ldi mar,66`

## ldmi [addr],[imm]

Stores immediate value into specified memory location. Immediate value is 8-bits wide.

Overwrites registers: mar, dob

Example: `ldmi 10,0`

## eqli [reg],[imm]

Compares value in specified register against immediate value. Immediate value is 8-bits wide. Zero flag is set if both values are equal, and cleared otherwise. dob is not written do.

Valid Registers: dia, dib

Affected flags: zf

Example: `eqli dia,33`

## txi [imm]

Transmits an 8-bit immediate value over the serial port.

Example: `txi 'a'`

## txd

Transmits contents of dia over the serial port.

Uses up registers: dia

## tfr [reg],{addr}

Copies value in dob to either dia or dib by storing it in memory at [mar], then immediately loading it again. Specifying an address overwrites [mar] beforehand.

Valid Registers: dia, dib

Overwrites registers: mar (if addr specified)

Example: `tfr dib,0`

## call [addr]

Backs up the address of following instruction into memory locations 255 (MSB) and 254 (LSB), then transfers program control to the specified address. Note that the location of the following instruction is determined during assembly, and hard-coded into the binary.

Overwrites registers: mar, dob

Example: `call a_subroutine`

## return {addr, addr}

Returns to subroutine callee by reading a return address from the specified address pair (MSB first). If no addresses are specified, the default pair of 255 (MSB) and 254 (LSB) is used, equivalent to an operation of `return 255,254`.

Overwrites registers: mar, dia

Example: `return`

## jmp {addr}

Transfers program control unconditionally to the address stored in dr. If an address is specified with the instruction, dr is overwritten beforehand.

Overwrites registers: dr (if address specified)

Example: `jmp a_label`

## jz {addr}

Transfers program control conditionally in the same manner as `jmp`, but only if the Zero Flag is set. Otherwise, the next instruction in sequence is executed.

Overwrites registers: dr (if address specified)

Example: `jz only_if_zero`

## jnz {addr}

Transfers program control conditionally in the same manner as `jmp`, but only if the Zero Flag is clear. Otherwise, the next instruction in sequence is executed.

Overwrites registers: dr (if address specified)

Example: `jnz not_zero`

## jc {addr}

Transfers program control conditionally in the same manner as `jmp`, but only if the Carry Flag is set. Otherwise, the next instruction in sequence is executed.

Overwrites registers: dr (if address specified)

Example: `jc we_have_a_carry`

## jnc {addr}

Transfers program control conditionally in the same manner as `jmp`, but only if the Carry Flag is clear. Otherwise, the next instruction in sequence is executed.

Overwrites registers: dr (if address specified)

Example: `jnc all_good`

## setup

Sets up the MC14500 for macro program execution. Inputs and Outputs are enabled, and the serial port reset. Must be the first instruction in a program, but may also be used any time as a soft reset.

## nop

Directly translates into a `ien 0` instruction. As inputs are expected by the assembler to always be enabled anyways, this acts as a nop. The actual MC14500 nopo and nopf instructions cannot be used for this purpose, as their flag signals are used to drive memory hardware.

## str {addr}

Stores the contents of dob into memory at [mar]. If an address if specified with the instruction, mar is overwritten with the given value beforehand.

Overwrites registers: mar (if address specified)

Example: `str 10`

## loda {addr}

Loads from memory at [mar] into dia. If an address is specified with the instruction, mar is overwritten with the given value beforehand.

Overwrites registers: dia, mar (if address specified)

Example: `loda 11`

## lodb {addr}

Loads from memory at [mar] into dib. If an address is specified with the instruction, mar is overwritten with the given value beforehand.

Overwrites registers: dib, mar (if address specified)

Example: `lodb 12`

## ldr [reg1],[reg2]

Copies value from reg2 into reg1.

Valid registers for reg1: dob, mar

Valid registers for reg2: dia, dib

Overwrites register specified in reg1

Uses up register specified in reg2

Example: `ldr mar,dia`

## ldrc [reg1],[reg2]

Copies the complemented value in reg2 into reg2.

Valid registers for reg1: dob, mar

Valid registers for reg2: dia, dib

Overwrites register specified in reg1

Uses up register specified in reg2

Example: `ldr dob,dib`

## lsl [reg]

Performs a logical shift left on the value in specified register, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise and the Carry Flag is loaded from the most significant bit of the input. A 0 is shifted into the least significant bit.

Valid registers: dia, dib

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `lsl dia`

## rlc [reg]

Performs a rotate left through carry on the value in the specified register, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise and the Carry Flag is loaded from the most significant bit of the input. The previous Carry Flag value is shifted into the least significant bit.

Valid registers: dia, dib

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `rlc dib`

## lsr [reg]

Performs a logical shift right on the value in specified register, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise and the Carry Flag is loaded from the least significant bit of the input. A 0 is shifted into the most significant bit.

Valid registers: dia, dib

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `lsr dib`

## rrc [reg]

Performs a rotate right through carry on the value in the specified register, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise and the Carry Flag is loaded from the least significant bit of the input. The previous Carry Flag value is shifted into the most significant bit.

Valid registers: dia, dib

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `rrc dia`

## and

Logic ANDs the values in dia and dib, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up registers: dia, dib

Overwrites registers: dob

Affected flags: zf

## ani [reg],[imm]

Logic ANDs the value in the specified register with an immediate value. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf

Example: `ani dia,128`

## xor

Logic XORs the values in dia and dib, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up registers: dia, dib

Overwrites registers: dob

Affected flags: zf

## xri [reg],[imm]

Logic XORs the value in the specified register with an immediate value, storing the result in dob. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf

Example: `xri dib,0x55`

## add

Adds the values in dia and dib, storing the result in dob. If the addition results in a carry, the Carry Flag is set, cleared otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up registers: dia, dib

Overwrites registers: dob

Affected flags: zf, cf

## adc

Adds the values in dia and dib and the Carry Flag, storing the result in dob. If the addition results in a carry, the Carry Flag is set, cleared otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up registers: dia, dib

Overwrites registers: dob

Affected flags: zf, cf

## sub

Subtracts the value in dib from the value in dia, storing the result in dob. If the subtraction results in a borrow, the Carry Flag is cleared, set otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up registers: dia, dib

Overwrites registers: dob

Affected flags: zf, cf

## suc

Subtracts the value in dib from the value in dia minus the complement of the Carry Flag, storing the result in dob. If the subtraction results in a borrow, the Carry Flag is cleared, set otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up registers: dia, dib

Overwrites registers: dob

Affected flags: zf, cf

## adi [reg],[imm]

Adds an immediate value onto the value in the specified register, storing the result in dob. If the addition results in a carry, the Carry Flag is set, cleared otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `adi dia,33`

## aci [reg],[imm]

Adds an immediate value and the Carry Flag onto the value in the specified register, storing the result in dob. If the addition results in a carry, the Carry Flag is set, cleared otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `aci dib,0b00010110`

## sui [reg],[imm]

Subtracts an immediate value from the specified register, storing the result in dob. If the subtraction results in a borrow, the Carry Flag is cleared, set otherwise. If the result if 0, the Zero Flag is set, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `sui dib,21`

## sci [reg],[imm]

Subtracts an immediate value minus the complement of the Carry Flag from the specified register, storing the result in dob. If the subtraction results in a borrow, the Carry Flag is cleared, set otherwise. If the result is 0, the Zero Flag is set, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `sci dia,0x05`

## cpy [reg]

Shorthand for `ldr dob,[reg]`

## cpl [reg]

Shorthand for `ldrc dob,[reg]`

## clc

Clears the Carry Flag.

Affected flags: cf

## sec

Sets the Carry Flag.

Affected flags: cf

## neg [reg]

Complements the specified register‘s value and adds the Carry Flag to it. If the Carry Flag is set beforehand, this results in a two’s complement negation. The Carry Flag is set if the addition results in a carry, cleared otherwise. This usage of the Carry Flag allows for numbers consisting of multiple bytes to be negated. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `neg dib`

## inc [reg]

Adds 1 to the value in the specified register, storing the result in dob. The Carry Flag is set if the addition resulted in a carry, cleared otherwise. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `inc dia`

Note: this instruction uses half adders instead of full adders, making it faster and more compact than `adi dia,1`.

## incc [reg]

Adds the Carry Flag to the value in the specified register, storing the result in dob. The Carry Flag is set if the addition resulted in a carry, cleared otherwise. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `incc dib`

Note: this instruction uses half adders instead of full adders, making it faster and more compact than `aci dib,1`.

## dec [reg]

Subtracts 1 from the value in the specified register, storing the result in dob. The Carry Flag is cleared if the subtraction results in a borrow, set otherwise. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `dec dia`

Note: this instruction uses half adders instead of full adders, making it faster and more compact than `sui dia,1`.

## decc [reg]

Subtracts the complement of the Carry Flag from the value in the specified register, storing the result in dob. The Carry Flag is cleared if the subtraction results in a borrow, set otherwise. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf, cf

Example: `decc dia`

Note: this instruction uses half adders instead of full adders, making it faster and more compact than `sci dia,1`.

## inc_nc [reg]

Adds 1 to the value in the specified register, storing the result in dob. The Carry Flag is not affected. The Zero Flag is set if the result is 0, cleared otherwise.

Uses up specified register

Overwrites registers: dob

Affected flags: zf

Example: `inc_nc dia`
