#!/bin/bash

# Recovery script to restore customizations after an update breaks things
echo "🔧 Restoring customizations..."

OMARCHY_SETUP="$HOME/omarchy-setup"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/share/omarchy/bin"

# Restore configs from omarchy-setup
echo "📁 Restoring configurations..."
cp "$OMARCHY_SETUP/configs/hypr/autostart.conf" "$CONFIG_DIR/hypr/" 2>/dev/null || echo "autostart.conf not found"
cp "$OMARCHY_SETUP/configs/hypr/bindings.conf" "$CONFIG_DIR/hypr/" 2>/dev/null || echo "bindings.conf not found"
cp "$OMARCHY_SETUP/configs/hypr/hypridle.conf" "$CONFIG_DIR/hypr/" 2>/dev/null || echo "hypridle.conf not found"
cp "$OMARCHY_SETUP/configs/hypr/hyprlock.conf" "$CONFIG_DIR/hypr/" 2>/dev/null || echo "hyprlock.conf not found"

# Restore scripts if backup exists
if [[ -f "$OMARCHY_SETUP/backup-scripts/omarchy-launch-screensaver" ]]; then
    echo "📋 Restoring custom screensaver script..."
    cp "$OMARCHY_SETUP/backup-scripts/omarchy-launch-screensaver" "$LOCAL_BIN/"
fi

echo "✅ Recovery complete! You may need to restart Hyprland: Super + Shift + R"