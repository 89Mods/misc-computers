#!/bin/bash

set - e

verilator -DBENCH -Wno-fatal --timing --top-module tb -cc -exe --trace-depth 2 --trace bench.cpp computer.v 8x305.v
cd obj_dir
make -f Vtb.mk
cd ..
