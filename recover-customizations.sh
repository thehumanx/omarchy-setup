#!/bin/bash

# Recovery script to restore customizations manually (useful if update breaks things)
# This is a manual version - automatic restore happens via ~/.config/omarchy/hooks/post-update

echo "🔧 Restoring customizations..."

OMARCHY_SETUP="$HOME/omarchy-setup"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/share/omarchy/bin"

# Restore hypr configs from omarchy-setup
echo "📁 Restoring configurations..."
[[ -f "$OMARCHY_SETUP/configs/hypr/autostart.conf" ]] && cp "$OMARCHY_SETUP/configs/hypr/autostart.conf" "$CONFIG_DIR/hypr/" && echo "✅ autostart.conf"
[[ -f "$OMARCHY_SETUP/configs/hypr/bindings.conf" ]] && cp "$OMARCHY_SETUP/configs/hypr/bindings.conf" "$CONFIG_DIR/hypr/" && echo "✅ bindings.conf"
[[ -f "$OMARCHY_SETUP/configs/hypr/hypridle.conf" ]] && cp "$OMARCHY_SETUP/configs/hypr/hypridle.conf" "$CONFIG_DIR/hypr/" && echo "✅ hypridle.conf"
[[ -f "$OMARCHY_SETUP/configs/hypr/hyprlock.conf" ]] && cp "$OMARCHY_SETUP/configs/hypr/hyprlock.conf" "$CONFIG_DIR/hypr/" && echo "✅ hyprlock.conf"

# Restore system-tweaks
echo "⚡ Restoring system-tweaks..."
if [[ -d "$OMARCHY_SETUP/configs/system-tweaks" ]]; then
    mkdir -p "$CONFIG_DIR/system-tweaks"
    cp "$OMARCHY_SETUP/configs/system-tweaks/"* "$CONFIG_DIR/system-tweaks/"
    echo "✅ system-tweaks restored"
fi

# Restore omarchy extensions
echo "📝 Restoring menu extensions..."
if [[ -f "$OMARCHY_SETUP/configs/omarchy/extensions/menu.sh" ]]; then
    mkdir -p "$CONFIG_DIR/omarchy/extensions"
    cp "$OMARCHY_SETUP/configs/omarchy/extensions/menu.sh" "$CONFIG_DIR/omarchy/extensions/"
    echo "✅ menu extensions restored"
fi

# Restore custom hypr scripts
echo "🔧 Restoring custom scripts..."
if [[ -d "$OMARCHY_SETUP/configs/hypr/scripts" ]]; then
    mkdir -p "$CONFIG_DIR/hypr/scripts"
    cp "$OMARCHY_SETUP/configs/hypr/scripts/"* "$CONFIG_DIR/hypr/scripts/"
    echo "✅ hypr scripts restored"
fi

[[ -f "$OMARCHY_SETUP/configs/hypr/custom-screensaver-launch.sh" ]] && cp "$OMARCHY_SETUP/configs/hypr/custom-screensaver-launch.sh" "$CONFIG_DIR/hypr/" && echo "✅ screensaver launcher"
[[ -f "$OMARCHY_SETUP/configs/hypr/screensaver-script.sh" ]] && cp "$OMARCHY_SETUP/configs/hypr/screensaver-script.sh" "$CONFIG_DIR/hypr/" && echo "✅ screensaver script"

echo ""
echo "✅ Recovery complete!"
echo "You may need to restart Hyprland: Super + Shift + R"
