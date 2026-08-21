#!/bin/bash
# Module: post-update-hook — Auto-restore customizations after omarchy updates

HOOK_DST="$CONFIG_DIR/omarchy/hooks/post-update.d/restore-customizations.hook"

install() {
  log_header "[Post-update hook]"

  local hook="$SETUP_DIR/restore-customizations.hook"
  if [[ ! -f "$hook" ]]; then
    log_error "restore-customizations.hook not found in repo root"
    return 1
  fi

  if check_cmd omarchy-hook-install; then
    omarchy-hook-install post-update "$hook" || return 1
    log_success "Installed: post-update hook (drift-detecting)"
  else
    log_warn "omarchy-hook-install not found. Install the hook manually:"
    log_warn "  omarchy hook install post-update $hook"
    return 1
  fi
}

uninstall() {
  log_header "[Post-update hook — remove]"

  if [[ -f "$HOOK_DST" ]]; then
    rm "$HOOK_DST"
    log_success "Removed: restore-customizations.hook"
  else
    log_info "Hook not present, nothing to remove."
  fi
  log_info "Customizations will no longer auto-restore after omarchy updates."
}

description() {
  echo "Post-update hook — auto-restore after omarchy updates (with drift detection)"
}

details() {
  echo "Registers restore-customizations.hook as an omarchy post-update hook."
  echo "After each 'omarchy update' it re-applies your customizations and flags"
  echo "a warning (⚠ DRIFT) if the update changed something this repo manages."
  echo ""
  echo "Files:"
  file_row "RUN" "omarchy-hook-install post-update" "$HOOK_DST"
}
