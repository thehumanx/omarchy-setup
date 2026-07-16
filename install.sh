#!/bin/bash

# Install customizations from omarchy-setup to ~/.config/
# Usage: ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Dependencies check
MISSING=""
check_cmd() { command -v "$1" &>/dev/null || MISSING="$MISSING  $1\n"; }
check_pkg() { pacman -Qi "$1" &>/dev/null 2>&1 || MISSING="$MISSING  $1\n"; }

check_cmd tlp
check_cmd upower
check_cmd bc
check_cmd playerctl
check_cmd makoctl
check_cmd pamixer
check_cmd notify-send
check_cmd jq
check_cmd bluetoothctl
check_cmd lpstat

if [[ -n "$MISSING" ]]; then
  echo "--- Missing dependencies ---"
  printf "$MISSING"
  echo "Install them with: sudo pacman -S tlp upower bc playerctl mako pamixer libnotify jq bluez bluez-utils cups"
  echo ""
fi

# Check sudo access for tlp
if command -v tlp &>/dev/null && ! sudo -n tlp start 2>/dev/null; then
  echo "⚠️  Passwordless sudo for 'tlp' is recommended for power-mode toggle."
  echo "   Add: $USER ALL=(ALL) NOPASSWD: /usr/bin/tlp"
  echo "   To:  /etc/sudoers.d/tlp"
fi

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
cp -r "$REPO_DIR/configs/omarchy/branding" "$CONFIG_DIR/omarchy/" 2>/dev/null || true
cp -r "$REPO_DIR/configs/omarchy/extensions" "$CONFIG_DIR/omarchy/" 2>/dev/null || true
echo "  Installed: omarchy/"

# Copy cursor theme
if [[ -d "$REPO_DIR/configs/icons/Afterglow-cursors" ]]; then
  mkdir -p "$HOME/.local/share/icons"
  cp -r "$REPO_DIR/configs/icons/Afterglow-cursors" "$HOME/.local/share/icons/"
  echo "  Installed: icons/Afterglow-cursors"
fi

# Copy system-tweaks
cp -r "$REPO_DIR/configs/system-tweaks" "$CONFIG_DIR/"
echo "  Installed: system-tweaks/"

# Install systemd service for WiFi power save after wake
if [[ -f "$REPO_DIR/configs/system-tweaks/disable-wifi-powersave-wake.service" ]]; then
  sudo cp "$REPO_DIR/configs/system-tweaks/disable-wifi-powersave-wake.service" /etc/systemd/system/
  sudo systemctl enable disable-wifi-powersave-wake.service
  echo "  Installed: disable-wifi-powersave-wake.service"
fi

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
