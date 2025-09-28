#!/system/bin/sh

if [ "$(whoami)" != "system" ]; then
    echo "This script must be run as the system user (UID 1000), run the reverse shell on the com.sprd.engineermode app before running this script."
    exit 1
fi

# Find the correct app lib path even with Scoped Storage naming
SYS_TOOLS=$(find /data/app -type d \( -path "*/com.sammy.systools*/lib/arm64" -o -path "*/com.sammy.systools*/lib/arm" \) 2>/dev/null | head -n1)

# Fallback if not found
if [ -z "$SYS_TOOLS" ]; then
  echo "Error: com.sammy.systools library path not found, install the app before running this script. If you didn't understand how the exploit works run one of the tutorial scripts or read the README.md/watch the video tutorials carefully."
  exit 1
fi

# Set environment variables
export TERMINFO=/sdcard/terminfo
export TERM=xterm-256color
export PATH="$PATH:$SYS_TOOLS"

echo -n "Please input the socket you want to connect to: "
read usercmd
$usercmd
echo "Connection provided by the Elite x Skorpion96"
