#!/system/bin/sh
GETPROP=$(getprop ro.product.device)
ghostroot() {
printf "$GETPROP:/ # "
read CMD
echo "$CMD" > /sdcard/rootbridge/in/command.txt
sleep 0.4
cat /sdcard/rootbridge/out/result.txt
ghostroot
}

ghostroot
