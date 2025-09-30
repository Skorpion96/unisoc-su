#!/bin/sh
if [ "$(whoami)" != "root" ]; then
    echo "This script must be run as the root user (UID 0) on the cmd_services shell, run unisoc-su before running this script."
    return 0
fi

HOME=/
if [ -s /sdcard/rootbridge ]; then
    rm -r /sdcard/rootbridge
fi
mkdir -p /sdcard/rootbridge/in /sdcard/rootbridge/out
execute_in_channel() {
    local cmd="$1"
    echo "[root executing] $cmd"
    if echo "$cmd" | grep -qE 'eval'; then
    echo "We don't do that here." > /sdcard/rootbridge/out/result.txt
        return 1
    fi
    eval "$cmd" > /sdcard/rootbridge/out/result.txt 2>&1
    return 0
}
while true; do
    if [ -s /sdcard/rootbridge/in/command.txt ]; then
        cmd=$(cat /sdcard/rootbridge/in/command.txt)
        execute_in_channel "$cmd"
        
        rm /sdcard/rootbridge/in/command.txt
    fi
done
