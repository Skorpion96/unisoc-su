#!/bin/sh

# Define port and address
HOST="127.0.0.1"
PORT="1234"

# Check if the listener is available
if echo | /system/bin/busybox nc $HOST $PORT >/dev/null 2>&1; then
echo "Welcome to the Unisoc Eng Mode App System Shell"
echo "Enter Commands"
    # Attempt to connect to the listener and provide a shell
   /system/bin/busybox nc $HOST $PORT
echo "Unisoc Eng Mode App System Shell provided by the Elite x Skorpion96"
else
    echo "Failed to connect to listener on ${HOST}:${PORT}"
    echo "Please run \"busybox nc 127.0.0.1 1234 -e /system/bin/sh\" on com.sprd.engineermode app or check if the port is already in use"
fi
