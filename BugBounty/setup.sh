#!/bin/bash

echo "[*] Updating package lists..."
sudo apt update

echo "[*] Installing system packages..."
sudo apt install -y amass httpx ffuf wget jadx python3-pip dos2unix git

echo "[*] Creating tools directory..."
mkdir -p ~/BugBounty/tools

echo "[*] Cloning LinkFinder..."
git clone https://github.com/GerbenJavado/LinkFinder.git ~/BugBounty/tools/LinkFinder

echo "[*] Setting up Python virtual environment..."
python3 -m venv ~/BugBounty/tools/bountyenv
source ~/BugBounty/tools/bountyenv/bin/activate

echo "[*] Installing Python requirements..."
pip install -r ~/BugBounty/tools/LinkFinder/requirements.txt
pip install -r ~/BugBounty/requirements.txt

echo "[✓] Environment setup complete. Use 'source ~/BugBounty/tools/bountyenv/bin/activate' to start."
