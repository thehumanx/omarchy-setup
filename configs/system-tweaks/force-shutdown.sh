#!/bin/bash
# Force shutdown - kills all apps immediately without waiting
# Place in ~/.config/omarchy/system-tweaks/force-shutdown.sh

# Clear any restart required state
omarchy-state clear re*-required 2>/dev/null || true

# Kill all user processes forcefully except essential ones
pkill -9 -u "$USER" -x "^(?!systemd|dbus|pipewire|wireplumber).*" 2>/dev/null || true

# Force poweroff immediately
systemctl poweroff -f --no-wall
