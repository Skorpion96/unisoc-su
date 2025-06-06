#!/system/bin/sh

# Find the correct app lib path even with Scoped Storage naming
SYS_TOOLS=$(find /data/app -type d -path "*/com.sammy.systools*/lib/arm64" 2>/dev/null | head -n1)

# Fallback if not found
if [ -z "$SYS_TOOLS" ]; then
  echo "Error: com.sammy.systools library path not found!"
  exit 1
fi

# Set environment variables
export TERMINFO=/sdcard/terminfo
export TERM=xterm-256color
export PATH="$PATH:$SYS_TOOLS"

echo "Go on EngineerMode Adb Shell activity, on the first shell prompt input 'setprop persist.sys.cmdservice.enable enable', don't press start, go on the second activity and paste the full cli-pie PATH including the binary, go to the setprop activity, press start now, then go on the cli-pie activity and press start as fast as possible, it should tell 'Connected to the server', after that press enter on this script to get a root shell on cmd_services"
read -n 1 -s

echo "Welcome to the Unisoc-SU Shell (aka CVE-2022-47339 reborn in 2025)\n"

cli-pie

echo "Unisoc-SU Shell provided by the Elite x Skorpion96"
