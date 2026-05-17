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
restore_dir  "$SETUP_DIR/configs/hypr/scripts"              "$CONFIG_DIR/hypr/scripts"

# Waybar
echo "== Waybar =="
restore_config "$SETUP_DIR/configs/waybar/config.jsonc"     "$CONFIG_DIR/waybar/config.jsonc"
restore_config "$SETUP_DIR/configs/waybar/style.css"        "$CONFIG_DIR/waybar/style.css"
restore_dir "$SETUP_DIR/configs/waybar/indicators"          "$CONFIG_DIR/waybar/indicators"

# Omarchy custom modules
echo "== Omarchy customizations =="
restore_dir "$SETUP_DIR/configs/omarchy/power-mode"         "$CONFIG_DIR/omarchy/power-mode"
restore_dir "$SETUP_DIR/configs/omarchy/branding"           "$CONFIG_DIR/omarchy/branding"
restore_dir "$SETUP_DIR/configs/omarchy/extensions"         "$CONFIG_DIR/omarchy/extensions"
restore_config "$SETUP_DIR/configs/omarchy/bluetooth-state.sh" "$CONFIG_DIR/omarchy/bluetooth-state.sh"

# Cursor theme
echo "== Cursor theme =="
restore_dir "$SETUP_DIR/configs/icons/Afterglow-cursors"        "$HOME/.local/share/icons/Afterglow-cursors"

# System-tweaks
echo "== System tweaks =="
restore_dir "$SETUP_DIR/configs/system-tweaks"              "$CONFIG_DIR/system-tweaks"

# Make scripts executable
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/hypr/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/power-mode/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/bluetooth-state.sh" 2>/dev/null || true

echo ""
echo "--- Done ---"
echo "Run 'hyprctl reload' to apply hyprland changes."
echo "Run 'omarchy restart waybar' to apply waybar changes."
