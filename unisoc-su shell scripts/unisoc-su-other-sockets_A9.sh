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

echo -n "Please input the socket you want to connect to: "
read usercmd
$usercmd
echo "Connection provided by the Elite x Skorpion96"
