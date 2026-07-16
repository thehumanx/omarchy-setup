#!/bin/bash

# TLP Power Profile Indicator for Waybar

POWER_MODE_FILE="$HOME/.local/state/omarchy/power-mode"

get_power_mode() {
    local mode
    if [[ -f "$POWER_MODE_FILE" ]]; then
        mode=$(cat "$POWER_MODE_FILE")
    else
        mode="default"
    fi
    case "$mode" in
        "powersave")   echo "󰛃" ;;
        "default")     echo "󰚥" ;;
        "performance") echo "󰾪" ;;
        *)             echo "󰾪" ;;
    esac
}

get_mode_details() {
    local mode
    if [[ -f "$POWER_MODE_FILE" ]]; then
        mode=$(cat "$POWER_MODE_FILE")
    else
        mode="default"
    fi
    local bat_path=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)
    local status=$(cat "$bat_path/status" 2>/dev/null)
    local sot_state_file="/tmp/waybar_sot_start_time"
    local now=$(date +%s)

    if [[ "$status" == "Discharging" ]]; then
        if [[ ! -f "$sot_state_file" ]]; then
            echo "$now" > "$sot_state_file"
        fi
        local start_time=$(cat "$sot_state_file")
        local diff=$((now - start_time))
        local hours=$((diff / 3600))
        local mins=$(((diff % 3600) / 60))
        local sot_text="${hours}h ${mins}m"
        local power_source="Battery Power"
    else
        rm -f "$sot_state_file" 2>/dev/null
        local sot_text="Charging/Full"
        local power_source="AC Power"
    fi

    local estimate=$(upower -i $(upower -e | grep 'BAT') | grep "time to empty" | awk -F': +' '{print $2}')
    [[ -z "$estimate" ]] && estimate="Calculating..."

    local power=$(cat "$bat_path/power_now" 2>/dev/null || echo 0)
    local watts=$(echo "scale=2; $power / 1000000" | bc -l)

    echo "Mode: $mode"
    echo "Source: $power_source"
    echo "----------------------"
    echo "Current SOT: $sot_text"
    echo "Remaining: $estimate"
    echo "Drain Rate: ${watts}W"
    echo "----------------------"
    echo "Click to toggle"
}

ICON=$(get_power_mode)
DETAILS=$(get_mode_details | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\": \"${ICON}\", \"tooltip\": \"$DETAILS\"}"
