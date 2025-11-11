GhostRoot PoC: Post-Exploit Root Channel via Internal Storage txt read/write

Summary

This PoC demonstrates a memory-resident root channel using only shell scripts and Internal Storage text files.

- No app required
- No socket
- No netcat
- No system binaries beyond toybox/sh

(these first 4 after running unisoc-su of course are not needed but before yes)
- SELinux logs almost nothing
- The root shell is invisible to untrusted_app context

How It Works

1. The root shell (spawned from `unisoc-su`) tails a file in `/sdcard/rootbridge/in/command.txt`
2. It writes output to `/sdcard/rootbridge/out/result.txt`
3. Any untrusted app can write to `command.txt` to execute commands with UID 0
4. Output is written back asynchronously to `result.txt`

Limitations

- Requires an authorized client shell already running to connect to the root client (e.g., via `cli-pie`)
- Only works until the shell dies or system reboots
- No automatic persistence — this is for research only

Why This Matters

This PoC demonstrates a stealth post-exploit control channel that remains listening for commands persistently (spawned via a previously available exploit like unisoc-su).

The exploited process is still alive in RAM

No cleanup mechanism terminates it

The root process doesn't see any client connected or command sent, the same is almost valid for selinux which will only show some denials for the untrusted_app or worse something unrelated or nothing at all

Untrusted apps can silently inject commands into this process using normal file I/O

Why This PoC Exists

This post-exploit root channel is not just a toy — it highlights real architectural flaws.

Stealth Root Access

The system does not register that an untrusted app is sending commands.
SELinux logs nothing meaningful. No client appears connected. No traces — yet full root execution occurs.

The System Shell Was Just the Entry Point

Even though the original system shell vulnerability (now patched) was the entry vector, the real issue is deeper:
The root process remains alive, unmonitored, and unprotected.
Unisoc patched the door but left the house open.

SELinux Fails to Understand the Channel

SELinux policies are unaware of the file-based IPC between the root client and the app, so no policy violation is raised, even as commands execute as UID 0.

If Accessed Again, It’s Weaponizable

If this root client is ever accessed again — by malware, a misused API, or another app — it becomes a fully functional, stealthy root shell. Think in-RAM RAT.

For Research and Awareness

This PoC shows how post-exploit persistence and stealth control channels can live entirely within existing userland and SEAndroid constraints.

WARNING

Educational use only. Do not run this on devices you do not own.

How-To

Source the rootbridge.sh from the root shell (i'd copy it first on a directory it can access as on /sdcard), then you can close the root shell terminal and the engineermode app, after that on any untrusted_app with a terminal run the ghostroot script.


![ghostroot_termux](https://github.com/user-attachments/assets/4b5988cb-c3b6-44dc-8f30-c2bed8d3a333)

Demonstration

https://github.com/user-attachments/assets/ce83fa97-01cc-40c4-9cb9-3837b7cb2c7f

Bonus: It's also possible to get RCE by this method: run the rootbridge from the engineermode reverse shell (with the root check removed) or the cmd_services root shell, then enable an ftp server on an app like MiXplorer, after that go on pc and run an app like FileZilla and input the phone ftp ip, user, password if present and port, after that create an empty text file named command.txt and insert the command/s you want to run, ex: id && pwd, then save it and copy it to /sdcard/rootbridge/in on FileZilla, then go to /sdcard/rootbridge/out and download the result.txt and check the output of the command/s, repeat the steps as you want. I added as well a script to be sourced from untrusted_app context called bridge_ftp.sh which uses /sdcard/Android/media/com.sprd.engineermode instead of /sdcard/rootbridge, you can use this for RCE and since uses /Android/media should be more stealth, this script obviously listens for commands from command.txt and sends them to result.txt, simple but effective.

I'm not responsible for misuse of this, this is only for research, and it's only a method, it's people who have the power to distinguish what is right or wrong, and in any case if you are worried you can just update or change device to a newer one.
