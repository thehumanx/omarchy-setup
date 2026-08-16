#!/bin/bash

# Manual recovery script to restore customizations onto an Omarchy 4 machine.
# Useful after `omarchy refresh`, or when setting up on a new system.

set -uo pipefail

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
    cp -r "$src"/* "$dst/" 2>/dev/null || true
    echo "  Restored: $dst/"
  fi
}

restore_tree() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    rsync -a "$src"/ "$dst"/
    echo "  Restored: $dst/"
  fi
}

# Hyprland (Omarchy 4 — Lua overrides)
echo "== Hyprland (Lua) =="
restore_config "$SETUP_DIR/configs/hypr/bindings.lua"    "$CONFIG_DIR/hypr/bindings.lua"
restore_config "$SETUP_DIR/configs/hypr/input.lua"       "$CONFIG_DIR/hypr/input.lua"
restore_config "$SETUP_DIR/configs/hypr/looknfeel.lua"   "$CONFIG_DIR/hypr/looknfeel.lua"
restore_config "$SETUP_DIR/configs/hypr/autostart.lua"   "$CONFIG_DIR/hypr/autostart.lua"

# Omarchy shell (Omarchy 4 — bar layout, style tokens, custom widgets/lock screen)
echo "== Omarchy shell =="
restore_config "$SETUP_DIR/configs/omarchy/shell.json"   "$CONFIG_DIR/omarchy/shell.json"
restore_config "$SETUP_DIR/configs/omarchy/shell.toml"   "$CONFIG_DIR/omarchy/shell.toml"
restore_tree   "$SETUP_DIR/configs/omarchy/plugins"      "$CONFIG_DIR/omarchy/plugins"

# Wallpaper portal backend (Nautilus "Set as Background" → aether theme generation)
echo "== Wallpaper portal =="
restore_config "$SETUP_DIR/configs/omarchy/wallpaper-portal.py"   "$CONFIG_DIR/omarchy/wallpaper-portal.py"
restore_config "$SETUP_DIR/configs/omarchy/wallpaper-to-theme"    "$CONFIG_DIR/omarchy/wallpaper-to-theme"
restore_config "$SETUP_DIR/configs/.local/share/xdg-desktop-portal/portals/omarchy.portal" \
               "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal"
restore_config "$SETUP_DIR/configs/xdg-desktop-portal/hyprland-portals.conf" \
               "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"

# Omarchy custom modules
echo "== Omarchy customizations =="
restore_dir "$SETUP_DIR/configs/omarchy/branding"           "$CONFIG_DIR/omarchy/branding"
restore_dir "$SETUP_DIR/configs/omarchy/extensions"          "$CONFIG_DIR/omarchy/extensions"
restore_dir "$SETUP_DIR/configs/omarchy/hooks"                "$CONFIG_DIR/omarchy/hooks"
restore_config "$SETUP_DIR/configs/omarchy/bluetooth-state.sh" "$CONFIG_DIR/omarchy/bluetooth-state.sh"

# Helper scripts
echo "== Helper scripts =="
restore_config "$SETUP_DIR/configs/.local/bin/border-from-wallpaper" "$HOME/.local/bin/border-from-wallpaper"
restore_config "$SETUP_DIR/configs/local-bin/sot-daemon"             "$HOME/.local/bin/sot-daemon"

# Omarchy bin overrides (survive omarchy update via post-update hook)
echo "== Omarchy bin overrides =="
restore_config "$SETUP_DIR/configs/omarchy/bin/omarchy-launch-webapp"       "$HOME/.local/share/omarchy/bin/omarchy-launch-webapp"
restore_config "$SETUP_DIR/configs/omarchy/bin/omarchy-brightness-display"  "$HOME/.local/share/omarchy/bin/omarchy-brightness-display"

# Systemd user services
echo "== Systemd user services =="
restore_config "$SETUP_DIR/configs/systemd/user/sot-daemon.service"  "$HOME/.config/systemd/user/sot-daemon.service"

# Cursor theme
echo "== Cursor theme =="
restore_dir "$SETUP_DIR/configs/icons/Afterglow-cursors"        "$HOME/.local/share/icons/Afterglow-cursors"
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface cursor-theme "Afterglow-cursors" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
fi
if command -v hyprctl &>/dev/null; then
  hyprctl setcursor "Afterglow-cursors" 24 2>/dev/null || true
fi

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

# Post-update hook — install via Omarchy's own hook mechanism, not a raw copy
echo "== Post-update hook =="
if command -v omarchy-hook-install &>/dev/null && [[ -f "$SETUP_DIR/restore-customizations.hook" ]]; then
  omarchy-hook-install post-update "$SETUP_DIR/restore-customizations.hook"
fi

# Make scripts executable
chmod +x "$CONFIG_DIR/omarchy/wallpaper-to-theme" 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/bluetooth-state.sh" 2>/dev/null || true
chmod +x "$CONFIG_DIR/omarchy/hooks/theme-set.d/"* 2>/dev/null || true
chmod +x "$HOME/.local/bin/border-from-wallpaper" 2>/dev/null || true
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
echo "Run 'hyprctl reload && hyprctl configerrors' to apply + validate Hyprland changes."
echo "Run 'omarchy restart shell' to apply bar/lock-screen changes."
