#!/bin/bash
# sync-configs.sh — Pull live configs back into omarchy-configs repo.

set -euo pipefail

REPO_DIR="$HOME/omarchy-configs"
CONFIG_DIR="$HOME/.config"
SOURCE_DIR="$REPO_DIR/configs"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}  $1${NC}"; }
log_success() { echo -e "${GREEN}  $1${NC}"; }
log_warning() { echo -e "${YELLOW}  $1${NC}"; }

mkdir -p "$SOURCE_DIR"

# ── Hyprland (.lua only) ──────────────────────────────────────────────
log_info "Syncing hypr (.lua only)..."
rm -rf "$SOURCE_DIR/hypr"
mkdir -p "$SOURCE_DIR/hypr"
rsync -a --include='*.lua' --include='*.json' --exclude='*' \
  "$CONFIG_DIR/hypr/" "$SOURCE_DIR/hypr/"
log_success "Synced hypr"

# ── Bar ───────────────────────────────────────────────────────────────
if [[ -d "$CONFIG_DIR/omarchy" ]]; then
  for f in shell.json shell.toml; do
    if [[ -f "$CONFIG_DIR/omarchy/$f" ]]; then
      cp "$CONFIG_DIR/omarchy/$f" "$SOURCE_DIR/bar/$f"
      log_success "Synced bar/$f"
    fi
  done
  if [[ -d "$CONFIG_DIR/omarchy/plugins" ]]; then
    log_info "Syncing bar/plugins..."
    mkdir -p "$SOURCE_DIR/bar/plugins"
    rsync -a --delete --exclude='.*' "$CONFIG_DIR/omarchy/plugins/" "$SOURCE_DIR/bar/plugins/"
    log_success "Synced bar/plugins"
  fi
fi

# ── Wallpaper pipeline ────────────────────────────────────────────────
if [[ -f "$CONFIG_DIR/omarchy/wallpaper-portal.py" ]]; then
  cp "$CONFIG_DIR/omarchy/wallpaper-portal.py" "$SOURCE_DIR/wallpaper/wallpaper-portal.py"
  log_success "Synced wallpaper/wallpaper-portal.py"
fi
if [[ -f "$CONFIG_DIR/omarchy/wallpaper-to-theme" ]]; then
  cp "$CONFIG_DIR/omarchy/wallpaper-to-theme" "$SOURCE_DIR/wallpaper/wallpaper-to-theme"
  chmod +x "$SOURCE_DIR/wallpaper/wallpaper-to-theme"
  log_success "Synced wallpaper/wallpaper-to-theme"
fi
if [[ -f "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal" ]]; then
  cp "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal" "$SOURCE_DIR/portal/omarchy.portal"
  log_success "Synced portal/omarchy.portal"
fi
if [[ -f "$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf" ]]; then
  cp "$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf" "$SOURCE_DIR/portal/hyprland-portals.conf"
  log_success "Synced portal/hyprland-portals.conf"
fi

# ── Cursor ────────────────────────────────────────────────────────────
if [[ -d "$HOME/.local/share/icons/Afterglow-cursors" ]]; then
  log_info "Syncing cursor theme..."
  mkdir -p "$SOURCE_DIR/cursor"
  rsync -a --delete "$HOME/.local/share/icons/Afterglow-cursors/" "$SOURCE_DIR/cursor/Afterglow-cursors/"
  log_success "Synced cursor/Afterglow-cursors"
fi

# ── Bin overrides ─────────────────────────────────────────────────────
for script in omarchy-launch-webapp omarchy-brightness-display omarchy-capture-screenshot; do
  if [[ -f "$HOME/.local/share/omarchy/bin/$script" ]]; then
    cp "$HOME/.local/share/omarchy/bin/$script" "$SOURCE_DIR/bin/$script"
    chmod +x "$SOURCE_DIR/bin/$script"
    log_success "Synced bin/$script"
  fi
done

# ── Branding (only if user has customized) ────────────────────────────
if [[ -f "$CONFIG_DIR/omarchy/branding/about.txt" ]]; then
  cp "$CONFIG_DIR/omarchy/branding/about.txt" "$SOURCE_DIR/branding/about.txt"
  log_success "Synced branding/about.txt"
fi
if [[ -f "$CONFIG_DIR/omarchy/branding/screensaver.txt" ]]; then
  cp "$CONFIG_DIR/omarchy/branding/screensaver.txt" "$SOURCE_DIR/branding/screensaver.txt"
  log_success "Synced branding/screensaver.txt"
fi

log_success "All configurations synced!"
echo
echo "Next: cd ~/omarchy-configs && git add -A && git commit -m 'Update configs' && git push"
