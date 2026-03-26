#!/bin/bash
# Custom volume output module for waybar
# Long-running event-driven script: prints JSON on startup and on every sink change

ICON_VOL_OFF=$(printf '\uf026')    # FontAwesome volume-off
ICON_VOL_DOWN=$(printf '\uf027')   # FontAwesome volume-down
ICON_VOL_UP=$(printf '\uf028')     # FontAwesome volume-up
ICON_VOL_MUTED=$(printf '\U000f075f') # nf-md-volume-mute
ICON_BT=$(printf '\uf294')         # FontAwesome bluetooth

print_volume() {
    info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    volume=$(echo "$info" | grep -oP 'Volume: \K[0-9.]+')
    muted=$(echo "$info" | grep -c MUTED)

    # Convert to percentage
    pct=$(awk "BEGIN {printf \"%.0f\", ${volume:-0} * 100}")

    # Get sink name (nickname)
    local inspect
    inspect=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    sink_name=$(echo "$inspect" | grep 'node.nick' | sed 's/.*= "//' | sed 's/"//')
    if [[ -z "$sink_name" ]]; then
        sink_name=$(echo "$inspect" | grep 'node.description' | sed 's/.*= "//' | sed 's/"//')
    fi

    # Check if bluetooth
    is_bt=$(echo "$inspect" | grep -c 'api.bluez5')

    # Pick icon
    if [[ "$muted" -eq 1 ]]; then
        text="$ICON_VOL_MUTED"
        class="muted"
    elif [[ "$pct" -le 30 ]]; then
        text="$ICON_VOL_OFF $pct%"
        class=""
    elif [[ "$pct" -le 60 ]]; then
        text="$ICON_VOL_DOWN $pct%"
        class=""
    else
        text="$ICON_VOL_UP $pct%"
        class=""
    fi

    # Prepend bluetooth icon if applicable
    if [[ "$is_bt" -ge 1 && "$muted" -ne 1 ]]; then
        text="$ICON_BT $text"
        class="bluetooth"
    fi

    tooltip="$sink_name"

    # Escape for JSON
    text="${text//\"/\\\"}"
    tooltip="${tooltip//\"/\\\"}"

    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
}

# Print initial state
print_volume

# Listen for sink changes and reprint
pactl subscribe 2>/dev/null | while read -r line; do
    if echo "$line" | grep -qE "'change' on sink"; then
        print_volume
    fi
done
