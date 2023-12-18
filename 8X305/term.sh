# Opening a terminal at 14.4K baud in Linux actually involves a bit of hacking. This bash script will end with /dev/ttyS0 being opened at 14.4K baud in screen.

#! /bin/bash

setserial /dev/ttyS0 spd_cust
setserial /dev/ttyS0 divisor 8
screen /dev/ttyS0 38400
