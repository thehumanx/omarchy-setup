#!/bin/bash
# Bluetooth state persistence using busctl (no bluetoothctl dependency)

STATE_FILE="$HOME/.local/state/omarchy/bluetooth-power"

_powered() {
  busctl --system get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null
}

save() {
  local powered
  powered=$(_powered)
  echo "$powered" > "$STATE_FILE"
}

restore() {
  if [[ ! -f "$STATE_FILE" ]]; then
    return
  fi
  local wanted
  wanted=$(cat "$STATE_FILE")
  local current
  current=$(_powered)
  if [[ "$wanted" != "$current" ]]; then
    local value
    if [[ $wanted == "b true" ]]; then
      value=true
    else
      value=false
    fi
    busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b "$value" 2>/dev/null
  fi
}

case "$1" in
  "save")   save ;;
  "restore") restore ;;
  *)
    echo "Usage: $0 {save|restore}"
    exit 1
    ;;
esac
