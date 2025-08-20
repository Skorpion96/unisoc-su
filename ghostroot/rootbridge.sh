#!/bin/sh

if [ "$(whoami)" != "root" ]; then
    echo "This script must be run as the root user (UID 0) on the cmd_services shell, run unisoc-su before running this script."
    exit 1
fi

HOME=/
if [ -s /sdcard/rootbridge ]; then
cmd=$(rm -r /sdcard/rootbridge)
fi
mkdir -p /sdcard/rootbridge/in /sdcard/rootbridge/out
while true; do
  if [ -s /sdcard/rootbridge/in/command.txt ]; then
    cmd=$(cat /sdcard/rootbridge/in/command.txt)
    echo "[root executing] $cmd"
    eval "$cmd" > /sdcard/rootbridge/out/result.txt 2>&1
    rm /sdcard/rootbridge/in/command.txt
  fi
done
