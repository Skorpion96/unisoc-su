#!/system/bin/sh

# Get current user
USER=$(whoami)

# Check for supported users
if [ "$USER" != "system" ] && [ "$USER" != "shell" ] && [ "$USER" != "root" ]; then
  echo "Error: Unsupported user $USER"
  exit 1
fi

# Function to validate and assign a path
assign_path() {
  local variable_name="$1"
  local value="$2"
}

# Get tool paths
if [ "$USER" = "system" ]; then
SYS_TOOLS=$(find /data/app -type d \( -path "*/com.sammy.systools*/lib/arm64" -o -path "*/com.sammy.systools*/lib/arm" \) 2>/dev/null | head -n1)
fi
if [ "$USER" = "shell" ]; then
SHELL_TOOLS=$(pm path --user 0 com.sammy.systools | sed -E 's/^package:(.*)\/base\.apk$/\1/'); \
[ -d "$SHELL_TOOLS/lib/arm64" ] && SHELL_TOOLS="$SHELL_TOOLS/lib/arm64" || \
{ [ -d "$SHELL_TOOLS/lib/arm" ] && SHELL_TOOLS="$SHELL_TOOLS/lib/arm" || SHELL_TOOLS=""; }
fi

# Static root tools paths (not validated individually)
ROOT_TOOLS="/data/ylog:/data/anr:/data/tombstones:/data/local/traces:/data/corefile:/data/fonts:/data/user/0/com.unisoc.phone"

# Validate dynamic paths
if [ "$USER" = "system" ]; then
assign_path SYS_TOOLS "$SYS_TOOLS"
fi
if [ "$USER" = "shell" ]; then
assign_path SHELL_TOOLS "$SHELL_TOOLS"
fi

# Set common env
export TERMINFO=/sdcard/terminfo
export TERM=xterm-256color

# Build PATH
case "$USER" in
  system)
    if [ -n "$SYS_TOOLS" ]; then
      PATH="$SYS_TOOLS:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/data/com.sprd.engineermode:/data/data/android:$PATH"
    fi
    ;;
  shell)
    if [ -n "$SHELL_TOOLS" ]; then
      PATH="$SHELL_TOOLS:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/local/tmp:/data/local/tests:/data/local/traces:$PATH"
    fi
    ;;
  root)
    PATH="$ROOT_TOOLS:$PATH"
    ;;
esac

export PATH

