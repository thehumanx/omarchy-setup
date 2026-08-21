#!/bin/bash
# Module: cursor — Afterglow dark cursor theme

install() {
  log_header "[Afterglow cursor]"

  local dst="$HOME/.local/share/icons"
  copy_dir "$CONFIGS_DIR/cursor/Afterglow-cursors" "$dst/Afterglow-cursors" || return 1

  # Activate the cursor theme (3 mechanisms)
  if check_cmd gsettings; then
    gsettings set org.gnome.desktop.interface cursor-theme "Afterglow-cursors" 2>/dev/null
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null
  fi
  if check_cmd hyprctl; then
    hyprctl setcursor "Afterglow-cursors" 24 2>/dev/null
  fi

  # Hyprland env vars — kept in THIS module so all cursor config is one step
  copy_file "$CONFIGS_DIR/cursor/cursor.lua" "$CONFIG_DIR/hypr/cursor.lua" || return 1

  log_success "Cursor activated: gsettings (GTK) + hyprctl (live) + Hyprland env vars"
}

uninstall() {
  log_header "[Afterglow cursor — remove]"

  restore_file "$HOME/.local/share/icons/Afterglow-cursors"
  restore_file "$CONFIG_DIR/hypr/cursor.lua"

  if check_cmd gsettings; then
    gsettings reset org.gnome.desktop.interface cursor-theme 2>/dev/null
    gsettings reset org.gnome.desktop.interface cursor-size 2>/dev/null
  fi
  if check_cmd hyprctl; then
    hyprctl setcursor "default" 24 2>/dev/null
  fi
  log_success "Cursor reset to system default"
}

description() {
  echo "Afterglow cursor — dark cursor theme for Hyprland + GTK"
}

details() {
  echo "All Afterglow cursor config in one step: installs the theme, activates"
  echo "it for Hyprland + GTK (gsettings + hyprctl), and sets the Hyprland env"
  echo "vars that make it persist across restarts."
  echo ""
  echo "Files:"
  file_row "ADD" "configs/cursor/Afterglow-cursors/" "$HOME/.local/share/icons/Afterglow-cursors/"
  file_row "ADD" "configs/cursor/cursor.lua" "$CONFIG_DIR/hypr/cursor.lua  (XCURSOR/HYPRCURSOR env vars)"
  info_row "Loaded via pcall in hyprland.lua — install the Hyprland module too."
}
