#!/system/bin/sh

if [ "$(whoami)" != "system" ]; then
    echo "This script must be run as the system user (UID 1000), run the reverse shell on the com.sprd.engineermode app before running this script."
    return 0
fi

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
  echo "Error: com.sammy.systools library path not found, install the app before running this script."
  return 0
fi

echo -n "Please input the socket you want to connect to: "
read usercmd
$usercmd
echo "Connection provided by the Elite x Skorpion96"
