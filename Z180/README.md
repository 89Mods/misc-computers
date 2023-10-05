# Z180 Mini Board

These are the files for my Z180 Arduino-like computer.

`HW` contains the KiCad project for the hardware, including production-ready PCB design. 27C1001 EPROM may be substituted with a 39SF010 flash ROM.

`Firmware` is the firmware to be put onto the EPROM/flash. Only needs to be done once. The build output is `EPROM.bin`

`Examples` right now just contains one example on how to use the system, but will be more in the future. The build output is `FLASH.bin` and needs to be loaded onto the SPI Flash.

Programs are loaded from the SPI Flash on the PCB. The SPI bus is broken out also, and functions exist in the `z180mini.h` header file to use it. The SPI flash also stays accessible after the bootloader is done.

Right now, the firmware recognizes 25MX1005 and 25Q32 ROMs by their unique device ID. However, many chips use the same protocol and you’re free to substitute. But you may need to add your SPI Flash’s device ID to the `allowed_rom_ids` ROM in the firmware and re-compile it.
