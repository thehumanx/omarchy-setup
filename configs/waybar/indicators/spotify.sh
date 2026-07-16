#!/bin/bash

# Spotify now playing script for Waybar
# Uses playerctl to get Spotify playback information

get_spotify_info() {
    # Get player status
    status=$(playerctl -p spotify status 2>/dev/null)
    
    if [ "$status" = "No player found" ] || [ -z "$status" ]; then
        echo '{"text": "no music", "tooltip": "Spotify not running", "class": "stopped"}'
        return
    }

# Main execution
get_spotify_info
