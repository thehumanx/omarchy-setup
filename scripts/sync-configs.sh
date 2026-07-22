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

log_success "All configurations synced!"
echo
echo "Next: cd ~/omarchy-setup && git add -A && git commit -m 'Update configs' && git push"
