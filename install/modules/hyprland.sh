#!/bin/bash
# Module: hyprland — Hyprland Lua configs (keybindings, input, look & feel, autostart, monitors)

HYPR_FILES=(hyprland.lua bindings.lua input.lua looknfeel.lua autostart.lua monitors.lua)

install() {
  log_header "[Hyprland config]"
  local dir="$CONFIGS_DIR/hypr"
  local dst="$CONFIG_DIR/hypr"
  mkdir -p "$dst"

  local rc=0
  for f in "${HYPR_FILES[@]}"; do
    backup_file "$dst/$f"
    copy_file "$dir/$f" "$dst/$f" || rc=1
  done

  (( rc == 0 )) && log_success "Installed: ${HYPR_FILES[*]}"
  return $rc
}

uninstall() {
  log_header "[Hyprland config — revert to stock]"

  for f in "${HYPR_FILES[@]}"; do
    restore_file "$CONFIG_DIR/hypr/$f"
  done

  log_info "Stock .lua files from /usr/share/omarchy are used after: hyprctl reload"
}

description() {
  echo "Hyprland config — keybindings, input, gaps, monitors, look & feel"
}

details() {
  echo "Custom keybindings (Q=close, L=menu, E=files, ;=emoji picker), natural"
  echo "scroll, 3-finger workspace swipe, tighter gaps (2/4), resize on border,"
  echo "wallpaper portal autostart, monitor layout. Also loads optional modules"
  echo "(cursor env vars, boot lock) via safe pcall requires."
  echo ""
  echo "Files:"
  file_row "OVERWRITE" "configs/hypr/hyprland.lua"   "$CONFIG_DIR/hypr/hyprland.lua"
  file_row "OVERWRITE" "configs/hypr/bindings.lua"   "$CONFIG_DIR/hypr/bindings.lua"
  file_row "OVERWRITE" "configs/hypr/input.lua"      "$CONFIG_DIR/hypr/input.lua"
  file_row "OVERWRITE" "configs/hypr/looknfeel.lua"  "$CONFIG_DIR/hypr/looknfeel.lua"
  file_row "OVERWRITE" "configs/hypr/autostart.lua"  "$CONFIG_DIR/hypr/autostart.lua"
  file_row "OVERWRITE" "configs/hypr/monitors.lua"   "$CONFIG_DIR/hypr/monitors.lua  (laptop + Dell U2520D above)"
  info_row "Each existing file is backed up (.pre-omarchy-setup) and restored on uninstall."
}
