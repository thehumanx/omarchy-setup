#!/bin/bash

# Install customizations from omarchy-setup to ~/.config/
# Usage: ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "--- Installing omarchy-setup customizations ---"

# Copy hypr configs
cp -r "$REPO_DIR/configs/hypr" "$CONFIG_DIR/"
echo "  Installed: hypr/"

# Copy waybar configs
cp -r "$REPO_DIR/configs/waybar" "$CONFIG_DIR/"
echo "  Installed: waybar/"

# Copy omarchy custom modules
mkdir -p "$CONFIG_DIR/omarchy"
cp "$REPO_DIR/configs/omarchy/bluetooth-state.sh" "$CONFIG_DIR/omarchy/"
cp -r "$REPO_DIR/configs/omarchy/power-mode" "$CONFIG_DIR/omarchy/"
echo "  Installed: omarchy/"

# Copy system-tweaks
cp -r "$REPO_DIR/configs/system-tweaks" "$CONFIG_DIR/"
echo "  Installed: system-tweaks/"

# Install post-update hook
mkdir -p "$CONFIG_DIR/omarchy/hooks"
cp "$REPO_DIR/post-update" "$CONFIG_DIR/omarchy/hooks/"
chmod +x "$CONFIG_DIR/omarchy/hooks/post-update"
echo "  Installed: omarchy/hooks/post-update"

# Make scripts executable
chmod +x "$CONFIG_DIR/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/hypr/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/power-mode/"*.sh 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/bluetooth-state.sh" 2>/dev/null || true

echo "--- Done ---"
echo "Run 'hyprctl reload' and 'omarchy restart waybar' to apply."
