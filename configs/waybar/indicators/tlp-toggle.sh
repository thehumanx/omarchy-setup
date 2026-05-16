#!/bin/bash

# TLP Profile Toggle Script for Waybar
# Toggles between powersave and automatic (balanced) profiles

get_current_profile() {
    tlp-stat -m 2>/dev/null | cut -d'/' -f1
}

set_tlp_profile() {
    local profile="$1"
    # You'll need to configure sudo access for this command
    # or set up a polkit rule for tlp
    echo "Setting TLP profile to: $profile"
    # This requires sudo - you may need to configure passwordless sudo for tlp
    # sudo tlp start $profile
}

# Toggle logic
current=$(get_current_profile)

case "$current" in
    "powersave")
        # Switch to automatic/balanced
        echo "Switching from powersave to automatic..."
        # set_tlp_profile "automatic"
        # For now, we'll simulate the toggle
        ;;
    "performance"|"balanced"|"automatic")
        # Switch to powersave
        echo "Switching to powersave..."
        # set_tlp_profile "powersave"
        ;;
    *)
        echo "Unknown current profile: $current"
        ;;
esac

# Send signal to waybar to update the module
pkill -RTMIN+7 waybar