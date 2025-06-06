#!/system/bin/sh

# Get current user
USER=$(whoami)

# Check for supported users
if [ "$USER" != "system" ] && [ "$USER" != "shell" ]; then
  echo "Error: Unsupported user $USER"
  exit 1
fi

# Function to validate and assign a path
assign_path() {
  local variable_name="$1"
  local value="$2"

  if [ -z "$value" ]; then
    echo "[-] Warning: Path variable $variable_name is empty. Check your environment."
  elif [ ! -d "$value" ]; then
    echo "[-] Warning: Path $value for $variable_name not found. Path might be invalid."
  else
    echo "[+] Validated path for $variable_name: $value"
    eval "$variable_name=\"$value\""
  fi
}

# Determine paths for system tools and shell tools
SYS_TOOLS=$(find /data/app -type d -path "*/com.sammy.systools*/lib/arm" 2>/dev/null | head -n1)
SHELL_TOOLS=$(pm path --user 0 com.sammy.systools | sed -E 's/^package:(.*)\/base\.apk$/\1\/lib\/arm/')

# Validate and assign paths
assign_path SYS_TOOLS "$SYS_TOOLS"
assign_path SHELL_TOOLS "$SHELL_TOOLS"

# If paths are still empty, provide fallback or exit
if [ -z "$SYS_TOOLS" ] && [ -z "$SHELL_TOOLS" ]; then
  echo "[-] Error: Both SYS_TOOLS and SHELL_TOOLS paths could not be determined. Exiting."
  exit 1
fi

# Set common environment variables
export TERMINFO=/sdcard/terminfo
export TERM=xterm-256color

# Set PATH based on the user
if [ "$USER" = "system" ]; then
  if [ -n "$SYS_TOOLS" ]; then
    PATH="$SYS_TOOLS:/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/lib:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/data/com.sprd.engineermode:/data/data/android:$PATH"
    echo "[+] Found lib path: $SYS_TOOLS"
  else
    echo "[-] Warning: SYS_TOOLS path is missing for 'system' user."
  fi
elif [ "$USER" = "shell" ]; then
  if [ -n "$SHELL_TOOLS" ]; then
    PATH="$SHELL_TOOLS:/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/lib:/product/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin:/system_ext/bin:/system/bin:/system/xbin:/odm/bin:/vendor/bin:/vendor/xbin:/data/data/com.sprd.engineermode:/data/data/android:$PATH"
    echo "[+] Found lib path: $SHELL_TOOLS"
  else
    echo "[-] Warning: SHELL_TOOLS path is missing for 'shell' user."
  fi
fi

# Export the PATH
export PATH
