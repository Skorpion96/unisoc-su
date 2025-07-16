#!/bin/sh
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
  sleep 0.2
done
