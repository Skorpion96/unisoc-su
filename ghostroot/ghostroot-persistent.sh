#!/system/bin/sh
GETPROP=$(getprop ro.product.device)
sendroot() {
printf "$GETPROP:/ # "
read CMD
echo "$CMD" > /sdcard/rootbridge/in/command.txt
sleep 0.4
cat /sdcard/rootbridge/out/result.txt
sendroot
}

sendroot