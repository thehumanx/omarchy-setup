#!/bin/bash

# Power Mode Toggle Script for Lenovo Slim 7 with TLP
# Modes: automatic, powersaver

POWER_MODE_FILE="/tmp/power_mode"
CONFIG_DIR="/home/bbk/.config/omarchy/power-mode"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Get current mode or default to automatic
get_current_mode() {
    if [ -f "$POWER_MODE_FILE" ]; then
        cat "$POWER_MODE_FILE"
    else
        echo "automatic"
    fi
}

# Apply power mode settings
apply_mode() {
    local mode="$1"
    
    case "$mode" in
        "automatic")
            # Reset to TLP defaults (respects TLP + Intel Evo optimization)
            sudo tlp start 2>/dev/null
            # Reset brightness to normal (can be customized)
            brightnessctl set 75% 2>/dev/null || true
            ;;
        "powersaver")
            # Force powersave governor even on AC
            sudo tlp start -c "CPU_SCALING_GOVERNOR_ON_AC=powersave" 2>/dev/null
            sudo tlp start -c "CPU_SCALING_GOVERNOR_ON_BAT=powersave" 2>/dev/null
            # Lower screen brightness for battery saving
            brightnessctl set 40% 2>/dev/null || true
            # Disable turbo boost for maximum efficiency
            echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
            ;;
    esac
    
    # Save current mode
    echo "$mode" > "$POWER_MODE_FILE"
    
    # Send notification
    notify_mode_change "$mode"
}

# Show notification for mode change
notify_mode_change() {
    local mode="$1"
    local icon
    local message
    
    case "$mode" in
        "automatic")
            icon="⚡"
            message="Automatic power mode - Full performance when needed"
            ;;
        "powersaver")
            icon="🪫"
            message="Power saver mode - Maximum battery life"
            ;;
    esac
    
    # Show notification
    notify-send "Power Mode" "$icon $message" -u low -t 2000
}

# Toggle between modes
toggle_mode() {
    local current_mode=$(get_current_mode)
    local new_mode
    
    case "$current_mode" in
        "automatic")
            new_mode="powersaver"
            ;;
        "powersaver")
            new_mode="automatic"
            ;;
        *)
            new_mode="automatic"
            ;;
    esac
    
    apply_mode "$new_mode"
    echo "$new_mode"
}

# Main execution
case "$1" in
    "get"|"status")
        get_current_mode
        ;;
    "toggle")
        toggle_mode
        ;;
    "set")
        if [ -n "$2" ]; then
            apply_mode "$2"
        else
            echo "Usage: $0 set <mode>"
            echo "Available modes: automatic, powersaver"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {get|toggle|set} [mode]"
        echo "Commands:"
        echo "  get     - Get current power mode"
        echo "  toggle  - Toggle between modes"
        echo "  set     - Set specific mode (automatic|powersaver)"
        exit 1
        ;;
esac