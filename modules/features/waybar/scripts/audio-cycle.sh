#!/bin/bash
# Cycle through available audio sinks or sources using wpctl
# Usage: audio-cycle.sh sink|source

type="$1"

if [[ "$type" == "sink" ]]; then
    section="Sinks:"
elif [[ "$type" == "source" ]]; then
    section="Sources:"
else
    echo "Usage: $0 sink|source" >&2
    exit 1
fi

# Parse wpctl status to extract node IDs from the target section
# Stop at the next section header (line containing ─)
in_section=false
ids=()
current_id=""

while IFS= read -r line; do
    if [[ "$line" == *"$section"* ]]; then
        in_section=true
        continue
    fi
    if $in_section; then
        # Stop at next section (lines with ─ like ├─ or └─)
        if [[ "$line" =~ [├└]─ ]]; then
            break
        fi
        # Extract node ID (number after optional * marker)
        if [[ "$line" =~ ^[[:space:]│]*\*?[[:space:]]*([0-9]+)\. ]]; then
            ids+=("${BASH_REMATCH[1]}")
            if [[ "$line" == *"*"* ]]; then
                current_id="${BASH_REMATCH[1]}"
            fi
        fi
    fi
done < <(wpctl status --nick)

if [[ ${#ids[@]} -lt 2 ]]; then
    exit 0  # Nothing to cycle
fi

# Find next ID in the list
next_id="${ids[0]}"
for i in "${!ids[@]}"; do
    if [[ "${ids[$i]}" == "$current_id" ]]; then
        next_index=$(( (i + 1) % ${#ids[@]} ))
        next_id="${ids[$next_index]}"
        break
    fi
done

wpctl set-default "$next_id"
