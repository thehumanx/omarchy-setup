#!/bin/bash
# Module: boot-lock — show the lock screen immediately at boot (password on login)

install() {
  log_header "[Lock screen at boot]"

  local dst="$CONFIG_DIR/hypr"
  mkdir -p "$dst"
  copy_file "$CONFIGS_DIR/boot-lock/bootlock.lua" "$dst/bootlock.lua" || return 1

  log_success "Installed: session locks the moment Hyprland starts"
  log_info "SDDM keeps autologging you in; the lock screen covers the session instantly."
  log_info "Requires the hyprland module's pcall loader (or add it manually) to activate."
}

uninstall() {
  log_header "[Lock screen at boot — remove]"

  restore_file "$CONFIG_DIR/hypr/bootlock.lua"
  log_info "Boot returns to plain autologin straight into the desktop."
}

description() {
  echo "Lock screen at boot — password prompt right after autologin (no delay)"
}

details() {
  echo "You autologin via SDDM as today, but the custom lock screen is thrown"
  echo "over the session the instant Hyprland starts — so every boot ends at"
  echo "your password prompt instead of an open desktop. No extra delay."
  echo ""
  echo "Files:"
  file_row "ADD" "configs/boot-lock/bootlock.lua" "$CONFIG_DIR/hypr/bootlock.lua"
  info_row "Runs: omarchy-shell lock lock (same path as Super+Esc manual lock)."
  info_row "Pairs with the Lock screen module for visuals; works with stock lock too."
  info_row "Needs the hyprland module installed (it loads this file via pcall)."
}
