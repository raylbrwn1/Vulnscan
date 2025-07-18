#!/bin/bash

# ============================
# Bug Pattern Checker (Custom)
# ============================

source "$(dirname "$0")/functions.sh"

log "Running JavaScript endpoint checks..."

output="$OUT_DIR/bugfinder_output.txt"
> "$output"

for dir in "$OUT_DIR/js"/*; do
  if [[ -d "$dir" ]]; then
    for js_file in "$dir"/*.js; do
      grep -Eo "https?://[a-zA-Z0-9./?=_-]*" "$js_file" >> "$output"
      grep -Ei "api|auth|token|key|endpoint" "$js_file" >> "$output"
    done
  fi
done

sort -u "$output" -o "$output"
save_output "Bug Checker Output" "$output"
