#!/bin/bash
# Shared functions for install/uninstall modules.
# Each module defines: install(), uninstall(), description(), details()

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIGS_DIR="$SETUP_DIR/configs"
CONFIG_DIR="$HOME/.config"
BACKUP_SUFFIX=".pre-omarchy-setup"

# Real ESC characters (not literal \033 strings) so colors work everywhere,
# including `read -rp` prompts which do not interpret escape sequences.
ESC=$'\033'
RED="${ESC}[0;31m"
GREEN="${ESC}[0;32m"
YELLOW="${ESC}[1;33m"
BLUE="${ESC}[0;34m"
CYAN="${ESC}[0;36m"
DIM="${ESC}[2m"
BOLD="${ESC}[1m"
NC="${ESC}[0m"

log_info()    { echo -e "  ${BLUE}$1${NC}"; }
log_success() { echo -e "  ${GREEN}✔ $1${NC}"; }
log_warn()    { echo -e "  ${YELLOW}⚠ $1${NC}"; }
log_error()   { echo -e "  ${RED}✘ $1${NC}"; }
log_header()  { echo -e "\n${BOLD}${CYAN}$1${NC}"; }

check_cmd() { command -v "$1" &>/dev/null; }
check_pkg() { pacman -Qi "$1" &>/dev/null 2>&1; }

# ── Backup / restore ──────────────────────────────────────────────────

backup_file() {
  local dst="$1"
  if [[ -f "$dst" && ! -f "$dst$BACKUP_SUFFIX" ]]; then
    cp "$dst" "$dst$BACKUP_SUFFIX"
    log_info "Backed up existing $(basename "$dst") → $(basename "$dst")$BACKUP_SUFFIX"
  fi
}

# Restore original from backup, or remove file we installed fresh.
restore_file() {
  local dst="$1"
  local bak="$dst$BACKUP_SUFFIX"
  if [[ -f "$bak" ]]; then
    mkdir -p "$(dirname "$dst")"
    mv "$bak" "$dst"
    log_success "Restored original: ${dst/#$HOME/\~}"
  elif [[ -e "$dst" ]]; then
    rm -rf "$dst"
    log_success "Removed: ${dst/#$HOME/\~}"
  else
    log_info "Not present, nothing to revert: ${dst/#$HOME/\~}"
  fi
}

# ── Copy helpers (fail loudly) ────────────────────────────────────────

copy_file() {
  local src="$1" dst="$2"
  if [[ ! -f "$src" ]]; then
    log_error "Missing source file: $src"
    return 1
  fi
  mkdir -p "$(dirname "$dst")" || return 1
  if ! cp "$src" "$dst"; then
    log_error "Failed to copy: $src → $dst"
    return 1
  fi
  log_success "Copied: $(basename "$dst")"
}

copy_dir() {
  local src="$1" dst="$2"
  if [[ ! -d "$src" ]]; then
    log_error "Missing source dir: $src"
    return 1
  fi
  mkdir -p "$dst" || return 1
  if ! rsync -a "$src/" "$dst/"; then
    log_error "Failed to copy dir: $src → $dst"
    return 1
  fi
  log_success "Copied: $(basename "$dst")/"
}

# ── Step UI ───────────────────────────────────────────────────────────

HR() { echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

progress_bar() {
  local current=$1 total=$2 width=30
  (( total <= 0 )) && return
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))
  local bar=""
  for ((i=0;i<filled;i++)); do bar+="█"; done
  for ((i=0;i<empty;i++)); do bar+="░"; done
  echo -ne "\r  ${CYAN}[${bar}]${NC} ${current}/${total} steps"
  (( current == total )) && echo ""
}

# file_row <ACTION> <source> <destination>
file_row() {
  local action="$1" src="$2" dst="$3"
  local c="$GREEN"
  case "$action" in
    OVERWRITE) c="$YELLOW" ;;
    PATCH)     c="$CYAN" ;;
    RUN)       c="$BLUE" ;;
  esac
  printf "      %b%-10s%b ${BOLD}%s${NC}\n          → %s\n" "$c" "$action" "$NC" "$src" "${dst/#$HOME/\~}"
}

info_row() {
  printf "      ${BLUE}•${NC} %s\n" "$1"
}

step_header() {
  local step_num="$1" total="$2" title="$3" subtitle="$4"
  clear
  echo ""
  HR
  echo -e "  ${BOLD}${CYAN}STEP $step_num OF $total — $title${NC}"
  echo -e "  ${DIM}$subtitle${NC}"
  HR
  progress_bar "$((step_num - 1))" "$total"
  echo ""
}

show_details() {
  local mod_file="$1"
  source "$mod_file"
  echo -e "  ${BOLD}What this does:${NC}"
  details
  echo ""
}

# ask_proceed — returns 0=proceed, 1=skip, 2=abort
ask_proceed() {
  while true; do
    read -rp "  Proceed with this step? [${GREEN}P${NC}]roceed / [${YELLOW}s${NC}]kip / [${RED}a${NC}]bort: " answer
    case "$answer" in
      p|P|"") return 0 ;;
      s|S)    return 1 ;;
      a|A|q|Q) return 2 ;;
      *) echo -e "  ${DIM}Please answer p, s, or a.${NC}" ;;
    esac
  done
}

# Run a module's function in the current shell, propagating failure.
run_module_fn() {
  local mod_file="$1" fn="$2"
  source "$mod_file"
  "$fn"
}

# Remove dirs the installer may have created, but only when empty —
# never touches dirs that still hold stock or user files.
cleanup_empty_dirs() {
  local d
  for d in \
    "$CONFIG_DIR/hypr" \
    "$CONFIG_DIR/omarchy/plugins" \
    "$CONFIG_DIR/omarchy/extensions" \
    "$CONFIG_DIR/xdg-desktop-portal" \
    "$HOME/.local/share/xdg-desktop-portal/portals"
  do
    rmdir "$d" 2>/dev/null || true
  done
}
