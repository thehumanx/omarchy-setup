#!/bin/bash
# Module: lock — Restyled lock screen (time/date/battery centered, password hidden)

install() {
  log_header "[Lock screen — restyled]"

  local dst="$CONFIG_DIR/omarchy/plugins"
  mkdir -p "$dst"

  # Copy custom.lock plugin
  local lock_src="$CONFIGS_DIR/bar/plugins/custom.lock"
  if [[ -d "$lock_src" ]]; then
    rsync -a "$lock_src/" "$dst/custom.lock/" || return 1
    log_success "Installed: custom.lock plugin"
  else
    log_error "custom.lock plugin not found in configs/bar/plugins/"
    return 1
  fi

  # Inject lock config into shell.json (requires bar module's shell.json)
  local shell_json="$CONFIG_DIR/omarchy/shell.json"
  if [[ -f "$shell_json" ]]; then
    backup_file "$shell_json"
    python3 "$SETUP_DIR/install/lock-inject.py" "$shell_json" || return 1
  else
    log_warn "shell.json not found — install the bar module first."
    log_warn "Lock plugin copied, but it won't activate without the bar module."
  fi

  log_info "PAM/session-lock logic is stock Omarchy — only visuals are restyled."
}

uninstall() {
  log_header "[Lock screen — revert to stock]"

  # Remove custom.lock plugin
  local lock_dir="$CONFIG_DIR/omarchy/plugins/custom.lock"
  if [[ -d "$lock_dir" ]]; then
    rm -rf "$lock_dir"
    log_success "Removed: custom.lock plugin"
  fi

  # Remove lock config from shell.json
  local shell_json="$CONFIG_DIR/omarchy/shell.json"
  if [[ -f "$shell_json" ]] && check_cmd python3; then
    python3 -c "
import json, sys
path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
if 'plugins' in cfg:
    cfg['plugins'] = [p for p in cfg['plugins'] if p.get('id') != 'custom.lock']
if 'disabledPlugins' in cfg:
    cfg['disabledPlugins'] = [p for p in cfg['disabledPlugins'] if p != 'omarchy.lock']
if 'cloneSourceRestores' in cfg:
    cfg['cloneSourceRestores'] = [p for p in cfg['cloneSourceRestores'] if p != 'custom.lock']
with open(path, 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
print('  Removed custom.lock config from shell.json')
" "$shell_json" || return 1
  fi

  log_info "Stock omarchy.lock will be used on next shell restart."
}

description() {
  echo "Lock screen — restyled (centered clock, battery, hidden password field)"
}

details() {
  echo "Clones the stock Omarchy lock service and restyles only the visual layer:"
  echo "time/date/battery centered, password field hidden until typed, no border,"
  echo "fully rounded. PAM/session-lock logic stays stock Omarchy."
  echo ""
  echo "Files:"
  file_row "ADD" "configs/bar/plugins/custom.lock/" "$CONFIG_DIR/omarchy/plugins/custom.lock/"
  file_row "PATCH" "(in place)" "$CONFIG_DIR/omarchy/shell.json  — adds custom.lock plugin, disables omarchy.lock"
  info_row "Requires the Custom bar module (needs its shell.json) to activate."
}
