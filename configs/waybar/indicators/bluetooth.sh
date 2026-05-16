#!/bin/bash
# Bluetooth status indicator for Waybar

# Save current state for persistence across reboots
~/.config/omarchy/bluetooth-state.sh save

readarray -t devices < <(bluetoothctl devices Connected 2>/dev/null)

if [[ ${#devices[@]} -eq 0 ]]; then
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        echo '{"text": "󰂱", "tooltip": "No devices connected", "class": "connected"}'
    else
        echo '{"text": "󰂲", "tooltip": "Bluetooth off", "class": "off"}'
    fi
else
    names=()
    for device in "${devices[@]}"; do
        name=$(echo "$device" | cut -d' ' -f3-)
        names+=("$name")
    done
    IFS=", " joined="${names[*]}"
    echo "{\"text\": \"󰂱\", \"tooltip\": \"$joined\", \"class\": \"connected\"}"
fi
