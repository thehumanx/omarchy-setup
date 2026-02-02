#!/bin/bash

# TLP Power Profile Indicator for Waybar
get_power_mode() {
    local mode=$(/home/bbk/.config/omarchy/power-mode/power-mode-toggle.sh get 2>/dev/null)
    case "$mode" in
        "powersaver") echo "󰛃" ;;
        "automatic")  echo "󰚥" ;;
        *)            echo "󰾪" ;;
    esac
}

get_mode_details() {
    local mode=$(/home/bbk/.config/omarchy/power-mode/power-mode-toggle.sh get 2>/dev/null)
    local bat_path=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)
    local status=$(cat "$bat_path/status" 2>/dev/null)
    
    # 1. Calculate SOT (Time since last discharge began)
    # Uses the modification time of the battery status file as a proxy
    local last_change=$(stat -c %Y "$bat_path/status")
    local now=$(date +%s)
    local diff=$((now - last_change))
    
    if [[ "$status" == "Discharging" ]]; then
        local hours=$((diff / 3600))
        local mins=$(((diff % 3600) / 60))
        local sot_text="${hours}h ${mins}m"
        local power_source="Battery Power"
    else
        local sot_text="Charging/Full"
        local power_source="AC Power"
    fi

    # 2. Get Estimates from upower
    local estimate=$(upower -i $(upower -e | grep 'BAT') | grep "time to empty" | awk -F': +' '{print $2}')
    [[ -z "$estimate" ]] && estimate="Calculating..."

    # 3. Get Wattage (Current Drain)
    local voltage=$(cat "$bat_path/voltage_now")
    local current=$(cat "$bat_path/current_now")
    local watts=$(echo "scale=2; ($voltage * $current) / 1000000000000" | bc -l)

    # Format Tooltip Output
    echo "Mode: $mode"
    echo "Source: $power_source"
    echo "----------------------"
    echo "Current SOT: $sot_text"
    echo "Remaining: $estimate"
    echo "Drain Rate: ${watts}W"
    echo "----------------------"
    echo "Click to toggle"
}

# Output JSON for Waybar
ICON=$(get_power_mode)
DETAILS=$(get_mode_details | sed ':a;N;$!ba;s/\n/\\n/g') # Convert newlines for JSON

echo "{\"text\": \"$ICON\", \"tooltip\": \"$DETAILS\"}"
