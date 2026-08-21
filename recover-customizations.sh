#!/bin/bash
# Restore all customizations non-interactively.
# For selective install, use install.sh instead.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install/modules/common.sh"

echo "--- Restoring all customizations ---"

# Load modules in defined order
MODULE_ORDER=(
  bar
  wallpaper-pipeline
  lock
  hyprland
  branding
  cursor
  boot-lock
  post-update-hook
)

declare -A MODULE_FILES
for mod in "$SCRIPT_DIR"/install/modules/*.sh; do
  name=$(basename "$mod" .sh)
  MODULE_FILES[$name]="$mod"
done

for mod_name in "${MODULE_ORDER[@]}"; do
  source "${MODULE_FILES[$mod_name]}"
  install
done

echo ""
echo "--- Done ---"
echo "Run 'hyprctl reload && hyprctl configerrors' to apply + validate Hyprland changes."
echo "Run 'omarchy restart shell' to apply bar/lock-screen changes."
