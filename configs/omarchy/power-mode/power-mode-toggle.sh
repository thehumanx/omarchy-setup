#!/bin/bash

# Power Mode Toggle Script for Lenovo Slim 7 with TLP
# Modes: default, powersave, performance

POWER_MODE_FILE="$HOME/.local/state/omarchy/power-mode"

mkdir -p "$(dirname "$POWER_MODE_FILE")"

get_current_mode() {
    if [[ -f "$POWER_MODE_FILE" ]]; then
        cat "$POWER_MODE_FILE"
    else
        echo "default"
    fi
}

apply_mode() {
    local mode="$1"

    case "$mode" in
        "default")
            sudo tlp start 2>/dev/null
            echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
            ;;
        "powersave")
            sudo tlp power-saver 2>/dev/null
            echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
            ;;
        "performance")
            sudo tlp performance 2>/dev/null
            echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
            ;;
    esac

    echo "$mode" > "$POWER_MODE_FILE"
    notify_mode_change "$mode"
}

notify_mode_change() {
    local mode="$1"
    local icon
    local message

    case "$mode" in
        "default")
            icon="⚡"
            message="Default mode — TLP auto-switches based on AC/battery"
            ;;
        "powersave")
            icon="🪫"
            message="Power saver — maximum battery life (turbo disabled)"
            ;;
        "performance")
            icon="🚀"
            message="Performance mode — full speed, no power saving"
            ;;
    esac

    notify-send "Power Mode" "$icon $message" -u low -t 2000
}

toggle_mode() {
    local current_mode=$(get_current_mode)
    local new_mode

    case "$current_mode" in
        "default")
            new_mode="powersave"
            ;;
        "powersave")
            new_mode="performance"
            ;;
        "performance")
            new_mode="default"
            ;;
        *)
            new_mode="default"
            ;;
    esac

    apply_mode "$new_mode"
    echo "$new_mode"
}

case "$1" in
    "get"|"status")
        get_current_mode
        ;;
    "toggle")
        toggle_mode
        ;;
    "set")
        if [[ -n "$2" ]]; then
            apply_mode "$2"
        else
            echo "Usage: $0 set <mode>"
            echo "Available modes: default, powersave, performance"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {get|toggle|set} [mode]"
        echo "Commands:"
        echo "  get     - Get current power mode"
        echo "  toggle  - Toggle between modes"
        echo "  set     - Set specific mode (default|powersave|performance)"
        exit 1
        ;;
esac
