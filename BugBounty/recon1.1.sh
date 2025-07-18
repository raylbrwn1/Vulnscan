#!/bin/bash

# =========================
# Syfe Full Recon & APK Analysis Script
# =========================
# Requires: amass, httpx, ffuf, wget, jadx, grep
# Make sure to: chmod +x syfe_full_recon.sh

read -p "Enter the primary root domain (e.g., syfe.com): " DOMAIN

read -p "Enter in-scope subdomains (comma-separated): " input
IFS=',' read -ra SCOPED_DOMAINS <<< "$input"

OUT_DIR="$HOME/bugbounty/recon"
FFUF_WORDLIST="/usr/share/wordlists/dirb/common.txt"
APK_URL="https://apkcombo.com/syfe/com.syfe/download/apk"
APK_NAME="Sdomain name here"

mkdir -p "$OUT_DIR" "$OUT_DIR/js" "$OUT_DIR/ffuf_results" "$OUT_DIR/apk"

echo "[*] Starting Amass subdomain enumeration..."
amass enum -passive -d "$DOMAIN" -o "$OUT_DIR/amass_all.txt"

echo "[*] Filtering only in-scope domains..."
> "$OUT_DIR/scoped.txt"
for domain in "${SCOPED_DOMAINS[@]}"; do
  grep -i "$domain" "$OUT_DIR/amass_all.txt" >> "$OUT_DIR/scoped.txt"
done
sort -u "$OUT_DIR/scoped.txt" -o "$OUT_DIR/scoped.txt"

echo "[*] Probing live scoped domains with httpx..."
httpx -l "$OUT_DIR/scoped.txt" -silent -status-code -title -o "$OUT_DIR/live_scoped.txt"

echo "[*] JS scraping from all scoped domains..."

for domain in "${SCOPED_DOMAINS[@]}"; do
  url="https://$domain"
  clean_name=$(echo "$domain" | sed 's|[./]|_|g')
  js_out="$OUT_DIR/js/$clean_name"
  mkdir -p "$js_out"
  echo "[*] Downloading JS from $url..."
  wget -r -l2 -np -nd -A "*.js" -P "$js_out" "$url" 2>/dev/null
done

echo "[*] Running ffuf scans on live domains..."
while read -r line; do
  domain=$(echo "$line" | awk '{print $1}')
  clean_name=$(echo "$domain" | sed 's|https\?://||;s|/||g')
  ffuf -u "$domain/FUZZ" -w "$FFUF_WORDLIST" -mc 200,301,302,403 -of md -o "$OUT_DIR/ffuf_results/$clean_name.txt"
done < "$OUT_DIR/live_scoped.txt"

echo "[*] Downloading and decompiling APK..."
wget -O "$OUT_DIR/apk/$APK_NAME" "$APK_URL"
jadx -d "$OUT_DIR/apk/jadx_output" "$OUT_DIR/apk/$APK_NAME"

echo "[*] Searching APK for secrets and URLs..."
grep -Eorh "https?://[a-zA-Z0-9./?=_-]*" "$OUT_DIR/apk/jadx_output" | sort -u > "$OUT_DIR/apk/urls.txt"
grep -Eorh "api[_-]?key|token|auth|secret" "$OUT_DIR/apk/jadx_output" | sort -u > "$OUT_DIR/apk/keys.txt"

echo "[✓] Full recon complete!"
echo "Results saved in: $OUT_DIR"

