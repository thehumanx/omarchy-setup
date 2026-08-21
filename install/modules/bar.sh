#!/bin/bash
# Module: bar — Custom bar (shell.json + shell.toml + custom.* bar widgets)
# All-or-nothing: shell.json references all bar widgets.

BAR_PLUGIN_COUNT=$(find "$CONFIGS_DIR/bar/plugins" -maxdepth 1 -name 'custom.*' -type d ! -name 'custom.lock' 2>/dev/null | wc -l)

install() {
  log_header "[Custom bar]"

  local dst="$CONFIG_DIR/omarchy"
  mkdir -p "$dst"

  backup_file "$dst/shell.json"
  backup_file "$dst/shell.toml"

  copy_file "$CONFIGS_DIR/bar/shell.json" "$dst/shell.json" || return 1
  copy_file "$CONFIGS_DIR/bar/shell.toml" "$dst/shell.toml" || return 1

  # Copy bar widget plugins (exclude custom.lock — handled by lock module)
  mkdir -p "$dst/plugins"
  rsync -a --exclude='custom.lock' "$CONFIGS_DIR/bar/plugins/" "$dst/plugins/" || return 1
  log_success "Installed: shell.json, shell.toml, $BAR_PLUGIN_COUNT bar widget plugins"
}

uninstall() {
  log_header "[Custom bar — revert to stock]"

  local plugins_dir="$CONFIG_DIR/omarchy/plugins"
  if [[ -d "$plugins_dir" ]]; then
    local custom_count
    custom_count=$(find "$plugins_dir" -maxdepth 1 -name 'custom.*' -type d | wc -l)
    if [[ $custom_count -gt 0 ]]; then
      find "$plugins_dir" -maxdepth 1 -name 'custom.*' -type d -exec rm -rf {} +
      log_success "Removed: $custom_count custom.* plugins"
    fi
  fi

  restore_file "$CONFIG_DIR/omarchy/shell.json"
  restore_file "$CONFIG_DIR/omarchy/shell.toml"

  if check_cmd omarchy; then
    omarchy bar reset 2>/dev/null && log_success "Bar reset to stock layout via omarchy bar reset"
  fi
}

description() {
  echo "Custom bar — $BAR_PLUGIN_COUNT boxed-pill widgets (workspaces, clock, weather, tray, agents, bluetooth, audio, network, memory, monitor, power, system-update)"
}

details() {
  echo "Replaces the stock Omarchy bar with a custom layout of $BAR_PLUGIN_COUNT"
  echo "boxed-pill widgets: workspaces, clock, weather, tray, agents, bluetooth,"
  echo "audio, network, memory, monitor, power, system-update."
  echo ""
  echo "Files:"
  file_row "OVERWRITE" "configs/bar/shell.json"  "$CONFIG_DIR/omarchy/shell.json"
  file_row "OVERWRITE" "configs/bar/shell.toml"  "$CONFIG_DIR/omarchy/shell.toml"
  for d in "$CONFIGS_DIR/bar/plugins"/custom.*; do
    [[ $(basename "$d") == "custom.lock" ]] && continue
    file_row "ADD" "$(basename "$d")/" "$CONFIG_DIR/omarchy/plugins/$(basename "$d")/"
  done
  info_row "Existing shell.json/shell.toml are backed up (.pre-omarchy-setup) for clean revert."
  info_row "Lock screen is a separate module."
}
