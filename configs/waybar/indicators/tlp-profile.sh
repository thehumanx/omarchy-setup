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

get_sot_text() {
    local state_file="$HOME/.local/state/omarchy/sot.state"
    [[ ! -f "$state_file" ]] && { echo "--"; return; }

    local unplug accum screen_since
    read -r unplug accum screen_since < "$state_file"

    if [[ $unplug -eq 0 ]]; then
        echo "Charging"
        return
    fi

    local now total
    now=$(date +%s)
    total=$accum
    [[ $screen_since -gt 0 ]] && total=$((accum + now - screen_since))

    local hours mins
    hours=$((total / 3600))
    mins=$(((total % 3600) / 60))
    echo "${hours}h ${mins}m"
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

    if [[ "$status" == "Discharging" ]]; then
        local power_source="Battery Power"
    else
        local power_source="AC Power"
    fi

    local sot_text
    sot_text=$(get_sot_text)

    local estimate=$(upower -i $(upower -e | grep 'BAT') | grep "time to empty" | awk -F': +' '{print $2}')
    [[ -z "$estimate" ]] && estimate="Calculating..."

    local power=$(cat "$bat_path/power_now" 2>/dev/null || echo 0)
    local watts=$(echo "scale=2; $power / 1000000" | bc -l)

    echo "Mode: $mode"
    echo "Source: $power_source"
    echo "----------------------"
    echo "Screen-On Time: $sot_text"
    echo "Remaining: $estimate"
    echo "Drain Rate: ${watts}W"
    echo "----------------------"
    echo "Click to toggle"
}

ICON=$(get_power_mode)
DETAILS=$(get_mode_details | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\": \"${ICON}\", \"tooltip\": \"$DETAILS\"}"
