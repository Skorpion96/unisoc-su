# unisoc-su
A method for [CVE-2025-31710](https://nvd.nist.gov/vuln/detail/CVE-2025-31710) and to connect to cmd_skt abstract socket to obtain a root shell on unisoc unpatched models

Before everyone screams, Unisoc itself authorized me to publish this after [CVE-2025-31710](https://nvd.nist.gov/vuln/detail/CVE-2025-31710) bullettin, so stay quiet.

Let's start with a joke

![9u4d2i](https://github.com/user-attachments/assets/2efc4cec-be56-4666-95b4-b0a4e354aa9a)


Yes, you are not dreaming, today i want to present you an exploit for a system shell on com.sprd.engineermode app and since it is one of the trusted clients of cmd_skt i was also able to enter it as well. This socket is part of a service running as root (cmd_services), so yes, i’m glad to present you unisoc-su. Here you can see a list of the trusted clients of cmd_skt extracted from cmd_services binary with ghidra which shows com.sprd.engineermode is present:


![cmd_services apps](https://github.com/user-attachments/assets/b42ece1e-3f7a-460f-b871-3859fa9a579c)

This cmd_skt, which is an abstract socket, was already entered in 2022:[CVE-2022-47339](https://nvd.nist.gov/vuln/detail/cve-2022-47339), because of this now it exits if nothing connects almost immediately, you will have to be fast enough to not make the connection drop. For this exploit it's used com.sammy.systools app by [pascua28](https://github.com/pascua28) and [cli-pie](https://github.com/TomKing062/cmd_services_client/releases) by [TomKing062](https://github.com/TomKing062), there is another placer app which is still the com.sammy.systools app but without all the binaries except the [cli-pie](https://github.com/TomKing062/cmd_services_client/releases) and some clis to connect to other various sockets (for engpc you can now source [this](https://github.com/user-attachments/files/25319358/engpcctl_cli.sh) from system shell, i suggest to source first the tools.sh), if you don't want the full app use this one, both should work on arm and arm64, i had modded this second app later so it looks different but it's still the com.sammy.systools app, as well now as an android 9 version of the app for lower android devices with the same binaries as this second placer app.

How this method works: you first execute as adb or shizuku rish the UnisocEngSyshell_Enabler_Script.sh to enable com.sprd.engineermode app (only needed on new models), then following the instructions run on dialer `*#*#83781#*#*` to run main activity, then from here enter the Adb shell activity. Then enter on one line the full [cli-pie](https://github.com/TomKing062/cmd_services_client/releases) PATH (including the applet), on the other "setprop persist.sys.cmdservice.enable enable", then press start as fast as possible on setprop first and then on the [cli-pie](https://github.com/TomKing062/cmd_services_client/releases) line, and boom it will show connected. Then press end on the setprop activity and delete it's text, input "nc -s 127.0.0.1 -p 1234 -L sh -l" or what you use to run the reverse shell. Then go to the terminal and connect back with the according binary, if it doesn't run source the according script or simply connect with "nc 127.0.0.1 1234", after that "source /sdcard/Documents/unisoc-su.sh" (or where you placed the script, but it must be accessible from the system shell). That's it, you just got a root shell if everything is correct.

Now, let's talk about about this exploit, the context is heavily guarded by selinux, we have root but every protection is still up. This root is huge because we didn't disable anything to get it like other similar exploits. Unfortunately this context doesn't have enough power to disable selinux and also execution seems to work only on system PATH. About the service itself, seems on eng doesn't have groups (at least on android 9) and so gid defaults to root, on user builds instead gid is system, so it's more restricted, but with selinux up it's this one which rules anyway.

![cmd_services_android13 (user) rc](https://github.com/user-attachments/assets/4018e40e-4a27-47c8-b764-51072119971a)
![cmd_services_android9 (eng) rc](https://github.com/user-attachments/assets/0ce7097a-3e45-412a-81a9-5412e2b6ea49)

CVEs that inspired this method: [CVE-2022-47339](https://nvd.nist.gov/vuln/detail/cve-2022-47339) (cmd_services), [CVE-2025-31710](https://nvd.nist.gov/vuln/detail/CVE-2025-31710) (com.sprd.engineermode system shell)

Also a special case which came later, this isn't part of the inspirational CVEs list, it's a reintroduced vulnerability, I'll add it here to make things cleaner: [CVE-2025-67264](https://www.cve.org/CVERecord?id=CVE-2025-67264) (Doogee com.sprd.engineermode bad patch on new unisoc models, covered [here](https://github.com/Skorpion96/unisoc-su/blob/main/CVE-2025-67264.md))

Here are provided various scripts for unisoc-su, one without tutorial: unisoc-su.sh, one that guides to enter the root shell with system shell only (this method is easier, works offline and without shizuku/adb): unisoc-su-syshell-only-tut.sh, one that guides to enter the root shell using shizuku/adb, only used to run the setprop part: unisoc-su-adb-shizuku-tut.sh, also a version to connect to various sockets, source the one you like from your terminal, only unisoc-su.sh and this last one requires to be sourced from the system shell. It's also available a tools.sh script into the ghostroot folder to add various directories to PATH which is compatible with adb/system and root, also a multi script to run the system shell if you don't know what nc you have on your system which will try to nc from various possible binaries until the connection is successful.

About GhostRoot (Post-Exploit Root Channel)
A stealthy post-exploit command channel that survives in RAM and accepts input from any unprivileged app via file-based I/O.

The exploit works up to Android 13 as on later versions unisoc removed the sharedUserId tag from the EngineerMode app and so now it's a normal user app, this makes selinux deny execution of the [cli-pie](https://github.com/TomKing062/cmd_services_client/releases) on android 14 and up.

![SharedUid-NormalUid_Compare-Patch](https://github.com/user-attachments/assets/fb757f06-e94a-4a78-8d64-434077a706cf)
Image Provided by [TomKing062](https://github.com/TomKing062)

This unless your device has EngineerMode into vendor and it wasn't updated with the system partition, i just found this situation on a ZTE Blade A55:
[ZTE_Blade_A55_system_ext_build.txt](https://github.com/user-attachments/files/21763984/ZTE_Blade_A55_system_ext_build.txt) [ZTE_Blade_A55_vendor_build.txt](https://github.com/user-attachments/files/21763989/ZTE_Blade_A55_vendor_build.txt) If it didn't you should have unpatched engineermode and tool_service instead of cmd_services. Note, tool_service doesn't need any setprop and should be always active. [tool_service.rc.txt](https://github.com/user-attachments/files/21764386/tool_service.rc.txt)

A screenshot of both the system and the root shell

![r00t_script6_new_version](https://github.com/user-attachments/assets/6e68555f-b3f7-45ea-a146-d357049403ab)

Here Video Tutorials to enter the cmd_services root shell

https://github.com/user-attachments/assets/225165d9-fd8b-4558-849a-7b00895ce894

https://github.com/user-attachments/assets/953ed696-f3a1-4556-8756-07bbe555b3ae

Please do not repost this elsewhere if possible.

The app icon icon was grabbed here:[icon-link], and here is the license:[license-link]

[icon-link]:https://www.awicons.com/free-icons/object-icons/activity-monitor-icons-by-gordon-irving/matrix-icon/
[license-link]:https://creativecommons.org/licenses/by-nc-nd/3.0/
