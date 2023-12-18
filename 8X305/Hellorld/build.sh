#!/bin/bash

set -e

../asl -cpu 8x305 -olist hellorld.lst hellorld.asm
../p2bin hellorld.p
java ../TestPGM/ToVerilogHex.java hellorld.bin verilog.txt
