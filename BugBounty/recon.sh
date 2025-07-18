#!/bin/bash

# =========================
# Syfe Bug Bounty Recon Script
# =========================
# Tools needed: amass, httpx, wget, linkfinder (optional)
# Ensure you run: chmod +x syfe_recon.sh
#!/bin/bash

source /home/sandbender/bugbounty/scripts/scopeconfig.sh  # Import DOMAIN and SCOPED_DOMAINS

OUT_DIR="/home/sandbender/bugbounty"

mkdir -p "$OUT_DIR"

echo "[*] Starting Amass subdomain enumeration (passive)..."
amass enum -passive -d $DOMAIN -o "$OUT_DIR/amass_all.txt"

echo "[*] Filtering only in-scope domains..."
touch "$OUT_DIR/scoped.txt"
for domain in "${SCOPED_DOMAINS[@]}"; do
  grep -i "$domain" "$OUT_DIR/amass_all.txt" >> "$OUT_DIR/scoped.txt"
done
sort -u "$OUT_DIR/scoped.txt" -o "$OUT_DIR/scoped.txt"

echo "[*] Probing which in-scope domains are live using httpx..."
httpx -l "$OUT_DIR/scoped.txt" -silent -status-code -title -o "$OUT_DIR/live_scoped.txt"

echo "[*] Live in-scope domains:"
cat "$OUT_DIR/live_scoped.txt"

# Optional JS download (can lead to hidden endpoints)
echo "[*] Checking for JS files to download from target site..."
wget -r -l2 -A "*.js" -P "$OUT_DIR/js" https://www.syfe.com 2>/dev/null

echo "[*] JavaScript files downloaded to: $OUT_DIR/js"

echo "[✓] Recon complete. Next step: analyze JS, scan live domains with Burp or ffuf."
