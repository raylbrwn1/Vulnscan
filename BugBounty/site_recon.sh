#!/bin/bash

source ./scopeconfig.sh  # Load DOMAIN and SCOPED_DOMAINS
OUT_DIR="/home/sandbender/BugBounty/Recon/Syfe"
mkdir -p "$OUT_DIR"

echo "[*] Starting Amass subdomain enumeration..."
amass enum -passive -d "$DOMAIN" -o "$OUT_DIR/amass_all.txt"

echo "[*] Filtering only in-scope domains..."
> "$OUT_DIR/scoped.txt"
for domain in "${SCOPED_DOMAINS[@]}"; do
  grep -i "$domain" "$OUT_DIR/amass_all.txt" >> "$OUT_DIR/scoped.txt"
done
sort -u "$OUT_DIR/scoped.txt" -o "$OUT_DIR/scoped.txt"

echo "[*] Probing which in-scope domains are live using httpx..."
httpx -l "$OUT_DIR/scoped.txt" -silent -status-code -title -o "$OUT_DIR/live_scoped.txt"

echo "[*] JS scraping from www.syfe.com..."
wget -r -l2 -A "*.js" -P "$OUT_DIR/js" https://www.syfe.com 2>/dev/null

echo "[✓] Recon complete."
