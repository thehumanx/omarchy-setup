#!/bin/bash

# Custom screensaver launcher with lock on exit
# This is our own implementation that doesn't modify Omarchy defaults

if ! command -v tte &>/dev/null; then
  exit 1
fi

pgrep -f org.omarchy.screensaver && exit 0

if [[ -f ~/.local/state/omarchy/toggles/screensaver-off ]] && [[ $1 != "force" ]]; then
  exit 1
fi

walker -q

focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')
terminal=$(xdg-terminal-exec --print-id)

# Launch custom screensaver script in terminal windows
for m in $(hyprctl monitors -j | jq -r '.[] | .name'); do
  hyprctl dispatch focusmonitor $m

  case $terminal in
  *Alacritty*)
    hyprctl dispatch exec -- \
      alacritty --class=org.omarchy.screensaver \
      --config-file ~/.local/share/omarchy/default/alacritty/screensaver.toml \
      -e ~/.config/hypr/screensaver-script.sh
    ;;
  *ghostty*)
    hyprctl dispatch exec -- \
      ghostty --class=org.omarchy.screensaver \
      --config-file=~/.local/share/omarchy/default/ghostty/screensaver \
      --font-size=18 \
      -e ~/.config/hypr/screensaver-script.sh
    ;;
  *kitty*)
    hyprctl dispatch exec -- \
      kitty --class=org.omarchy.screensaver \
      --override font_size=18 \
      --override window_padding_width=0 \
      -e ~/.config/hypr/screensaver-script.sh
    ;;
  *)
    notify-send "✋  Screensaver only runs in Alacritty, Ghostty, or Kitty"
    ;;
  esac
done

hyprctl dispatch focusmonitor $focused

# Wait for screensaver windows to close, then lock
while pgrep -f org.omarchy.screensaver >/dev/null; do
  sleep 0.1
done
hyprlock