#!/bin/bash

FW=nodemcu-master-8-modules-2018-11-02-19-32-45-float.bin
DEFPORT=/dev/ttyUSB0
BAUD=250000
ESPTOOL=esptool.py

PORT=${1:-$DEFPORT}

FILE=$(cd `dirname $0` && pwd)/$FW

if [ ! -f $FILE ]; then
    echo "Firmware file $FILE not found"
    exit
fi

python $ESPTOOL --port $PORT --baud $BAUD write_flash -fm qio 0x00000 $FILE
