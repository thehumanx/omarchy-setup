#!/bin/bash

# sync-configs.sh - Sync actual config files to omarchy-setup repo

set -euo pipefail

REPO_DIR="$HOME/omarchy-setup"
CONFIG_DIR="$HOME/.config"
SOURCE_DIR="$REPO_DIR/configs"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}  $1${NC}"; }
log_success() { echo -e "${GREEN}  $1${NC}"; }
log_warning() { echo -e "${YELLOW}  $1${NC}"; }

rsync_config() {
  local app_name="$1"
  local src="$CONFIG_DIR/$app_name"
  local dst="$SOURCE_DIR/$app_name"

  if [[ -d "$src" ]]; then
    log_info "Syncing $app_name..."
    rm -rf "$dst"
    mkdir -p "$dst"
    rsync -a --exclude='.git' --exclude='*.bak.*' --exclude='cache' --exclude='__pycache__' "$src/" "$dst/"
    log_success "Synced $app_name"
  else
    log_warning "$app_name not found, skipping"
  fi
}

sync_file() {
  local app_name="$1"
  local file="$2"
  local src="$CONFIG_DIR/$file"
  local dst="$SOURCE_DIR/$app_name"

  if [[ -f "$src" ]]; then
    mkdir -p "$dst"
    cp "$src" "$dst/"
    log_success "Synced $file"
  else
    log_warning "$file not found, skipping"
  fi
}

mkdir -p "$SOURCE_DIR"

rsync_config "hypr"
rsync_config "waybar"
rsync_config "system-tweaks"
rsync_config "swayosd"
rsync_config "mako"
sync_file "opencode" "opencode/opencode.json"

# Sync omarchy customizations (not theme files, just custom additions)
mkdir -p "$SOURCE_DIR/omarchy"
cp -r "$CONFIG_DIR/omarchy/bluetooth-state.sh"    "$SOURCE_DIR/omarchy/" 2>/dev/null || true
cp -r "$CONFIG_DIR/omarchy/power-mode"            "$SOURCE_DIR/omarchy/" 2>/dev/null || true
cp -r "$CONFIG_DIR/omarchy/branding"              "$SOURCE_DIR/omarchy/" 2>/dev/null || true
cp -r "$CONFIG_DIR/omarchy/extensions"            "$SOURCE_DIR/omarchy/" 2>/dev/null || true
cp -r "$CONFIG_DIR/omarchy/hooks"                 "$SOURCE_DIR/omarchy/" 2>/dev/null || true

# Sync helper scripts in ~/.local/bin
mkdir -p "$SOURCE_DIR/.local/bin"
for script in border-from-wallpaper wallpaper-to-theme; do
  if [[ -f "$HOME/.local/bin/$script" ]]; then
    cp "$HOME/.local/bin/$script" "$SOURCE_DIR/.local/bin/$script"
    chmod +x "$SOURCE_DIR/.local/bin/$script"
    log_success "Synced .local/bin/$script"
  fi
done

# Sync wallpaper portal backend
if [[ -f "$HOME/.config/omarchy/wallpaper-portal.py" ]]; then
  cp "$HOME/.config/omarchy/wallpaper-portal.py" "$SOURCE_DIR/omarchy/wallpaper-portal.py"
  log_success "Synced omarchy/wallpaper-portal.py"
fi

# Sync xdg-desktop-portal configs (Nautilus wallpaper portal routing)
mkdir -p "$SOURCE_DIR/.local/share/xdg-desktop-portal/portals"
if [[ -f "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal" ]]; then
  cp "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal" \
     "$SOURCE_DIR/.local/share/xdg-desktop-portal/portals/omarchy.portal"
  log_success "Synced xdg-desktop-portal omarchy.portal"
fi
mkdir -p "$SOURCE_DIR/xdg-desktop-portal"
if [[ -f "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" ]]; then
  cp "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" \
     "$SOURCE_DIR/xdg-desktop-portal/hyprland-portals.conf"
  log_success "Synced xdg-desktop-portal/hyprland-portals.conf"
fi

log_success "All configurations synced!"
echo
echo "Next: cd ~/omarchy-setup && git add -A && git commit -m 'Update configs' && git push"
