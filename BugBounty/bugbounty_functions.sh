#!/bin/bash

# =============================
# Shared functions and variables for Bug Bounty Scripts
# =============================

# Load target DOMAIN and SCOPED_DOMAINS from config
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/scopeconfig.sh"

# Allow OUT_DIR to be overridden externally (e.g., by BugBountyAuto.sh)
OUT_DIR="${OUT_DIR:-$HOME/bugbounty/${DOMAIN}_recon_default/recon_output}"
mkdir -p "$OUT_DIR"

log() {
  echo -e "[\033[1;34m*\033[0m] $1"
}

save_output() {
  local label="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    echo "$label: $file" >> "$OUT_DIR/../summary.txt"
  fi
}
