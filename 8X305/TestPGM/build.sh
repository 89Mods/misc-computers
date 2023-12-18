#!/bin/bash

set -e

../asl -cpu 8x305 -olist test.lst test.asm
../p2bin test.p
java ToVerilogHex.java test.bin verilog.txt
