#!/bin/sh
echo "Welcome to the Unisoc Eng App System Shell Enabler Script\n"
if [ "$(whoami)" != "shell" ]; then
    echo "This script must be run as the Shell user (UID 2000)."
    exit 1
fi
echo "Running as Shell user!\n"
BRAND=$(getprop ro.product.brand)
echo "Disabling $BRAND Update APP to not allow $BRAND-kun or Unisoc Kill the Exploit in the future"
echo "Detected brand: $BRAND"
# Define update apps for different brands
case "$BRAND" in
    "ZTE")
        pm disable-user --user 0 com.zte.zdm
        ;;
    "Huawei")
        pm disable-user --user 0 com.huawei.android.hwouc
        ;;
    "Samsung")
        pm disable-user --user 0 com.wssyncmldm
        ;;
    "Xiaomi")
        pm disable-user --user 0 com.xiaomi.discover
        pm disable-user --user 0 com.xiaomi.mipicks
        ;;
    "OnePlus")
        pm disable-user --user 0 net.oneplus.odm
        ;;
    "Realme" | "Oppo" | "Vivo")
        pm disable-user --user 0 com.oppo.ota
        ;;
    "Google")
        pm disable-user --user 0 com.google.android.gms
        pm disable-user --user 0 com.google.android.gms.policy_sidecar_aps
        ;;
    "Sony")
        pm disable-user --user 0 com.sonymobile.customizationselector
        ;;
    "Motorola")
        pm disable-user --user 0 com.motorola.ccc.ota
        ;;
    "Asus")
        pm disable-user --user 0 com.asus.dm
        ;;
    "Nokia")
        pm disable-user --user 0 com.evenwell.partnerbrowsercustomizations
        ;;
    *)
        echo "Brand not recognized or no update app found.\n"
        ;;
esac
echo "Update app disabling completed.\n"
echo "On Phone Dialer digit *#*#983#*#* to enable EMode Keypad, then press any key to continue..."
read -n 1 -s
echo "On EMode Keypad digit *983*673636# to enable EMode, then press any key to continue..."
read -n 1 -s
echo "Unlocking the principal EMode activity with a workaround\n"
setprop persist.sys.snd.level.pwd 1
echo "Not really needed but let's unlock as well EMode entirely, in case this will also unlock other sprd based apps like YLog (com.sprd.logmanager), com.sprd.validationtools, com.sprd.camta, com.emode.cameratest (com.zte.burntest.camera), com.zte.flagreset, and more...\n"
setprop persist.sys.emode.enable 1
echo "Go to phone dialer and enter *#*#83781#*#*, then open ADB Shell activity manually from menu or alternatively use any launcher app as Root Activity Launcher or AM Debug, enter 'nc -s 127.0.0.1 -p 1234 -L sh -l' or 'toybox nc -s 127.0.0.1 -p 1234 -L sh -l' and press start (better copy the command out), then go back to the terminal and press any key to continue...\n"
read -n 1 -s
echo "exit adb/shizuku and on jackpal terminal, cd to the directory where this script is located and run 'cp -R UnisocEngsyshell ~ && cd ~ && chmod +x UnisocEngsyshell && clear && ./UnisocEngsyshell'\n"
echo "you can as well go on jackpal settings and set this as startup command 'cd ~ && clear && ./UnisocEngsyshell' to run the system shell when you open the app"
