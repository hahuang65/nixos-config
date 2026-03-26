#!/bin/bash
# Custom network module for waybar
# Shows WiFi SSID with VPN indicator when a VPN is active
# Output format: JSON for waybar (return-type: json)

# Define icons via unicode escapes to avoid encoding issues
ICON_WIFI=$(printf '\uf1eb')       # FontAwesome wifi icon
ICON_LOCAL=$(printf '\U000f0a5f')  # nf-md-ip-network
ICON_VPN=$(printf '\U000f033e')    # nf-md-lock
ICON_DISCONNECTED=$(printf '\U000f05aa') # nf-md-wifi-off

get_wifi_info() {
    local iface="wlan0"
    local state
    state=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)

    if [[ "$state" != "up" ]]; then
        return 1
    fi

    local ssid signal
    ssid=$(iw dev "$iface" link 2>/dev/null | grep 'SSID:' | sed 's/.*SSID: //')
    signal=$(iw dev "$iface" link 2>/dev/null | grep 'signal:' | sed 's/.*signal: //' | sed 's/ dBm//')

    if [[ -z "$ssid" ]]; then
        return 1
    fi

    # Convert dBm to rough percentage
    local pct=0
    if [[ -n "$signal" ]]; then
        # Clamp between -100 and -30 dBm, map to 0-100%
        if (( signal >= -30 )); then
            pct=100
        elif (( signal <= -100 )); then
            pct=0
        else
            pct=$(( (signal + 100) * 100 / 70 ))
        fi
    fi

    echo "$ssid|$pct"
}

get_vpn_status() {
    # Check for common VPN interfaces (WireGuard, OpenVPN, etc.)
    for iface in /sys/class/net/{proton,wg,tun,vpn,mullvad,nordlynx}*; do
        if [[ -d "$iface" ]]; then
            local state
            state=$(cat "$iface/operstate" 2>/dev/null)
            if [[ "$state" == "unknown" || "$state" == "up" ]]; then
                return 0
            fi
        fi
    done
    return 1
}

get_local_ip() {
    local iface="$1"
    ip -4 addr show dev "$iface" 2>/dev/null | grep -oP 'inet \K[0-9.]+'
}

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
CACHE_FILE="$CACHE_DIR/remote_ip"

get_remote_ip_info() {
    # Returns "ip|city|country" from cache or fresh lookup.
    # Cache is keyed on VPN status and refreshed every 5 minutes.
    local vpn_state="$1"
    local now
    now=$(date +%s)

    mkdir -p "$CACHE_DIR"

    if [[ -f "$CACHE_FILE" ]]; then
        local cached_state cached_time
        cached_state=$(sed -n '1p' "$CACHE_FILE")
        cached_time=$(sed -n '2p' "$CACHE_FILE")
        local age=$(( now - cached_time ))

        # Use cache if VPN state hasn't changed and cache is < 5 min old
        if [[ "$cached_state" == "$vpn_state" && $age -lt 300 ]]; then
            sed -n '3p' "$CACHE_FILE"
            return
        fi
    fi

    # Fetch fresh data (timeout after 3s to avoid blocking waybar)
    local json
    json=$(curl -s --max-time 3 https://ipinfo.io/json 2>/dev/null)

    if [[ -n "$json" ]]; then
        local rip rcity rcountry
        rip=$(echo "$json" | grep -oP '"ip"\s*:\s*"\K[^"]+')
        rcity=$(echo "$json" | grep -oP '"city"\s*:\s*"\K[^"]+')
        rcountry=$(echo "$json" | grep -oP '"country"\s*:\s*"\K[^"]+')
        local result="$rip|$rcity|$rcountry"

        # Write cache
        printf '%s\n%s\n%s\n' "$vpn_state" "$now" "$result" > "$CACHE_FILE"
        echo "$result"
    else
        # Return stale cache if available, otherwise empty
        [[ -f "$CACHE_FILE" ]] && sed -n '3p' "$CACHE_FILE"
    fi
}

# --- Main ---

wifi_info=$(get_wifi_info)
vpn_active=false
get_vpn_status && vpn_active=true

# Fetch remote IP info (cached)
remote_info=$(get_remote_ip_info "$vpn_active")
remote_ip="${remote_info%%|*}"
remote_loc="${remote_info#*|}"
remote_city="${remote_loc%%|*}"
remote_country="${remote_loc##*|}"

ICON_GLOBE=$(printf '\U000f059f')  # nf-md-web
if [[ -n "$remote_ip" ]]; then
    remote_line="$ICON_GLOBE  $remote_ip ($remote_city, $remote_country)"
else
    remote_line=""
fi

if [[ -n "$wifi_info" ]]; then
    ssid="${wifi_info%%|*}"
    signal="${wifi_info##*|}"
    local_ip=$(get_local_ip wlan0)

    if [[ "$vpn_active" == true ]]; then
        text="$ICON_WIFI $ssid  $ICON_VPN"
        tooltip="$ICON_WIFI $ssid (${signal}%)\n$ICON_LOCAL  $local_ip\n$ICON_VPN  VPN active\n$remote_line"
        class="wifi-vpn"
    else
        text="$ICON_WIFI $ssid"
        tooltip="$ICON_WIFI $ssid (${signal}%)\n$ICON_LOCAL  $local_ip\n$remote_line"
        class="wifi"
    fi
elif [[ "$vpn_active" == true ]]; then
    text="$ICON_VPN VPN"
    tooltip="$ICON_VPN  VPN active (no WiFi)\n$remote_line"
    class="vpn"
else
    text="$ICON_DISCONNECTED NONE"
    tooltip="Disconnected"
    class="disconnected"
fi

# Escape for JSON
text="${text//\"/\\\"}"
tooltip="${tooltip//\"/\\\"}"

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
