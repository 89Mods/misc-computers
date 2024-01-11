#!/bin/bash

set -e

../asl -cpu 8x305 -olist mul.lst mul.asm
../p2bin mul.p
java ../TestPGM/ToVerilogHex.java mul.bin verilog.txt
