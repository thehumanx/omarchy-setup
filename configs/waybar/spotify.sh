#!/bin/bash

# Spotify now playing script for Waybar
# Uses playerctl to get Spotify playback information

get_spotify_info() {
    # Get player status
    status=$(playerctl -p spotify status 2>/dev/null)
    
    if [ "$status" = "No player found" ] || [ -z "$status" ]; then
        echo '{"text": "󰝚 Spotify not open", "tooltip": "Spotify not running", "class": "stopped"}'
        return
    fi
    
    # Get metadata
    artist=$(playerctl -p spotify metadata artist 2>/dev/null || echo "Unknown Artist")
    title=$(playerctl -p spotify metadata title 2>/dev/null || echo "Unknown Title")
    album=$(playerctl -p spotify metadata album 2>/dev/null || echo "Unknown Album")
    
    # Clean up text (remove quotes and special characters)
    artist=$(echo "$artist" | sed 's/"//g' | sed 's|/|\\/|g')
    title=$(echo "$title" | sed 's/"//g' | sed 's|/|\\/|g')
    album=$(echo "$album" | sed 's/"//g' | sed 's|/|\\/|g')
    
    # Output JSON for Waybar
    case "$status" in
        "Playing")
            icon="󰎈"
            class="playing"
            ;;
        "Paused")
            icon="󰏤"
            class="paused"
            ;;
        *)
            icon="󰝚"
            class="stopped"
            ;;
    esac
    
    echo "{\"text\": \"$icon $artist - $title\", \"tooltip\": \"$artist - $title\\nAlbum: $album\\nStatus: $status\", \"class\": \"$class\", \"artist\": \"$artist\", \"title\": \"$title\", \"album\": \"$album\", \"status\": \"$status\"}"
}

# Main execution
get_spotify_info
