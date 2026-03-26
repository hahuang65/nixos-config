#!/bin/bash
# Custom clock module for waybar
# Shows local time in bar, world times on hover

# Bar text: local time
local_time=$(date +'%H:%M')
text="$local_time"

# Tooltip: world clocks with city labels, ordered by UTC offset
# Using Pango monospace for alignment
# "LOCAL" marks the local timezone
timezones=(
    "Honolulu|Pacific/Honolulu"
    "Anchorage|America/Anchorage"
    "Los Angeles|America/Los_Angeles"
    "Denver|America/Denver"
    "LOCAL"
    "New York|America/New_York"
    "Santiago|America/Santiago"
    "London|Europe/London"
    "Berlin|Europe/Berlin"
    "Cairo|Africa/Cairo"
    "Moscow|Europe/Moscow"
    "Dubai|Asia/Dubai"
    "Mumbai|Asia/Kolkata"
    "Bangkok|Asia/Bangkok"
    "Shanghai|Asia/Shanghai"
    "Tokyo|Asia/Tokyo"
    "Sydney|Australia/Sydney"
    "Auckland|Pacific/Auckland"
)

lines=""
for entry in "${timezones[@]}"; do
    if [[ "$entry" == "LOCAL" ]]; then
        local_city=$(timedatectl show -p Timezone --value 2>/dev/null | sed 's|.*/||')
        local_label="Local ($local_city)"
        lines+="<b>$local_time  $local_label</b>"
    else
        label="${entry%%|*}"
        tz="${entry##*|}"
        time_str=$(TZ="$tz" date +'%H:%M')
        lines+="$time_str  $label"
    fi
    lines+='\n'
done

# Remove trailing \n
lines="${lines%\\n}"

tooltip="<tt>$lines</tt>"

# Escape quotes for JSON
text="${text//\"/\\\"}"
tooltip="${tooltip//\"/\\\"}"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
