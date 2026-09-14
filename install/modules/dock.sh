#!/bin/bash
# Module: dock — Auto-hiding app dock (hover-to-reveal, pinning, all displays)

install() {
  log_header "[App dock]"

  local dst="$CONFIG_DIR/omarchy/plugins"
  mkdir -p "$dst"

  # Copy custom.dock plugin
  local dock_src="$CONFIGS_DIR/bar/plugins/custom.dock"
  if [[ -d "$dock_src" ]]; then
    rsync -a "$dock_src/" "$dst/custom.dock/" || return 1
    log_success "Installed: custom.dock plugin"
  else
    log_error "custom.dock plugin not found in configs/bar/plugins/"
    return 1
  fi

  # Inject dock config into shell.json (requires bar module's shell.json)
  local shell_json="$CONFIG_DIR/omarchy/shell.json"
  if [[ -f "$shell_json" ]]; then
    backup_file "$shell_json"
    python3 "$SETUP_DIR/install/dock-inject.py" "$shell_json" || return 1
  else
    log_warn "shell.json not found — install the bar module first."
    log_warn "Dock plugin copied, but it won't activate without the bar module."
  fi

  log_info "Restart the shell to see it: omarchy restart shell"
}

uninstall() {
  log_header "[App dock — remove]"

  # Remove custom.dock plugin
  local dock_dir="$CONFIG_DIR/omarchy/plugins/custom.dock"
  if [[ -d "$dock_dir" ]]; then
    rm -rf "$dock_dir"
    log_success "Removed: custom.dock plugin"
  fi

  # Remove dock config from shell.json
  local shell_json="$CONFIG_DIR/omarchy/shell.json"
  if [[ -f "$shell_json" ]] && check_cmd python3; then
    python3 -c "
import json, sys
path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
if 'plugins' in cfg:
    cfg['plugins'] = [p for p in cfg['plugins'] if p.get('id') != 'custom.dock']
with open(path, 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
print('  Removed custom.dock config from shell.json')
" "$shell_json" || return 1
  fi

  rm -f "$HOME/.local/state/omarchy/dock.json"
  log_info "Also removed saved dock state (position + pinned apps)."
}

description() {
  echo "App dock — auto-hiding, hover-to-reveal, pin apps, all displays"
}

details() {
  echo "An auto-hiding dock: shows every open window grouped by app, hidden"
  echo "by default, revealed on hover at the screen edge (bottom by default;"
  echo "right-click empty dock space to switch top/left/right). Right-click"
  echo "an icon for New Window / Close / Pin to Dock — pinned apps stay in"
  echo "the dock, and launch from it, even after every window closes."
  echo "Runs on every connected display independently."
  echo ""
  echo "Files:"
  file_row "ADD" "configs/bar/plugins/custom.dock/" "$CONFIG_DIR/omarchy/plugins/custom.dock/"
  file_row "PATCH" "(in place)" "$CONFIG_DIR/omarchy/shell.json  — adds custom.dock plugin"
  info_row "Position + pinned apps are saved separately to ~/.local/state/omarchy/dock.json"
  info_row "(not managed by this repo — it's per-machine state, not a config)."
  info_row "Requires the Custom bar module (needs its shell.json) to activate."
}
