#!/system/bin/sh

echo "On EngineerMode Adb Shell Activity enter the full cli-pie PATH including the cli-pie applet, don't press start, prepare 'rish -c "setprop persist.sys.cmdservice.enable enable"' or 'adb shell setprop persist.sys.cmdservice.enable enable' then press enter on this setprop shell, as fast as possible go back to the EngineerMode Activity you prepared first and press start, it should tell 'Connected to the server', after that enter the reverse shell command for your system on the second activity and press start, then press enter on this script to continue..."
read -n 1 -s

echo "run these commands:'/system/bin/nc 127.0.0.1 1234' or run the UnisocEngsyshell for your system, then 'source /sdcard/tools.sh' and then 'cli-pie', this must be done manually as the script would drop after entering the system shell"
