#!/bin/bash
# Bluetooth state persistence

STATE_FILE="$HOME/.local/state/omarchy/bluetooth-power"

save() {
    local powered
    powered=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    echo "$powered" > "$STATE_FILE"
}

restore() {
    if [[ ! -f "$STATE_FILE" ]]; then
        return
    fi
    local wanted
    wanted=$(cat "$STATE_FILE")
    local current
    current=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    if [[ "$wanted" != "$current" ]]; then
        bluetoothctl power "$wanted" 2>/dev/null
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
