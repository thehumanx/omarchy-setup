#!/bin/bash
# Module: branding — Custom ASCII art for about screen and lock screen
# Interactive: prompts user to generate art at patorjk.com and paste it.

install() {
  log_header "[Branding — custom ASCII art]"

  local patorjk_url="https://patorjk.com/software/taag/"
  local dst="$CONFIG_DIR/omarchy/branding"
  mkdir -p "$dst"

  echo ""
  echo -e "  ${CYAN}This module sets custom ASCII art for the about text and lock screen.${NC}"
  echo -e "  ${CYAN}You'll need to generate your art first.${NC}"
  echo ""
  echo -e "  ${BOLD}Step 1:${NC} Open ${BLUE}$patorjk_url${NC}"
  echo -e "  ${BOLD}Step 2:${NC} Pick a font (try ${BOLD}ANSI Shadow${NC} or ${BOLD}Calvin S${NC})"
  echo -e "  ${BOLD}Step 3:${NC} Type your text and copy the output"
  echo ""

  read -rp "  Press Enter when ready to paste, or 's' to skip: " ready
  if [[ "$ready" == "s" || "$ready" == "S" ]]; then
    log_info "Skipping branding."
    return 0
  fi

  # About text
  echo ""
  echo -e "  ${CYAN}Paste your about text (Ctrl+D when done):${NC}"
  echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  local about_text
  about_text=$(cat)
  echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  if [[ -n "$about_text" ]]; then
    echo "$about_text" > "$dst/about.txt"
    log_success "Wrote: about.txt"
  fi

  # Screensaver text
  echo ""
  echo -e "  ${CYAN}Now paste your lock screen text (keep it short):${NC}"
  echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  local ss_text
  ss_text=$(cat)
  echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  if [[ -n "$ss_text" ]]; then
    echo "$ss_text" > "$dst/screensaver.txt"
    log_success "Wrote: screensaver.txt"
  fi

  log_success "Branding installed to ${dst/#$HOME/\~}"
}

uninstall() {
  log_header "[Branding — reset to stock]"

  restore_file "$CONFIG_DIR/omarchy/branding"

  if check_cmd omarchy; then
    omarchy branding about reset 2>/dev/null && log_success "About branding reset"
    omarchy branding screensaver reset 2>/dev/null && log_success "Screensaver branding reset"
  fi
}

description() {
  echo "Branding — custom ASCII art for about screen and lock screen (interactive)"
}

details() {
  echo "Interactive: you generate ASCII art at patorjk.com and paste it."
  echo "Sets custom text for the about screen and the lock screen."
  echo ""
  echo "Files:"
  file_row "ADD" "(your paste)" "$CONFIG_DIR/omarchy/branding/about.txt"
  file_row "ADD" "(your paste)" "$CONFIG_DIR/omarchy/branding/screensaver.txt"
  info_row "You can skip pasting either text during install."
}

# Branding is interactive — mark it so the runner can warn before running.
BRANDING_INTERACTIVE=1
