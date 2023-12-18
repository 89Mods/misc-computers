#!/bin/bash

set -e

#TRACE_FLAGS="--trace-depth 6 --trace -DTRACE_ON -CFLAGS '-DTRACE_ON'"
verilator -DBENCH -Wno-fatal --timing --top-module tb -cc -exe ${TRACE_FLAGS} bench.cpp tb.v computer.v HC00.v HC04.v HC08.v HC32.v HC74.v HC138.v HC163.v HC164.v HC165.v HC244.v HC259.v HC4051.v HY6116A.v ../mc14500/MC14500.v HC175.v
cd obj_dir
make -f Vtb.mk
cd ..
