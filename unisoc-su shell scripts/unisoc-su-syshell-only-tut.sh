#!/system/bin/sh

echo echo "Go on EngineerMode Adb Shell activity, on the first shell prompt input 'setprop persist.sys.cmdservice.enable enable', don't press start, go on the second activity and paste the full cli-pie PATH including the binary, go to the setprop activity, press start now, then go on the cli-pie activity and press start as fast as possible, it should tell 'Connected to the server', after that press end on the first setprop activity and delete the content, then enter the reverse shell command for your system on the setprop activity and press start, then press enter on this script to continue..."
read -n 1 -s

echo "run these commands:'/system/bin/nc 127.0.0.1 1234' or run the UnisocEngsyshell for your system, then 'source /sdcard/tools.sh' and then 'cli-pie', this must be done manually as the script would drop after entering the system shell"
