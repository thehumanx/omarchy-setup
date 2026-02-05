#!/bin/bash
# Notification counter for Waybar
# Shows number of unread notifications in Mako

count=$(makoctl list 2>/dev/null | jq -r '.data[0][1][0][1][] | select(.["app-name"].data != "screenshot") | .id.data' | wc -l)

if [[ "$count" -gt 0 ]]; then
    echo "󰂚 ${count}"
else
    echo ""
fi
