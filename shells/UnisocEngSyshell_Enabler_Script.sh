#!/bin/sh
echo "Welcome to the Unisoc Eng App System Shell Enabler Script\n"
if [ "$(whoami)" != "shell" ]; then
    echo "This script must be run as the Shell user (UID 2000)."
    exit 1
fi
echo "Running as Shell user!\n"
BRAND=$(getprop ro.product.brand)
DIS="pm disable-user --user 0"
echo "Disabling $BRAND Update APP to not allow $BRAND-kun or Unisoc Kill the Exploit in the future"
echo "Detected brand: $BRAND"
# Define update apps for different brands and try to disable them (in some cases the app is protected so disable will fail)
case "$BRAND" in
    "ZTE" | "Nubia")
        $DIS com.zte.zdm 2>&1 || echo "com.zte.zdm disable failed"
        ;;
    "Huawei" | "Honor")
        $DIS com.huawei.android.hwouc 2>&1 || echo "com.huawei.android.hwouc disable failed"
        $DIS com.hihonor.ouc 2>&1 || echo "com.hihonor.ouc disable failed"
        ;;
    "Samsung")
        $DIS com.wssyncmldm 2>&1 || echo "com.wssyncmldm disable failed"
        ;;
    "Xiaomi" | "POCO" | "Redmi")
        $DIS com.android.updater 2>&1 || echo "com.android.updater disable failed"
        ;;
    "OnePlus")
        $DIS com.oplus.ota 2>&1 || echo "com.oplus.ota disable failed"
        $DIS com.oneplus.opbackup 2>&1 || echo "com.oneplus.opbackup disable failed"
        ;;
    "Oppo")
        $DIS com.oppo.ota 2>&1 || echo "com.oppo.ota disable failed"
        ;;
    "Realme")
        $DIS com.coloros.ota 2>&1 || echo "com.coloros.ota disable failed"
        ;;
    "Vivo" | "iQOO")
        $DIS com.bbk.updater 2>&1 || echo "com.bbk.updater disable failed"
        ;;
    "Google")
        $DIS com.google.android.systemupdater 2>&1 || echo "com.google.android.systemupdater disable failed"
        ;;
    "Sony")
        $DIS com.sonyericsson.updatecenter 2>&1 || echo "com.sonyericsson.updatecenter disable failed"
        ;;
    "Motorola" | "Lenovo")
        $DIS com.motorola.ccc.ota 2>&1 || echo "com.motorola.ccc.ota disable failed"
        $DIS com.lenovo.lsf.ota 2>&1 || echo "com.lenovo.lsf.ota disable failed"
        ;;
    "Asus")
        $DIS com.asus.fota 2>&1 || echo "com.asus.fota disable failed"
        ;;
    "Nokia")
        $DIS com.evenwell.OTAUpdate 2>&1 || echo "com.evenwell.OTAUpdate disable failed"
        $DIS com.hmdglobal.app.customizationclient.OTAApplication 2>&1 || echo "com.hmdglobal.app.customizationclient.OTAApplication disable failed"
        ;;
    "Doogee")
        $DIS com.doogee.ota 2>&1 || echo "com.doogee.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Blackview" | "Blackview Pro")
        $DIS com.blackview.ota 2>&1 || echo "com.blackview.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Ulefone")
        $DIS com.ulefone.ota 2>&1 || echo "com.ulefone.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Oukitel")
        $DIS com.oukitel.ota 2>&1 || echo "com.oukitel.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Umidigi" | "UMIDIGI")
        $DIS com.umidigi.ota 2>&1 || echo "com.umidigi.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Cubot")
        $DIS com.cubot.ota 2>&1 || echo "com.cubot.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Itel" | "Spice")
        $DIS com.itel.ota 2>&1 || echo "com.itel.ota disable failed"
        $DIS com.transsion.ota 2>&1 || echo "com.transsion.ota disable failed"
        $DIS com.sprd.ota 2>&1 || echo "com.sprd.ota disable failed"
        ;;
    "Tecno" | "TECNO")
        $DIS com.tecno.ota 2>&1 || echo "com.tecno.ota disable failed"
        $DIS com.transsion.ota 2>&1 || echo "com.transsion.ota disable failed"
        ;;
    "Infinix")
        $DIS com.infinix.ota 2>&1 || echo "com.infinix.ota disable failed"
        $DIS com.transsion.ota 2>&1 || echo "com.transsion.ota disable failed"
        ;;
    "Wiko")
        $DIS com.wiko.ota 2>&1 || echo "com.wiko.ota disable failed"
        $DIS com.mediatek.fota 2>&1 || echo "com.mediatek.fota disable failed"
        ;;
    "Alcatel" | "TCL")
        $DIS com.tcl.ota 2>&1 || echo "com.tcl.ota disable failed"
        $DIS com.alcatel.otaupgrade 2>&1 || echo "com.alcatel.otaupgrade disable failed"
        ;;
    "Micromax")
        $DIS com.micromax.ota 2>&1 || echo "com.micromax.ota disable failed"
        ;;
    "Lava")
        $DIS com.lava.ota 2>&1 || echo "com.lava.ota disable failed"
        ;;
    *)
        echo "Brand not recognized or no update app found.\n"
        ;;
esac
echo "Update app disabling completed (is recommended an OTA presence check just in case in settings, normally it's entry disappears when the app is disabled).\n"
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
