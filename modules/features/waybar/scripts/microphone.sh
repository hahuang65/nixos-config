#!/bin/bash
# Custom microphone module for waybar
# Long-running event-driven script: prints JSON on startup and on every source change

ICON_MIC=$(printf '\uf130')        # FontAwesome microphone
ICON_MIC_MUTED=$(printf '\uf131')  # FontAwesome microphone-slash

print_microphone() {
    info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
    volume=$(echo "$info" | grep -oP 'Volume: \K[0-9.]+')
    muted=$(echo "$info" | grep -c MUTED)

    # Convert to percentage
    pct=$(awk "BEGIN {printf \"%.0f\", ${volume:-0} * 100}")

    # Get source name
    local inspect
    inspect=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
    source_name=$(echo "$inspect" | grep 'node.nick' | sed 's/.*= "//' | sed 's/"//')
    if [[ -z "$source_name" ]]; then
        source_name=$(echo "$inspect" | grep 'node.description' | sed 's/.*= "//' | sed 's/"//')
    fi

    if [[ "$muted" -eq 1 ]]; then
        text="$ICON_MIC_MUTED"
        class="muted"
    else
        text="$ICON_MIC $pct%"
        class=""
    fi

    tooltip="$source_name"

    # Escape for JSON
    text="${text//\"/\\\"}"
    tooltip="${tooltip//\"/\\\"}"

    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
}

# Print initial state
print_microphone

# Listen for source changes and reprint
pactl subscribe 2>/dev/null | while read -r line; do
    if echo "$line" | grep -qE "'change' on source"; then
        print_microphone
    fi
done
