#!/system/bin/sh

# Get current user
USER=$(whoami)

# Check for supported users
if [ "$USER" != "system" ] && [ "$USER" != "shell" ] && [ "$USER" != "root" ]; then
  echo "Error: Unsupported user $USER"
  return 0
fi

SYS_TOOLS_SET=$(echo $SYS_TOOLS)
SHELL_TOOLS_SET=$(echo $SHELL_TOOLS)
ROOT_TOOLS_SET=$(echo $ROOT_TOOLS)

if [ -n "$SYS_TOOLS_SET" ]; then
echo "You already ran this script for system"
return 0
fi
if [ -n "$SHELL_TOOLS_SET" ]; then
echo "You already ran this script for shell"
return 0
fi
if [ -n "$ROOT_TOOLS_SET" ]; then
echo "You already ran this script for root"
return 0
fi

ARCH=$(getprop ro.product.cpu.abi)
if [ "$ARCH" = "arm64-v8a" ]; then
ARM_DIR=arm64
else
ARM_DIR=arm
fi

# Function to validate and assign a path
assign_path() {
  local variable_name="$1"
  local value="$2"
}

# Get tool paths
if [ "$USER" = "system" ]; then
  # Try to find SYS_TOOLS with architecture-specific path first
  SYS_TOOLS=$(find /data/app -type d \( -path "*/com.sammy.systools*/lib/$ARM_DIR" \) 2>/dev/null | head -n1)
  
  # If not found, try fallback search for old Android versions (both arm64 and arm)
  if [ -z "$SYS_TOOLS" ]; then
    for d in /data/app/com.sammy.systools*/lib/$ARM_DIR /data/app/*/com.sammy.systools*/lib/$ARM_DIR; do
      if [ -d "$d" ]; then
        SYS_TOOLS="$d"
        break
      fi
    done
  fi
  
  # Additional fallback for old Android versions - try both architectures
  if [ -z "$SYS_TOOLS" ]; then
    SYS_TOOLS=$(find /data/app -type d \( -path "*/com.sammy.systools*/lib/arm64" -o -path "*/com.sammy.systools*/lib/arm" \) 2>/dev/null | head -n1)
  fi
  
  # Final check - error if still not found
  if [ -z "$SYS_TOOLS" ]; then
    echo "Error: com.sammy.systools library path not found, install the app before running this script. If you didn't understand how the exploit works run one of the tutorial scripts or read the README.md/watch the video tutorials carefully."
    return 0
  fi
fi

if [ "$USER" = "shell" ]; then
  SHELL_TOOLS=$(pm path --user 0 com.sammy.systools | sed -E 's/^package:(.*)\/base\.apk$/\1/')
  # Check for architecture-specific path first, then fallback to both architectures
  [ -d "$SHELL_TOOLS/lib/$ARM_DIR" ] && SHELL_TOOLS="$SHELL_TOOLS/lib/$ARM_DIR" || \
  { [ -d "$SHELL_TOOLS/lib/arm64" ] && SHELL_TOOLS="$SHELL_TOOLS/lib/arm64" || \
  { [ -d "$SHELL_TOOLS/lib/arm" ] && SHELL_TOOLS="$SHELL_TOOLS/lib/arm" || SHELL_TOOLS=""; } }
fi

SPRD_PATH="/data/data/com.sprd.engineermode:/data/data/android:/data/resource-cache:/data/user/0/com.unisoc.enginecore:/data/user/0/com.sprd.camta:/data/user/0/com.android.localtransport:/data/user/0/com.android.subsys:/data/data/com.android.wallpaperbackup:/data/data/com.android.providers.settings:/data/data/com.sprd.srmi:/data/data/com.android.inputdevices:/data/data/com.android.dynsystem:/data/data/com.android.location.fused:/data/data/com.android.settings:/data/data/com.android.server.telecom:/data/ylog:/data/ylog/ap:/data/ylog/ap/settings:/data/data/com.android.keychain:/data/user/0/com.android.keychain/databases:/data/data/com.unisoc.networksliceserver:/data/data/com.unisoc.networksliceserver/cache/oat_primary/$ARM_DIR:/data/data/com.sprd.validationtools:/data/data/com.sprd.validationtools/cache/oat_primary/$ARM_DIR:/apex/com.android.adbd/bin:/proc/mdbg:/data/misc/ethernet:/data/vendor"

BRAND=$(getprop ro.product.brand)

# Static root tools paths (not validated individually)
ROOT_TOOLS="/data/ylog:/data/anr:/data/tombstones:/data/local/traces:/data/corefile:/data/fonts:/data/system:/data/system_ce:/data/system_de:/data/vendor:/data/vendor/tombstones"

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

# Build PATH based on user
case "$USER" in
  system)
    if [ -n "$SYS_TOOLS" ]; then
      if [ "$BRAND" = "ZTE" ]; then
        PATH="$SYS_TOOLS:$SPRD_PATH:/data/data/com.zte.burntest.camera:/data/data/com.zte.easymode:/data/data/com.zte.zdm.omacp:/data/data/zte.com.cn.alarmclock:/data/data/androidzte:/data/data/zpub.res:/data/data/com.zte.emode:/data/data/com.zte.emode/cache/oat_primary/$ARM_DIR:/data/data/com.zte.aiengine:/data/data/com.zte.aiengine/cache/oat_primary/$ARM_DIR:/data/data/com.zte.appsimcardfilter:/data/data/com.zte.appsimcardfilter/cache/oat_primary/$ARM_DIR:/data/data/com.zte.zbackup.platservice:/data/data/com.zte.zbackup.platservice/cache/oat_primary/$ARM_DIR:/data/data/com.zte.powersavemode:/data/data/com.zte.powersavemode/cache/oat_primary/$ARM_DIR:/data/data/com.zte.zgesture:/data/data/com.zte.zgesture/cache/oat_primary/$ARM_DIR:/data/data/com.zte.mifavor.launcher.adapter:/data/data/com.zte.mifavor.launcher.adapter/cache/oat_primary/$ARM_DIR:/data/data/com.zte.linkspeedup:/data/data/com.zte.linkspeedup/cache/oat_primary/$ARM_DIR:/data/data/com.android.ztescreenshot:/data/data/com.android.ztescreenshot/cache/oat_primary/$ARM_DIR:/data/data/com.zte.zdmdaemon:/data/data/com.zte.zdmdaemon/cache/oat_primary/$ARM_DIR:$PATH"
      else
        PATH="$SYS_TOOLS:$SPRD_PATH:$PATH"
      fi
      HOME=/data/data/com.sprd.engineermode
    fi
    ;;
  shell)
    if [ -n "$SHELL_TOOLS" ]; then
      PATH="$SHELL_TOOLS:/data/local/tmp:/data/local/tests:/data/local/traces:$PATH"
      HOME=/data/local/tmp
    fi
    ;;
  root)
    PATH="$ROOT_TOOLS:$PATH"
    HOME=/
    ;;
esac

export PATH
