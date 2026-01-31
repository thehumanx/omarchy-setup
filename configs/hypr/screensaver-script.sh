#!/bin/bash

# Custom screensaver script with lock on exit
# This replaces the omarchy-cmd-screensaver functionality

screensaver_in_focus() {
  hyprctl activewindow -j | jq -e '.class == "org.omarchy.screensaver"' >/dev/null 2>&1
}

exit_screensaver() {
  hyprctl keyword cursor:invisible false &>/dev/null || true
  pkill -x tte 2>/dev/null
  pkill -f org.omarchy.screensaver 2>/dev/null
  exit 0
}

trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

printf '\033]11;rgb:00/00/00\007'

hyprctl keyword cursor:invisible true &>/dev/null

tty=$(tty 2>/dev/null)

# Add Python path to find terminaltexteffects module
export PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH"

while true; do
  # Check if tte is available with adjusted Python path
  if command -v tte >/dev/null 2>&1 && PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH" python3 -c "import terminaltexteffects" 2>/dev/null; then
    # Run tte with adjusted Python path
    PYTHONPATH="/usr/lib/python3.13/site-packages:$PYTHONPATH" tte -i ~/.config/omarchy/branding/screensaver.txt \
      --frame-rate 120 --canvas-width 0 --canvas-height 0 --reuse-canvas --anchor-canvas c --anchor-text c\
      --random-effect --exclude-effects dev_worm \
      --no-eol --no-restore-cursor &

    while pgrep -t "${tty#/dev/}" -x tte >/dev/null; do
      if read -n1 -t 1 || ! screensaver_in_focus; then
        exit_screensaver
      fi
    done
  else
    # Fallback: simple blank screen with clock
    while true; do
      clear
      printf '\033]11;rgb:00/00/00\007'
      echo "$(date '+%H:%M:%S')"
      sleep 1
      
      if ! screensaver_in_focus; then
        exit_screensaver
      fi
    done
  fi
done