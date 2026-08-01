#!/usr/bin/env bash
# last_verified: 2026-08-01 · IaC n/a
# generate-compose.sh — build a docker-compose.yaml from a simple service list.

set -euo pipefail

SERVICES_FILE="${1:-services.txt}"
OUTPUT_FILE="${2:-docker-compose.yaml}"

if [[ ! -f "$SERVICES_FILE" ]]; then
    echo "Error: services file '$SERVICES_FILE' not found." >&2
    exit 1
fi

cat > "$OUTPUT_FILE" <<'EOF'
version: "3.9"
services:
EOF

while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    read -r name image ports_str <<< "$line"

    if [[ -z "$name" || -z "$image" ]]; then
        echo "Warning: skipping malformed line: $line" >&2
        continue
    fi

    echo "  ${name}:" >> "$OUTPUT_FILE"
    echo "    image: ${image}" >> "$OUTPUT_FILE"

    if [[ -n "$ports_str" ]]; then
        echo "    ports:" >> "$OUTPUT_FILE"
        IFS=',' read -ra port_arr <<< "$ports_str"
        for p in "${port_arr[@]}"; do
            echo "      - \"${p}\"" >> "$OUTPUT_FILE"
        done
    fi
done < "$SERVICES_FILE"

echo "Generated ${OUTPUT_FILE} from ${SERVICES_FILE}"
