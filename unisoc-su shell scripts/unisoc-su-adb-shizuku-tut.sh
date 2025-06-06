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

echo "On EngineerMode Adb Shell Activity enter the full cli-pie PATH including the cli-pie applet, don't press start, prepare 'rish -c "setprop persist.sys.cmdservice.enable enable"' or 'adb shell setprop persist.sys.cmdservice.enable enable' then press enter on this setprop shell, as fast as possible go back to the EngineerMode Activity you prepared first and press start, then press enter on this script shell to enter the cmd_services server"
read -n 1 -s

echo "Welcome to the Unisoc-SU Shell (aka CVE-2022-47339 reborn in 2025)\n"

cli-pie

echo "Unisoc-SU Shell provided by the Elite x Skorpion96"
