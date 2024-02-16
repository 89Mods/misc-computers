#!/bin/bash

set -e

../asl -cpu 8x305 -olist mandel.lst mandel.asm
../p2bin mandel.p
java ../TestPGM/ToVerilogHex.java mandel.bin verilog.txt
