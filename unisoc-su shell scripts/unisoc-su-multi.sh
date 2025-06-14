#!/system/bin/sh

# Find the correct app lib path even with Scoped Storage naming
SYS_TOOLS=$(find /data/app -type d \( -path "*/com.sammy.systools*/lib/arm64" -o -path "*/com.sammy.systools*/lib/arm" \) 2>/dev/null | head -n1)

# Fallback if not found
if [ -z "$SYS_TOOLS" ]; then
  echo "Error: com.sammy.systools library path not found!"
  exit 1
fi

# Set environment variables
export TERMINFO=/sdcard/terminfo
export TERM=xterm-256color
export PATH="$PATH:$SYS_TOOLS"

echo "Welcome to the Unisoc-SU Shell (aka CVE-2022-47339 reborn in 2025)\n"

cli-pie

echo "Unisoc-SU Shell provided by the Elite x Skorpion96"
