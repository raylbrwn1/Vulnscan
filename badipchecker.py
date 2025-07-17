import os
import platform
import subprocess
import requests
from datetime import datetime

# === Configuration ===
THREAT_FEEDS = {
    "Feodo Tracker": "https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.txt",
    "AlienVault OTX": "https://reputation.alienvault.com/reputation.generic",
    "Blocklist.de": "https://lists.blocklist.de/lists/all.txt",
    "Malc0de": "http://malc0de.com/bl/IP_Blacklist.txt",
    "Emerging Threats": "https://rules.emergingthreats.net/blockrules/compromised-ips.txt"
}

LOG_FILE = "/home/sandbender/PyScripts/VulnScan/BadIPs/BadBadIps.log"
EXPECTED_CONN_FILE = "/home/sandbender/PyScripts/VulnScan/BadIPs/ExpectedConnections.txt"
ALERT_MESSAGE = "⚠️ Suspicious network connection detected!\nIP: {}\nTime: {}"

# === Functions ===

def fetch_malicious_ips():
    all_ips = set()
    for name, url in THREAT_FEEDS.items():
        try:
            print(f"[*] Fetching from: {name}")
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                lines = response.text.splitlines()
                for line in lines:
                    line = line.strip()
                    if line and not line.startswith("#") and not line.startswith(";"):
                        if ' ' in line:
                            line = line.split()[0]
                        all_ips.add(line)
            else:
                print(f"[!] Failed to fetch from {name} (HTTP {response.status_code})")
        except Exception as e:
            print(f"[!] Error fetching from {name}: {e}")
    return all_ips

def get_active_connections():
    try:
        system_platform = platform.system()
        if system_platform == "Windows":
            result = subprocess.check_output(["netstat", "-n"], text=True)
        else:
            result = subprocess.check_output(["netstat", "-tun"], text=True)
        lines = result.splitlines()
        connections = set()
        for line in lines:
            parts = line.split()
            if len(parts) >= 5 and ("." in parts[0] or parts[0].startswith("tcp")):
                ip_port = parts[4] if system_platform == "Windows" else parts[4]
                ip = ip_port.split(':')[0]
                connections.add(ip)
        return connections
    except Exception as e:
        print(f"Error getting connections: {e}")
        return set()

def load_expected_connections():
    if not os.path.exists(EXPECTED_CONN_FILE):
        return set()
    with open(EXPECTED_CONN_FILE, "r") as f:
        return set(line.strip() for line in f.readlines())

def save_expected_connections(connections):
    with open(EXPECTED_CONN_FILE, "w") as f:
        for conn in sorted(connections):
            f.write(conn + "\n")

def alert_user(ip):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = ALERT_MESSAGE.format(ip, timestamp)
    print(message)
    with open(LOG_FILE, "a") as log:
        log.write(message + "\n")

# === Main ===
def scan_connections():
    print("[*] Fetching threat intel feeds...")
    bad_ips = fetch_malicious_ips()
    if not bad_ips:
        print("No malicious IPs loaded. Exiting.")
        return

    print("[*] Scanning active connections...")
    active_ips = get_active_connections()
    expected_ips = load_expected_connections()

    print("[*] Comparing against malicious IP list and expected connections...")
    for ip in active_ips:
        if ip in bad_ips:
            alert_user(ip)
        elif ip not in expected_ips:
            print(f"[?] Unknown connection: {ip} (Consider reviewing)")

    save_expected_connections(expected_ips.union(active_ips))
    print("[✓] Scan complete.")

# === Run ===
if __name__ == "__main__":
    scan_connections()
