#!/bin/bash
# Force shutdown - kills all apps immediately without waiting

# Clear any restart required state
omarchy-state clear re*-required 2>/dev/null || true

# Kill all user processes forcefully except essential ones
# Get all user processes and filter out essential system processes
ps -u "$USER" -o pid=,comm= | while read pid comm; do
  case "$comm" in
    systemd|dbus*|pipewire|pipewire-*|wireplumber|login|bash|sh|Hyprland|hyprland)
      : # Skip essential processes including Hyprland
      ;;
    *)
      kill -9 "$pid" 2>/dev/null || true
      ;;
  esac
done

# Wait a moment for apps to die
sleep 0.5

# Force poweroff immediately
systemctl poweroff -f --no-wall
