#!/usr/bin/env bash
set -e

# ── Java ──────────────────────────────────────────────────────────────────────
if ! java -version &>/dev/null; then
    echo "❌  Java not found. Install JDK 17."
    exit 1
fi
echo "✅  Java found ($(java -version 2>&1 | head -1))"

# ── ANDROID_HOME ──────────────────────────────────────────────────────────────
if [ -z "$ANDROID_HOME" ]; then
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    else
        echo "❌  ANDROID_HOME not set and ~/Android/Sdk not found."
        exit 1
    fi
fi
echo "✅  ANDROID_HOME = $ANDROID_HOME"

# ── gradle-wrapper.jar ────────────────────────────────────────────────────────
JAR="gradle/wrapper/gradle-wrapper.jar"
if [ ! -f "$JAR" ]; then
    echo "⬇️   Downloading gradle-wrapper.jar..."
    curl -fsSL -o "$JAR" \
        "https://github.com/gradle/gradle/raw/v8.4.0/gradle/wrapper/gradle-wrapper.jar"
fi
echo "✅  gradle-wrapper.jar present"

chmod +x gradlew

echo "🔨  Building debug APK..."
./gradlew assembleDebug

APK=$(find app/build/outputs/apk/debug -name "*.apk" | head -1)
if [ -n "$APK" ]; then
    echo ""
    echo "✅  Done: $APK"
else
    echo "❌  APK not found after build."
    exit 1
fi
