#!/bin/bash

# TLP Power Profile Indicator for Waybar
# Returns current power mode from your custom toggle script

get_power_mode() {
    # Get current mode from your power mode toggle script
    local mode=$(/home/bbk/.config/omarchy/power-mode/power-mode-toggle.sh get 2>/dev/null)
    
    case "$mode" in
        "powersaver")
            echo "󰛃"  # Battery icon for powersaver
            ;;
        "automatic")
            echo "󰚥"  # Power icon for automatic
            ;;
        *)
            echo "󰾪"  # Default/unknown icon
            ;;
    esac
}

get_mode_details() {
    # Get current mode and power source
    local mode=$(/home/bbk/.config/omarchy/power-mode/power-mode-toggle.sh get 2>/dev/null)
    local power_source="Unknown"
    
    if grep -q "1" /sys/class/power_supply/AC/online 2>/dev/null; then
        power_source="AC Power"
    elif grep -q "Discharging" /sys/class/power_supply/BAT*/status 2>/dev/null; then
        power_source="Battery Power"
    fi
    
    echo "Mode: $mode\\nSource: $power_source\\n\\nClick to toggle"
}

# Output JSON for Waybar
ICON=$(get_power_mode)
DETAILS=$(get_mode_details)

echo "{\"text\": \"$ICON\", \"tooltip\": \"Power Profile\\n$DETAILS\"}"