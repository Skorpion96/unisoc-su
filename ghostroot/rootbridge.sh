#!/bin/sh
if [ "$(whoami)" != "root" ]; then
    echo "This script must be run as the root user (UID 0) on the cmd_services shell, run unisoc-su before running this script."
    return 0
fi
BRIDGEHOME=/sdcard/Android/media/.rootbridge
HOME=/
if [ -s $BRIDGEHOME ]; then
    rm -r $BRIDGEHOME
fi
mkdir -p $BRIDGEHOME/in $BRIDGEHOME/out
execute_in_channel() {
    local cmd="$1"
    echo "[root executing] $cmd"
    if echo "$cmd" | grep -qE 'eval'; then
    echo "We don't do that here." > $BRIDGEHOME/out/result.txt
        return 1
    fi
    eval "$cmd" > $BRIDGEHOME/out/result.txt 2>&1
    return 0
}
while true; do
    if [ -s $BRIDGEHOME/in/command.txt ]; then
        cmd=$(cat $BRIDGEHOME/in/command.txt)
        execute_in_channel "$cmd"
        
        rm $BRIDGEHOME/in/command.txt
    fi
done
