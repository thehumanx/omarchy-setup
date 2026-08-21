#!/bin/bash
# Module: wallpaper-pipeline — Nautilus "Set as Background" → auto theme generation

install() {
  log_header "[Wallpaper → theme pipeline]"

  # Check dependencies
  local missing=""
  if ! check_pkg python-dbus; then missing="$missing python-dbus"; fi
  if ! check_pkg python-gobject; then missing="$missing python-gobject"; fi
  if [[ -n "$missing" ]]; then
    log_warn "Missing dependencies:$missing"
    log_warn "Install with: sudo pacman -S$missing"
    echo ""
  fi

  local rc=0
  copy_file "$CONFIGS_DIR/wallpaper/wallpaper-portal.py" \
            "$CONFIG_DIR/omarchy/wallpaper-portal.py" || rc=1
  copy_file "$CONFIGS_DIR/wallpaper/wallpaper-to-theme" \
            "$CONFIG_DIR/omarchy/wallpaper-to-theme" || rc=1
  chmod +x "$CONFIG_DIR/omarchy/wallpaper-to-theme"

  # Portal registration
  local portal_dst="$HOME/.local/share/xdg-desktop-portal/portals"
  copy_file "$CONFIGS_DIR/portal/omarchy.portal" "$portal_dst/omarchy.portal" || rc=1

  # Portal routing config
  backup_file "$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf"
  copy_file "$CONFIGS_DIR/portal/hyprland-portals.conf" \
            "$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf" || rc=1

  (( rc == 0 )) && log_success "Installed: wallpaper portal + theme generation pipeline"
  return $rc
}

uninstall() {
  log_header "[Wallpaper → theme pipeline — remove]"

  restore_file "$CONFIG_DIR/omarchy/wallpaper-portal.py"
  restore_file "$CONFIG_DIR/omarchy/wallpaper-to-theme"
  restore_file "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal"
  restore_file "$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf"

  log_info "Nautilus \"Set as Background\" will no longer auto-generate themes."
}

description() {
  echo "Wallpaper → theme — Nautilus \"Set as Background\" auto-generates theme"
}

details() {
  echo "Makes Nautilus \"Set as Background\" work on Hyprland: a D-Bus wallpaper"
  echo "portal catches the request and a theme generator recolors the whole"
  echo "system (borders, bar, terminals, btop, browser accent) from the image."
  echo ""
  echo "Files:"
  file_row "ADD" "configs/wallpaper/wallpaper-portal.py"     "$CONFIG_DIR/omarchy/wallpaper-portal.py"
  file_row "ADD" "configs/wallpaper/wallpaper-to-theme"      "$CONFIG_DIR/omarchy/wallpaper-to-theme"
  file_row "ADD" "configs/portal/omarchy.portal"             "$HOME/.local/share/xdg-desktop-portal/portals/omarchy.portal"
  file_row "OVERWRITE" "configs/portal/hyprland-portals.conf" "$CONFIG_DIR/xdg-desktop-portal/hyprland-portals.conf"
  info_row "Requires packages: python-dbus, python-gobject (checked during install)."
}
