#!/bin/bash
# Bandwidth monitor for Waybar
# Shows current upload/download speeds

get_bandwidth() {
    local interface=$(ip route | grep default | awk '{print $5}' | head -1)
    if [[ -z "$interface" ]]; then
        echo "󰤭 --"
        return
    fi

    # Read current bytes
    local rx1=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx1=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)

    sleep 1

    local rx2=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx2=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)

    # Calculate speeds
    local rx_speed=$(( (rx2 - rx1) / 1024 ))
    local tx_speed=$(( (tx2 - tx1) / 1024 ))

    # Format with appropriate units
    format_speed() {
        local speed=$1
        if [[ $speed -gt 1024 ]]; then
            printf "%.1fM" $(echo "scale=1; $speed/1024" | bc)
        else
            echo "${speed}K"
        fi
    }

    local down=$(format_speed $rx_speed)
    local up=$(format_speed $tx_speed)

    echo "󰇚 ${down} 󰕒 ${up}"
}

get_bandwidth
