# set_syfe_scope.py
output_file = "scopeconfig.sh"

# Prompt for primary domain
primary_domain = input("Enter the primary root domain (e.g., syfe.com): ").strip()

# Prompt for scoped domains (comma-separated)
scoped = input("Enter in-scope subdomains (comma-separated, e.g., www.syfe.com,api.syfe.com): ")
scoped_list = [d.strip() for d in scoped.split(",") if d.strip()]

# Generate Bash variable declarations
with open(output_file, "w") as f:
    f.write(f'DOMAIN="{primary_domain}"\n')
    f.write("SCOPED_DOMAINS=(")
    f.write(" ".join(f'"{d}"' for d in scoped_list))
    f.write(")\n")

print(f"[✓] Scope written to {output_file}")

