#!/bin/bash
# Bluetooth status indicator for Waybar

~/.config/omarchy/bluetooth-state.sh save

if ! busctl --system get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered &>/dev/null; then
  echo '{"text": "󰂲", "tooltip": "Bluetooth off", "class": "off"}'
  exit 0
fi

powered=$(busctl --system get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null)

if [[ $powered != "b true" ]]; then
  echo '{"text": "󰂲", "tooltip": "Bluetooth off", "class": "off"}'
  exit 0
fi

devices=$(busctl --system call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects 2>/dev/null | grep -oP '/org/bluez/hci0/dev_[0-9A-F_]+(?!/)' | sort -u)

connected_names=()
while IFS= read -r path; do
  if [[ -z $path ]]; then continue; fi
  connected=$(busctl --system get-property org.bluez "$path" org.bluez.Device1 Connected 2>/dev/null | tr -d 'b \n')
  if [[ $connected == "true" ]]; then
    name=$(busctl --system get-property org.bluez "$path" org.bluez.Device1 Alias 2>/dev/null | sed 's/^s "\|"$//g')
    connected_names+=("$name")
  fi
done <<< "$devices"

if [[ ${#connected_names[@]} -gt 0 ]]; then
  IFS=", " joined="${connected_names[*]}"
  echo "{\"text\": \"󰂱 $joined\", \"tooltip\": \"$joined\", \"class\": \"connected\"}"
else
  echo '{"text": "󰂯", "tooltip": "Bluetooth on - no devices connected", "class": "on"}'
fi
