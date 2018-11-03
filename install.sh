#!/bin/bash


echp `pwd`

LUATOOL=./luatool.py
ESPTOOL=esptool.py
DEFPORT=/dev/ttyUSB0
DEFMODE=reflash
PORT=${1:-$DEFPORT}
MODE=${2:-$DEFMODE}
BAUD=115200
FLASHTOOL=./fw/flash.sh

#File list to upload
files=(
    mqtt.lua
    config.lua
    http.lua
    page.tmpl
    telnet.lua
    led.lua
    init.lua
)

function run_cmd() {
    local reply
    exec 4<$PORT 5>$PORT
    stty -F $PORT speed $BAUD -echo > /dev/null
    #Clean input buffer
    read -t 1 -n 100000 discard <&4
    echo $1 >&5
    read reply <&4
    exec 4<&- 5>&-
    echo $reply
}

if [[ $MODE != "noflash" ]]; then
    MODE=$DEFMODE
fi

echo "Board will be erased and all data will be lost!"	

if [[ $MODE = "reflash" ]]; then
    read -p "Hold button on the board and reboot it. Then press ENTER to continue..."
   
    #Flash chip
    echo "Programming..."
    $FLASHTOOL $PORT
    if [[ $? != 0 ]]; then
        exit
    fi

    sleep 5
else
    echo "FW flash skipped.."    
fi

#Detect Nodemcu firmware
REPLY=$(run_cmd "=node.heap()")
if [ -z "$REPLY" ]; then
    echo "No answer from Nodemcu! No RTS conected?"
    read -p "Reboot device manualy, then press ENTER to continue..."
fi

#Clear files on flash memory
echo "Clearing..."
$LUATOOL -p $PORT -b $BAUD --wipe
echo

sleep 3

#Do upload
for fname in ${files[@]}; do
    echo "Uploading: $fname..."
    $LUATOOL -p $PORT -b $BAUD -f ./$fname --bar --delay 0.02
    if [[ $? != 0 ]]; then
	echo "Upload error!"
        exit 
    fi
done

#Verify uploaded file list
list=$($LUATOOL -p $PORT -b $BAUD --list | awk -F '[:,]' '/^name/{print $2}')

if [[ $(echo ${files[@]} ${list[@]} | tr ' ' '\n' | sort | uniq -d | wc -l) == ${#files[@]} ]]; then
	echo "---------------"
	echo -e "Uploaded ${#files[@]} files.\nDone"
else
	echo "Upload error!"
	exit
fi

echo "Rebooting..."
run_cmd "node.restart()"
