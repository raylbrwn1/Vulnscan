#!/bin/bash

# ============================
# APK Pull + Decompile Script
# ============================

source "$(dirname "$0")/functions.sh"

APK_URL="https://apkcombo.com/syfe/com.syfe/download/apk"
APK_NAME="Syfe.apk"

APK_DIR="$OUT_DIR/apks"
DECOMPILED_DIR="$APK_DIR/decompiled"
mkdir -p "$APK_DIR" "$DECOMPILED_DIR"

log "Downloading Syfe APK..."
wget -O "$APK_DIR/$APK_NAME" "$APK_URL"

if [[ ! -f "$APK_DIR/$APK_NAME" ]]; then
  log "[-] APK download failed."
  exit 1
fi

log "Decompiling APK with JADX..."
jadx -d "$DECOMPILED_DIR" "$APK_DIR/$APK_NAME" > /dev/null

URL_OUTPUT="$OUT_DIR/results/apk_urls.txt"
KEY_OUTPUT="$OUT_DIR/results/apk_secrets.txt"
mkdir -p "$(dirname "$URL_OUTPUT")"

log "Extracting URLs from APK..."
grep -Eorh "https?://[a-zA-Z0-9./?=_-]*" "$DECOMPILED_DIR" | sort -u > "$URL_OUTPUT"

log "Extracting possible secrets from APK..."
grep -Eorih "api[_-]?key|token|auth|secret" "$DECOMPILED_DIR" | sort -u > "$KEY_OUTPUT"

save_output "APK Decompiled Directory" "$DECOMPILED_DIR"
save_output "APK URLs" "$URL_OUTPUT"
save_output "APK Secrets" "$KEY_OUTPUT"

log "[✓] APK analysis complete."
