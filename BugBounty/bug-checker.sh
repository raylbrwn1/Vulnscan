#!/bin/bash

# ============================
# Bug Checker: JS + APK Discovery
# ============================

source "$(dirname "$0")/functions.sh"

TOOLS_DIR="$HOME/tools"
LINKFINDER="$TOOLS_DIR/LinkFinder/linkfinder.py"

JS_RESULTS="$OUT_DIR/results/js_links.txt"
APK_RESULTS_URLS="$OUT_DIR/results/apk_urls.txt"
APK_RESULTS_SECRETS="$OUT_DIR/results/apk_secrets.txt"
mkdir -p "$(dirname "$JS_RESULTS")"

log "Running LinkFinder on downloaded JS..."
for jsfile in $(find "$OUT_DIR/js" -type f -name "*.js"); do
  python3 "$LINKFINDER" -i "$jsfile" -o cli >> "$JS_RESULTS"
done
save_output "JS LinkFinder Results" "$JS_RESULTS"

log "Extracting URLs and secrets from APK (if exists)..."
if [ -d "$OUT_DIR/apks/decompiled" ]; then
  grep -Eorh "https?://[a-zA-Z0-9./?=_-]*" "$OUT_DIR/apks/decompiled" | sort -u > "$APK_RESULTS_URLS"
  grep -Eorih "api[_-]?key|token|auth|secret" "$OUT_DIR/apks/decompiled" | sort -u > "$APK_RESULTS_SECRETS"
  save_output "APK URLs" "$APK_RESULTS_URLS"
  save_output "APK Secrets" "$APK_RESULTS_SECRETS"
else
  log "[!] APK decompiled folder not found. Skipping APK scanning."
fi

log "Preparing target list for Burp..."
cut -d ' ' -f1 "$OUT_DIR/live_scoped.txt" > "$OUT_DIR/results/burp_scope.txt"
save_output "Burp Scope Targets" "$OUT_DIR/results/burp_scope.txt"

log "[✓] Bug checker script complete."
