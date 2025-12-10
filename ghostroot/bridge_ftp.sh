#!/bin/sh

HOST="127.0.0.1"
PORT="1234"
EMODEDIR="/sdcard/Android/media/com.sprd.engineermode"
INFILE="$EMODEDIR/rootbridge/in/command.txt"
INDIR="$EMODEDIR/rootbridge/in"
OUTDIR="$EMODEDIR/rootbridge/out"
OUTFILE="$OUTDIR/result.txt"
NC="/system/bin/toybox nc"
SLEEP_INTERVAL=0.5
if echo | $NC "$HOST" "$PORT" >/dev/null 2>&1; then
    echo "Welcome to the Unisoc Eng Mode App Reverse Shell"
    echo "Waiting for remote FTP Commands"
fi
if [ -s "$EMODEDIR" ]; then
rm -r $EMODEDIR && mkdir $EMODEDIR
else mkdir $EMODEDIR
fi
mkdir -p "$INDIR" "$OUTDIR"
is_dangerous_content() {
    echo "$cmd_text" | grep -qE 'eval'
}
while true; do
    if [ -s "$INFILE" ]; then
        cmd_text="$(cat "$INFILE")"
        echo "[bridge executing] $cmd_text"
        if is_dangerous_content "$cmd_text"; then
            printf 'We do not allow eval/command-substitution or dangerous tokens in command.txt\n' > "$OUTFILE"
        return 0
        else
            printf '%s\n' "$cmd_text" | $NC "$HOST" "$PORT" > "$OUTFILE" 2>&1 || {
                printf 'Error: network/send failed (nc exit code: %s)\n' "$?" >> "$OUTFILE"
            }
        fi
        rm -f "$INFILE"
    fi
    sleep "$SLEEP_INTERVAL"
done
