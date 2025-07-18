#!/bin/bash

# =============================
# Shared functions and variables for Bug Bounty Scripts
# =============================

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/scopeconfig.sh"

# Setup recon output folder dynamically
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
RECON_ROOT="$HOME/bugbounty/${DOMAIN}_recon_${NOW}"
OUT_DIR="$RECON_ROOT/recon_output"
mkdir -p "$OUT_DIR"

log() {
  echo -e "[\033[1;34m*\033[0m] $1"
}

save_output() {
  local label="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    echo "$label: $file" >> "$RECON_ROOT/summary.txt"
  fi
}

