GhostRoot PoC: Post-Exploit Root Channel via Internal Storage txt read/write

Summary

This PoC demonstrates a memory-resident root channel using only shell scripts and Internal Storage text files.

- No app required
- No socket
- No netcat
(these first 3 after running unisoc-su of course are not needed but before yes)
- No system binaries beyond toybox/sh
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

This PoC demonstrates a stealth post-exploit control channel that remains viable only if the root process (spawned via a previously available exploit like unisoc-su) is still running in memory.

The exploited process is still alive in RAM

No cleanup mechanism terminates it

The root process doesn't see any client conected or command sent, the same is almost valid for selinux which will only show some denials for the untrusted_app

Untrusted apps can silently inject commands into this process using normal file I/O

WARNING

Educational use only. Do not run this on devices you do not own.

