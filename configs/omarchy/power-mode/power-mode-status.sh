#!/bin/bash

# Power Mode Status Script for Waybar
# Shows current power mode with appropriate icon and color

POWER_MODE_FILE="/tmp/power_mode"
SCRIPT_DIR="/home/bbk/.config/omarchy/power-mode"

# Get current power mode
get_current_mode() {
    if [ -f "$POWER_MODE_FILE" ]; then
        cat "$POWER_MODE_FILE"
    else
        echo "automatic"
    fi
}

# Get mode icon and class
get_mode_info() {
    local mode=$(get_current_mode)
    local icon
    local class
    local tooltip
    
    case "$mode" in
        "automatic")
            icon="⚡"
            class="power-automatic"
            tooltip="Automatic power mode\nTLP + Intel Evo optimization\nPerformance when needed, efficiency when not"
            ;;
        "powersaver")
            icon="🪫"
            class="power-powersaver"
            tooltip="Power saver mode\nMaximum battery life\nForced powersave governor, lower brightness"
            ;;
        *)
            icon="⚡"
            class="power-automatic"
            tooltip="Automatic power mode\nTLP + Intel Evo optimization"
            ;;
    esac
    
    # Output JSON for Waybar
    echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
}

# Main execution
get_mode_info