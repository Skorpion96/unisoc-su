#!/system/bin/env sh

BR_IN="/sdcard/rootbridge/in/command.txt"
BR_OUT="/sdcard/rootbridge/out/result.txt"

usage() {
  cat <<EOF >&2
Usage: ghostsu -c <command>
Example: ghostsu -c "id; ls /data/ylog"
EOF
  exit 1
}

if [ "$1" = "-c" ]; then
  shift
  [ $# -gt 0 ] || usage
  CMD="$*"
else
  usage
fi

printf '%s\n' "$CMD" >"$BR_IN"

sleep 0.2

cat "$BR_OUT"
