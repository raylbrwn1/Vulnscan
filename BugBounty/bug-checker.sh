#!/bin/bash

# ==============
# Syfe Auto Recon & Analysis Script
# ==============

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BASE_DIR="$HOME/BugBounty/Runs/Syfe_$DATE"
TOOLS_DIR="$HOME/tools"
LINKFINDER="$TOOLS_DIR/LinkFinder/linkfinder.py"
FFUF_WORDLIST="/usr/share/wordlists/dirb/common.txt"
APK_URL="https://apkcombo.com/syfe/com.syfe/download/apk"
APK_NAME="Syfe.apk"

mkdir -p "$BASE_DIR"/{js,ffuf,apk,results}

read -p "[+] Root domain (e.g., syfe.com): " DOMAIN
read -p "[+] Comma-separated in-scope subdomains: " SUBS
IFS=',' read -ra SCOPED <<< "$SUBS"

echo "[*] Running Amass passive enum for $DOMAIN..."
amass enum -passive -d "$DOMAIN" -o "$BASE_DIR/amass.txt"

echo "[*] Filtering scoped subdomains..."
> "$BASE_DIR/scoped.txt"
for sub in "${SCOPED[@]}"; do
  grep -i "$sub" "$BASE_DIR/amass.txt" >> "$BASE_DIR/scoped.txt"
done
sort -u "$BASE_DIR/scoped.txt" -o "$BASE_DIR/scoped.txt"

echo "[*] Probing live domains with httpx..."
httpx -l "$BASE_DIR/scoped.txt" -silent -status-code -title -o "$BASE_DIR/live.txt"

echo "[*] Scraping JS from all live scoped domains..."
while read -r domain_line; do
  domain=$(echo "$domain_line" | awk '{print $1}')
  folder=$(echo "$domain" | sed 's|https\?://||;s|/||g' | tr '.' '_')
  mkdir -p "$BASE_DIR/js/$folder"
  wget -r -l2 -np -nd -A "*.js" -P "$BASE_DIR/js/$folder" "$domain" 2>/dev/null
done < "$BASE_DIR/live.txt"

echo "[*] Running LinkFinder on downloaded JS..."
for jsfile in $(find "$BASE_DIR/js" -type f -name "*.js"); do
  python3 "$LINKFINDER" -i "$jsfile" -o cli >> "$BASE_DIR/results/js_links.txt"
done

echo "[*] Starting ffuf scans..."
while read -r line; do
  url=$(echo "$line" | cut -d ' ' -f1)
  fname=$(echo "$url" | sed 's|https\?://||;s|/||g' | tr '.' '_')
  ffuf -u "$url/FUZZ" -w "$FFUF_WORDLIST" -mc 200,301,302,403 -o "$BASE_DIR/ffuf/$fname.json"
done < "$BASE_DIR/live.txt"

echo "[*] Downloading and decompiling APK..."
wget -O "$BASE_DIR/apk/$APK_NAME" "$APK_URL"
jadx -d "$BASE_DIR/apk/jadx" "$BASE_DIR/apk/$APK_NAME"

echo "[*] Extracting secrets and URLs from APK..."
grep -Eorh "https?://[a-zA-Z0-9./?=_-]*" "$BASE_DIR/apk/jadx" | sort -u > "$BASE_DIR/results/apk_urls.txt"
grep -Eorih "api[_-]?key|token|auth|secret" "$BASE_DIR/apk/jadx" | sort -u > "$BASE_DIR/results/apk_secrets.txt"

echo "[*] Preparing target list for Burp..."
cut -d ' ' -f1 "$BASE_DIR/live.txt" > "$BASE_DIR/results/burp_scope.txt"

read -p "[+] Launch Burp Suite now with these targets? (y/n): " burp
if [[ "$burp" =~ ^[Yy]$ ]]; then
  burpsuite &
fi

echo "[✓] Recon and analysis complete. Output stored in:"
echo "$BASE_DIR"
