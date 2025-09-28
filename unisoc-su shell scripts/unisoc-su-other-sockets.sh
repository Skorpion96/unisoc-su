#!/system/bin/sh

if [ "$(whoami)" != "system" ]; then
    echo "This script must be run as the system user (UID 1000), run the reverse shell on the com.sprd.engineermode app before running this script."
    exit 1
fi

# Find the correct app lib path even with Scoped Storage naming
SYS_TOOLS=$(find /data/app -type d \( -path "*/com.sammy.systools*/lib/arm64" -o -path "*/com.sammy.systools*/lib/arm" \) 2>/dev/null | head -n1)

# Fallback if not found
if [ -z "$SYS_TOOLS" ]; then
  echo "Error: com.sammy.systools library path not found, install the app before running this script."
  return 0
fi

export PATH="$PATH:$SYS_TOOLS"

echo -n "Please input the socket you want to connect to: "
read usercmd
$usercmd
echo "Connection provided by the Elite x Skorpion96"
