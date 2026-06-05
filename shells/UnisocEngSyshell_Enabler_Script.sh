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
    "ZTE" | "Nubia")
        pm disable-user --user 0 com.zte.zdm 2>&1
        ;;
    "Huawei" | "Honor")
        pm disable-user --user 0 com.huawei.android.hwouc 2>&1
        pm disable-user --user 0 com.hihonor.ouc 2>&1
        ;;
    "Samsung")
        pm disable-user --user 0 com.wssyncmldm 2>&1
        ;;
    "Xiaomi")
    # This won't work but we will add it anyway (and Xiaomi doesn 't have Unisoc devices, it's just to have everything)
        pm disable-user --user 0 com.android.updater 2>&1
        ;;
    "OnePlus")
        pm disable-user --user 0 com.oplus.ota 2>&1
        pm disable-user --user 0 com.oneplus.opbackup 2>&1
        ;;
    "Oppo")
        pm disable-user --user 0 com.oppo.ota 2>&1
        ;;
    "Realme")
    pm disable-user --user 0 com.coloros.ota 2>&1
        ;;
    "Vivo")
    pm disable-user --user 0 com.bbk.updater 2>&1
        ;;
    "Google")
        pm disable-user --user 0 com.google.android.systemupdater 2>&1
        ;;
    "Sony")
        pm disable-user --user 0 com.sonyericsson.updatecenter 2>&1
        ;;
    "Motorola")
        pm disable-user --user 0 com.motorola.ccc.ota 2>&1
        ;;
    "Asus")
        pm disable-user --user 0 com.asus.fota 2>&1
        ;;
    "Nokia")
        pm disable-user --user 0 com.evenwell.OTAUpdate 2>&1
        pm disable-user --user 0 com.hmdglobal.app.customizationclient.OTAApplication 2>&1
        ;;
    *)
        echo "Brand not recognized or no update app found.\n"
        ;;
esac
echo "Update app disabling completed.\n"
echo "Unlocking the principal EMode activity with a workaround\n"
setprop persist.sys.snd.level.pwd 1
echo "Not really needed but let's unlock as well EMode entirely, in case this will also unlock other sprd based apps like YLog (com.sprd.logmanager), com.sprd.validationtools, com.sprd.camta, com.emode.cameratest (com.zte.burntest.camera), com.zte.flagreset, and more...\n"
setprop persist.sys.emode.enable 1
echo "On Phone Dialer digit *#*#983#*#* to open EMode Keypad, then press any key to continue..."
read -n 1 -s
echo "On EMode Keypad digit *983*673636# to enable EMode, then press any key to continue..."
read -n 1 -s
echo "Go to phone dialer and enter *#*#83781#*#*, then open ADB Shell activity manually from menu or alternatively use any launcher app as Root Activity Launcher or AM Debug, enter 'nc -s 127.0.0.1 -p 1234 -L sh -l' or 'toybox nc -s 127.0.0.1 -p 1234 -L sh -l' and press start (better copy the command out), then go back to the terminal and press any key to continue...\n"
read -n 1 -s
echo "exit adb/shizuku and on jackpal terminal, cd to the directory where this script is located and run 'cp -R UnisocEngsyshell.sh ~ && cd ~ && chmod +x UnisocEngsyshell.sh && clear && source UnisocEngsyshell.sh'\n"
echo "you can as well go on jackpal settings and set this as startup command 'cd ~ && clear && source UnisocEngsyshell.sh' to run the system shell when you open the app"
