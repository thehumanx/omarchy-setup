#!/bin/bash
# MPRIS media player indicator for Waybar

player=$(playerctl -l 2>/dev/null | head -1)
if [[ -z "$player" ]]; then
    echo '{"text": "", "class": "stopped"}'
    exit 0
fi

status=$(playerctl status 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null | sed 's/"/\\"/g' | tr -d '\n')
title=$(playerctl metadata title 2>/dev/null | sed 's/"/\\"/g' | tr -d '\n')

truncate() {
    local str="$1"
    local max="$2"
    if [[ ${#str} -gt $max ]]; then
        echo "${str:0:$max}…"
    else
        echo "$str"
    fi
}

if [[ "$status" == "Playing" ]]; then
    text="󰎈 $(truncate "$artist - $title" 50)"
    echo "{\"text\": \"$text\", \"class\": \"playing\"}"
elif [[ "$status" == "Paused" ]]; then
    text="󰏤 $(truncate "$artist - $title" 50)"
    echo "{\"text\": \"$text\", \"class\": \"paused\"}"
else
    echo '{"text": "", "class": "stopped"}'
fi
