#!/bin/sh

# Define port and address
HOST="127.0.0.1"
PORT="1234"

# List of netcat binary candidates (full command including 'nc')
NC_LIST="
/system/bin/busybox nc
/system/bin/toybox nc
/system/xbin/busybox nc
/system/bin/nc
/data/data/com.termux/files/usr/bin/nc
/system/bin/ncat
"

# Loop through each candidate
for NC_CMD in $NC_LIST; do
    NC_BIN=$(echo "$NC_CMD" | cut -d' ' -f1)  # Extract actual binary path

    if [ -x "$NC_BIN" ]; then
        if echo | $NC_CMD $HOST $PORT >/dev/null 2>&1; then
            echo "Welcome to the Unisoc Eng Mode App System Shell"
            echo "Enter Commands"
            $NC_CMD $HOST $PORT
            echo "Unisoc Eng Mode App System Shell provided by the Elite x Skorpion96"
           CONNECTED=1
          break
        fi
    fi
done
if [ "$CONNECTED" -eq 0 ]; then
    echo "Failed to connect to listener on ${HOST}:${PORT}"
    echo "Please run the reverse shell on com.sprd.engineermode app or check if the port is already in use"
fi
