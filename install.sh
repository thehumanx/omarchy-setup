#!/bin/bash
# omarchy-configs interactive installer — one step at a time.
# Each step shows what it does, which files it touches, then lets you
# proceed, skip, or abort. Progress shown per-step and overall.
#
# Usage:
#   ./install.sh                    Step-by-step through all customizations
#   ./install.sh --all              Install everything without prompting
#   ./install.sh --only bar,cursor  Step-by-step through selected modules only
#   ./install.sh --help             Show help

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install/modules/common.sh"

MODULE_ORDER=(
  wallpaper-pipeline
  lock
  hyprland
  bar
  branding
  cursor
  boot-lock
  post-update-hook
)

usage() {
  echo "Usage: $0 [--all | --only mod1,mod2 | --help]"
  echo ""
  echo "  (no args)            Step-by-step through all customizations"
  echo "  --all                Install everything without prompting"
  echo "  --only mod1,mod2     Walk through only the named modules"
  echo "  --help               Show this help"
  echo ""
  echo "Modules: ${MODULE_ORDER[*]}"
}

module_file() { echo "$SCRIPT_DIR/install/modules/$1.sh"; }

module_desc() {
  bash -c "source '$SCRIPT_DIR/install/modules/common.sh' >/dev/null; source '$(module_file "$1")'; description"
}

# ── Overview ──────────────────────────────────────────────────────────

show_overview() {
  local -a names=("$@")
  clear
  echo ""
  HR
  echo -e "  ${BOLD}${CYAN}omarchy-configs installer${NC}"
  echo -e "  ${DIM}${#names[@]} customization(s), applied one step at a time.${NC}"
  HR
  echo ""
  local i=1
  for mod in "${names[@]}"; do
    printf "  ${BOLD}%d.${NC} %s\n" "$i" "$(module_desc "$mod")"
    ((i++))
  done
  echo ""
  HR
  echo -e "  ${CYAN}Each step:${NC} see details → choose ${GREEN}proceed${NC} / ${YELLOW}skip${NC} / ${RED}abort${NC}"
  echo ""
  read -rp "  Press Enter to start, or Ctrl+C to cancel..." _
}

# ── Runner ────────────────────────────────────────────────────────────

run_steps() {
  local interactive="$1"; shift
  local -a names=("$@")
  local total=${#names[@]}
  local -a results

  local n=1
  for mod in "${names[@]}"; do
    local title
    title=$(module_desc "$mod")

    if [[ "$interactive" == "yes" ]]; then
      step_header "$n" "$total" "$title" "Module: $mod"
      show_details "$(module_file "$mod")"
      ask_proceed
      local choice=$?
      case $choice in
        2) echo -e "\n  ${YELLOW}Aborted at step $n. Nothing further was changed.${NC}"; progress_bar $((n-1)) "$total"; echo ""; exit 130 ;;
        1) results+=("skipped"); progress_bar "$n" "$total"; ((n++)); continue ;;
      esac
    fi

    # Run the module's install()
    if run_module_fn "$(module_file "$mod")" install; then
      results+=("done")
    else
      results+=("failed")
    fi
    progress_bar "$n" "$total"
    ((n++))
  done

  cleanup_empty_dirs

  # ── Summary ────────────────────────────────────────────────────────
  echo ""
  HR
  echo -e "  ${BOLD}${CYAN}Summary${NC}"
  HR
  local i=1 failures=0
  for idx in "${!names[@]}"; do
    case "${results[$idx]}" in
      done)    echo -e "  ${GREEN}✔${NC} Step $i: $(module_desc "${names[$idx]}")" ;;
      skipped) echo -e "  ${YELLOW}→${NC} Step $i: skipped — $(module_desc "${names[$idx]}")" ;;
      failed)  echo -e "  ${RED}✘${NC} Step $i: FAILED — $(module_desc "${names[$idx]}")"; ((failures++)) ;;
    esac
    ((i++))
  done
  HR

  if (( failures > 0 )); then
    log_error "$failures step(s) failed — review the output above."
    exit 1
  fi

  echo ""
  echo -e "${BOLD}Next steps:${NC}"
  echo -e "  1. ${CYAN}hyprctl reload && hyprctl configerrors${NC}  — validate Hyprland changes"
  echo -e "  2. ${CYAN}omarchy restart shell${NC}                    — apply bar/lock screen changes"
  echo ""
}

# ── Main ──────────────────────────────────────────────────────────────

case "${1:-}" in
  --help|-h) usage; exit 0 ;;
  --all)     run_steps no "${MODULE_ORDER[@]}"; exit $? ;;
  --only)
    shift
    [[ -z "${1:-}" ]] && { log_error "--only needs a module list"; usage; exit 1; }
    IFS=',' read -ra wanted <<< "$1"
    for w in "${wanted[@]}"; do
      [[ -f "$(module_file "$w")" ]] || { log_error "Unknown module: $w"; exit 1; }
    done
    run_steps yes "${wanted[@]}"; exit $?
    ;;
  "") show_overview "${MODULE_ORDER[@]}"; run_steps yes "${MODULE_ORDER[@]}"; exit $? ;;
  *) log_error "Unknown option: $1"; usage; exit 1 ;;
esac
