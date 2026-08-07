#!/bin/bash

# Manual recovery script to restore customizations
# This is useful if omarchy refresh resets configs or if setting up on a new system

set -euo pipefail

SETUP_DIR="$HOME/omarchy-setup"
CONFIG_DIR="$HOME/.config"

echo "--- Restoring customizations ---"

restore_config() {
  local src="$1"
  local dst="$2"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  Restored: $dst"
  fi
}

restore_dir() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    cp -r "$src"/* "$dst/"
    echo "  Restored: $dst/"
  fi
}

# Hyprland
echo "== Hyprland configs =="
restore_config "$SETUP_DIR/configs/hypr/autostart.conf"     "$CONFIG_DIR/hypr/autostart.conf"
restore_config "$SETUP_DIR/configs/hypr/bindings.conf"      "$CONFIG_DIR/hypr/bindings.conf"
restore_config "$SETUP_DIR/configs/hypr/hypridle.conf"      "$CONFIG_DIR/hypr/hypridle.conf"
restore_config "$SETUP_DIR/configs/hypr/hyprland.conf"      "$CONFIG_DIR/hypr/hyprland.conf"
restore_config "$SETUP_DIR/configs/hypr/hyprlock.conf"      "$CONFIG_DIR/hypr/hyprlock.conf"
restore_config "$SETUP_DIR/configs/hypr/input.conf"         "$CONFIG_DIR/hypr/input.conf"
restore_config "$SETUP_DIR/configs/hypr/looknfeel.conf"     "$CONFIG_DIR/hypr/looknfeel.conf"
restore_config "$SETUP_DIR/configs/hypr/monitors.conf"      "$CONFIG_DIR/hypr/monitors.conf"
restore_config "$SETUP_DIR/configs/hypr/border-colors.conf" "$CONFIG_DIR/hypr/border-colors.conf"
restore_dir  "$SETUP_DIR/configs/hypr/scripts"              "$CONFIG_DIR/hypr/scripts"

# Waybar
echo "== Waybar =="
restore_config "$SETUP_DIR/configs/waybar/config.jsonc"     "$CONFIG_DIR/waybar/config.jsonc"
restore_config "$SETUP_DIR/configs/waybar/style.css"        "$CONFIG_DIR/waybar/style.css"
restore_config "$SETUP_DIR/configs/waybar/dynamic.css"      "$CONFIG_DIR/waybar/dynamic.css"
restore_dir "$SETUP_DIR/configs/waybar/indicators"          "$CONFIG_DIR/waybar/indicators"

# Omarchy custom modules
echo "== Omarchy customizations =="
restore_dir "$SETUP_DIR/configs/omarchy/power-mode"         "$CONFIG_DIR/omarchy/power-mode"
restore_dir "$SETUP_DIR/configs/omarchy/branding"           "$CONFIG_DIR/omarchy/branding"
restore_dir "$SETUP_DIR/configs/omarchy/extensions"         "$CONFIG_DIR/omarchy/extensions"
restore_dir "$SETUP_DIR/configs/omarchy/hooks"              "$CONFIG_DIR/omarchy/hooks"
restore_config "$SETUP_DIR/configs/omarchy/bluetooth-state.sh" "$CONFIG_DIR/omarchy/bluetooth-state.sh"

# Helper scripts
echo "== Helper scripts =="
restore_config "$SETUP_DIR/configs/.local/bin/border-from-wallpaper" "$HOME/.local/bin/border-from-wallpaper"
restore_config "$SETUP_DIR/configs/.local/bin/wallpaper-to-theme"    "$HOME/.local/bin/wallpaper-to-theme"
restore_config "$SETUP_DIR/configs/.local/bin/sot-daemon"            "$HOME/.local/bin/sot-daemon"

# Omarchy bin overrides (survive omarchy update via post-update hook)
echo "== Omarchy bin overrides =="
restore_config "$SETUP_DIR/configs/omarchy/bin/omarchy-launch-webapp"       "$HOME/.local/share/omarchy/bin/omarchy-launch-webapp"
restore_config "$SETUP_DIR/configs/omarchy/bin/omarchy-brightness-display"  "$HOME/.local/share/omarchy/bin/omarchy-brightness-display"

# Systemd user services
echo "== Systemd user services =="
restore_config "$SETUP_DIR/configs/systemd/user/sot-daemon.service"  "$HOME/.config/systemd/user/sot-daemon.service"

# Wallpaper portal backend (Nautilus "Set as Background" → aether theme generation)
echo "== Wallpaper portal =="
restore_config "$SETUP_DIR/configs/omarchy/wallpaper-portal.py"      "$HOME/.config/omarchy/wallpaper-portal.py"
restore_config "$SETUP_DIR/configs/.local/share/xdg-desktop-portal/portals/omarchy.portal" \
               "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal"
restore_config "$SETUP_DIR/configs/xdg-desktop-portal/hyprland-portals.conf" \
               "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"

# Cursor theme
echo "== Cursor theme =="
restore_dir "$SETUP_DIR/configs/icons/Afterglow-cursors"        "$HOME/.local/share/icons/Afterglow-cursors"

# System-tweaks
echo "== System tweaks =="
restore_dir "$SETUP_DIR/configs/system-tweaks"              "$CONFIG_DIR/system-tweaks"

# OpenCode config
echo "== OpenCode =="
restore_config "$SETUP_DIR/configs/opencode/opencode.json"  "$CONFIG_DIR/opencode/opencode.json"

# System-level sleep hook (requires sudo)
echo "== System sleep hook =="
if [[ -f "$SETUP_DIR/configs/system-sleep/sot-hook.sh" ]]; then
  echo "  NOTE: sot-hook.sh requires sudo to install:"
  echo "  sudo cp $SETUP_DIR/configs/system-sleep/sot-hook.sh /etc/systemd/system-sleep/"
  echo "  sudo chmod +x /etc/systemd/system-sleep/sot-hook.sh"
fi

# Make scripts executable
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/hypr/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/power-mode/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/bluetooth-state.sh" 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/hooks/theme-set.d/"* 2>/dev/null || true
chmod +x "$HOME/.local/bin/border-from-wallpaper" 2>/dev/null || true
chmod +x "$HOME/.local/bin/wallpaper-to-theme" 2>/dev/null || true
chmod +x "$HOME/.local/bin/sot-daemon" 2>/dev/null || true
chmod +x "$HOME/.local/share/omarchy/bin/omarchy-launch-webapp" 2>/dev/null || true
chmod +x "$HOME/.local/share/omarchy/bin/omarchy-brightness-display" 2>/dev/null || true

# Reload and restart sot-daemon if systemd is available
if command -v systemctl &>/dev/null; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now sot-daemon.service 2>/dev/null || true
fi

echo ""
echo "--- Done ---"
echo "Run 'hyprctl reload' to apply hyprland changes."
echo "Run 'omarchy restart waybar' to apply waybar changes."
