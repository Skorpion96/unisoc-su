#!/system/bin/sh

if [ "$(whoami)" != "system" ]; then
    echo "This script must be run as the system user (UID 1000), run the reverse shell on the com.sprd.engineermode app before running this script."
    exit 1
fi

# Try to glob the directory
for dir in /data/app/com.sammy.systools*/lib/arm*; do
    if [ -d "$dir" ]; then
        export PATH="$dir:$PATH"
        break
    fi
done

echo "Welcome to the Unisoc-SU Shell (aka CVE-2022-47339 reborn in 2025)"
cli-pie
echo "Unisoc-SU Shell provided by the Elite x Skorpion96"
