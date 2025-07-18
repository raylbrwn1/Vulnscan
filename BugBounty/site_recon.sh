#!/bin/bash

# ============================
# Subdomain Recon and JS Fetch
# ============================

source "$(dirname "$0")/functions.sh"

log "Starting Amass subdomain enumeration..."
amass enum -passive -d "$DOMAIN" -o "$OUT_DIR/amass_all.txt"
save_output "Amass Output" "$OUT_DIR/amass_all.txt"

log "Filtering only in-scope domains..."
> "$OUT_DIR/scoped.txt"
for domain in "${SCOPED_DOMAINS[@]}"; do
  grep -i "$domain" "$OUT_DIR/amass_all.txt" >> "$OUT_DIR/scoped.txt"
done
sort -u "$OUT_DIR/scoped.txt" -o "$OUT_DIR/scoped.txt"
save_output "Scoped Domains" "$OUT_DIR/scoped.txt"

log "Probing live in-scope domains with httpx..."
httpx -l "$OUT_DIR/scoped.txt" -silent -status-code -title -o "$OUT_DIR/live_scoped.txt"
save_output "Live Domains" "$OUT_DIR/live_scoped.txt"

log "Scraping JavaScript from live scoped domains..."
mkdir -p "$OUT_DIR/js"
while read -r url; do
  domain=$(echo "$url" | sed 's|https\?://||;s|/$||')
  clean_name=$(echo "$domain" | sed 's|[./]|_|g')
  js_out="$OUT_DIR/js/$clean_name"
  mkdir -p "$js_out"
  log "Downloading JS from $url..."
  wget -r -l2 -np -nd -A "*.js" -P "$js_out" "$url" 2>/dev/null
done < "$OUT_DIR/live_scoped.txt"
