#!/bin/bash

# ===============================
# Master Launcher: BugBountyAuto.sh
# ===============================
# This script orchestrates the full bug bounty recon workflow.
# It includes a timestamped recon folder and outputs a summary report.

# === Setup ===
set -e  # Exit on error

# === Paths ===
BB_DIR="$HOME/bugbounty"
SCRIPT_DIR="$BB_DIR/scripts"
RECON_TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# === Step 1: Define scope ===
echo "[*] Running scope definition..."
SCOPE_SCRIPT="$SCRIPT_DIR/domainscope.py"  # or set_sitescope.py
python3 "$SCOPE_SCRIPT"

# Load DOMAIN from scopeconfig.sh generated by the scope script
source "$SCRIPT_DIR/scopeconfig.sh"
TARGET_NAME="$DOMAIN"
RECON_DIR="$BB_DIR/${TARGET_NAME}_recon_$RECON_TIMESTAMP"
mkdir -p "$RECON_DIR"

SITE_RECON="$SCRIPT_DIR/site_recon.sh"
FFUF_SCAN="$SCRIPT_DIR/fuffscan.sh"
BUG_CHECKER="$SCRIPT_DIR/bug-checker.sh"
APK_PULL="$SCRIPT_DIR/apkpull-compile.sh"  # Optional
SUMMARY_REPORT="$RECON_DIR/summary.txt"

# === Step 2: Recon and subdomain enum ===
echo "[*] Running recon (amass, httpx, JS scraping)..."
RECON_OUT_DIR="$RECON_DIR/recon_output"
mkdir -p "$RECON_OUT_DIR"
SITE_RECON_OUT_DIR="$RECON_OUT_DIR"
export OUT_DIR="$SITE_RECON_OUT_DIR"
bash "$SITE_RECON"

# === Step 3: Directory fuzzing with ffuf ===
echo "[*] Running ffuf scan on live scoped domains..."
bash "$FFUF_SCAN" > "$RECON_DIR/ffuf_output.txt"

# === Step 4: JavaScript endpoint hunting / custom checks ===
echo "[*] Running bug checker..."
bash "$BUG_CHECKER" > "$RECON_DIR/bugchecker_output.txt"

# === Step 5 (Optional): APK pulling and decompilation ===
echo "[*] Run Android recon? (y/n)"
read -r apkchoice
if [[ "$apkchoice" == "y" || "$apkchoice" == "Y" ]]; then
    echo "[*] Pulling APKs and compiling..."
    bash "$APK_PULL" > "$RECON_DIR/apk_output.txt"
else
    echo "[i] Skipping APK pulling." >> "$SUMMARY_REPORT"
fi

# === Summary Report ===
echo "[*] Writing summary report to $SUMMARY_REPORT"
echo "Recon run: $RECON_TIMESTAMP" > "$SUMMARY_REPORT"
echo "Target: $TARGET_NAME" >> "$SUMMARY_REPORT"
echo "Scope defined via: $SCOPE_SCRIPT" >> "$SUMMARY_REPORT"
echo "Subdomain and recon results in: $SITE_RECON_OUT_DIR" >> "$SUMMARY_REPORT"
echo "FFUF results: $RECON_DIR/ffuf_output.txt" >> "$SUMMARY_REPORT"
echo "Bug checker output: $RECON_DIR/bugchecker_output.txt" >> "$SUMMARY_REPORT"
if [[ "$apkchoice" == "y" || "$apkchoice" == "Y" ]]; then
    echo "APK analysis: $RECON_DIR/apk_output.txt" >> "$SUMMARY_REPORT"
else
    echo "APK analysis: Skipped" >> "$SUMMARY_REPORT"
fi

echo "[✓] Bug bounty recon complete. See summary: $SUMMARY_REPORT"
