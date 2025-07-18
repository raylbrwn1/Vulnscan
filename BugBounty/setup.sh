#!/bin/bash

echo "[*] Making BugBounty directory"
mkdir ~/bugbounty

echo "[*] Making sub directories"
mkdir ~/bugbounty/scripts
mkdir ~/bugbounty/tools
mkdir ~/bugbounty/recon

echo "[*] Updating package lists..."
sudo apt update

echo "[*] Installing system packages..."
sudo apt install -y amass httpx ffuf wget jadx python3-pip dos2unix git

echo "[*] Setting up virtual environment."
python3 -m ~/bugbounty/tools/.venv
source ~/bugbounty/tools/.venv/bin/activate

echo "[*] Downloading scripts."
wget -P ~/bugbounty https://raw.githubusercontent.com/raylbrwn1/Vulnscan/refs/heads/main/BugBounty/requirements
wget -P ~/bugbounty/scripts https://raw.githubusercontent.com/raylbrwn1/Vulnscan/refs/heads/main/BugBounty/bug-checker.sh
wget -P ~/bugbounty/scripts https://raw.githubusercontent.com/raylbrwn1/Vulnscan/refs/heads/main/BugBounty/set_sitescope.py
wget -P ~/bugbounty/scripts https://raw.githubusercontent.com/raylbrwn1/Vulnscan/refs/heads/main/BugBounty/site_recon.sh

echo "[*] Making sure files are ready to use"
dos2unix requirements
dos2unix bug-checker.sh
dos2unix site_recon.sh

chmod +x ~/bugbounty/requirements
chmod +x ~/bugbounty/scripts/bug-checker.sh
chmod +x ~/bugbounty/scripts/set_sitescope.py
chmod +x ~/bugbounty/scripts/site_recon.sh

echo "[*] Cloning LinkFinder..."
git clone https://github.com/GerbenJavado/LinkFinder.git ~/bugbounty/tools/LinkFinder

echo "[*] Installing Python requirements..."
pip install -r ~/bugbounty/requirements

echo "[✓] Environment setup complete."
