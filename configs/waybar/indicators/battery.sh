#!/bin/bash

BAT_PATH=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)

if [[ -z "$BAT_PATH" ]]; then
  exit 0
fi

LAST_STATUS=""
LAST_CAP=""

print_status() {
  BAT_CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "?")
  BAT_STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

  case "$BAT_STATUS" in
    "Charging")
      ICON="󰂄"
      CLASS="charging"
      TOOLTIP="Charging: ${BAT_CAP}%"
      ;;
    "Full")
      ICON="󰁹"
      CLASS="full"
      TOOLTIP="Fully charged"
      ;;
    "Discharging")
      if [[ "$BAT_CAP" -ge 90 ]]; then
        ICON="󰁹"
      elif [[ "$BAT_CAP" -ge 70 ]]; then
        ICON="󰂀"
      elif [[ "$BAT_CAP" -ge 50 ]]; then
        ICON="󰁾"
      elif [[ "$BAT_CAP" -ge 30 ]]; then
        ICON="󰁼"
      elif [[ "$BAT_CAP" -ge 15 ]]; then
        ICON="󰁹"
      else
        ICON="󰂃"
      fi
      CLASS="discharging"
      TOOLTIP="On battery: ${BAT_CAP}%"
      ;;
    *)
      ICON="󰂑"
      CLASS="unknown"
      TOOLTIP="Battery: ${BAT_CAP}% (${BAT_STATUS})"
      ;;
  esac

  echo "{\"text\": \"${ICON} ${BAT_CAP}%\", \"tooltip\": \"${TOOLTIP}\", \"class\": \"${CLASS}\"}"
}

print_status

while true; do
  sleep 1
  BAT_CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "?")
  BAT_STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)
  
  if [[ "$BAT_STATUS" != "$LAST_STATUS" || "$BAT_CAP" != "$LAST_CAP" ]]; then
    LAST_STATUS="$BAT_STATUS"
    LAST_CAP="$BAT_CAP"
    print_status
  fi
done
