# unisoc-su
A method for CVE-2025-31710 and to connect to cmd_skt abstract socket to obtain a root shell on unisoc unpatched devices

Before everyone screams, Unisoc itself authorized me to publish this after CVE-2025-31710 bullettin, so stay quiet.

Let's start with a joke

![9u4d2i](https://github.com/user-attachments/assets/2efc4cec-be56-4666-95b4-b0a4e354aa9a)


Yes, you are not dreaming. Today i want to present you an exploit for a system shell on com.sprd.engineermode app and since it is one of trusted clients of cmd_skt i was also able to enter it as well. This socket runs a service as root (cmd_services). So yes, i’m glad to present you unisoc-su. Here a list of the trusted clients extracted from cmd_services binary with ghidra:


![cmd_services apps](https://github.com/user-attachments/assets/b42ece1e-3f7a-460f-b871-3859fa9a579c)

This cmd_skt, which is an abstract socket, was already entered in 2022:https://nvd.nist.gov/vuln/detail/cve-2022-47339, because of this now it exits if nothing connects almost immediately, that's the reason of this method. On this method it's used com.sammy.systools app by https://github.com/pascua28 and cli-pie here https://github.com/TomKing062/cmd_services_client/releases by https://github.com/TomKing062 (there is another placer app which is still the sammy.systools app but without all the binaries except the cli-pie and has as well the 32 bit version of cli-pie so if you are on 32 bit use that, i had modded it later so it looks different but it's still sammy.systools app).

How this method works. You first execute as adb or shizuku rish UnisocEngSyshell_Enabler_Script.sh to enable com.sprd.engineermode app (only needed on new models), then following the script run on dialer *#*#83781#*#* to run main activity, then from here enter adb shell activity. Then enter on one line the full cli-pie PATH (including the applet), on the other "setprop persist.sys.cmdservice.enable enable", then press start as fast as possible on setprop first and then on the cli-pie line, and boom it will show connected. Then press end on the setprop activity and delete it's text, input "nc -s 127.0.0.1 -p 1234 -L sh -l" or what you use to run the reverse shell. Then go to the terminal and connect back with the according binary or simply with "nc localhost 1234", after that "source /sdcard/Documents/unisoc-su.sh" (or where you placed the binary, but it must be accessible from the system shell). That's it, you just got a root shell if everything is correct.

Now, let's talk about about this exploit, the context is heavily guarded by selinux, we have root but every protection is still up. This root is huge because we didn't disable anything but we have to find a place where we can execute, unfortunately this context isn't probably able to disable selinux but after getting our binaries execution we could try something. The cmd_services sepolicy isn't this good honestly in my opinion but there is hope. About the service itself, seems on eng doesn't have groups (at least on android 9) and so gid defaults to root, on user builds instead gid is system, so it's more restricted, but with selinux up it's this one which rules anyway.

![cmd_services_android13 (user) rc](https://github.com/user-attachments/assets/4018e40e-4a27-47c8-b764-51072119971a)
![cmd_services_android9 (eng) rc](https://github.com/user-attachments/assets/0ce7097a-3e45-412a-81a9-5412e2b6ea49)

CVEs that inspired this method: CVE-2022-47339 (cmd_services), CVE-2025-31710 (engineermode system shell)

Here are provided three scripts for unisoc-su, one without tutorial: unisoc-su.sh, one that guides to enter the root shell with system shell only (this method is easier, works offline and without shizuku/adb): unisoc-su-syshell-only-tut.sh, the last one guides to enter the root shell using shizuku/adb, only used to run the setprop part: unisoc-su-adb-shizuku-tut.sh, source the one you like from the system shell, the blank one requires you to do everything manually, for 32 bit phones use unisoc-su-armv7l.sh (manual setup).

The exploit works up to Android 13 as on later versions unisoc removed the sharedUserId tag from the EngineerMode app and so now it's a normal user app, this makes selinux deny execution of the cli-pie on android 14 and on Android 15.

![SharedUid-NormalUid_Compare-Patch](https://github.com/user-attachments/assets/fb757f06-e94a-4a78-8d64-434077a706cf)
Image Provided by TomKing062

Here Video Tutorials to enter the cmd_services root shell

https://github.com/user-attachments/assets/225165d9-fd8b-4558-849a-7b00895ce894

https://github.com/user-attachments/assets/953ed696-f3a1-4556-8756-07bbe555b3ae

Please do not repost this elsewhere if possible.

