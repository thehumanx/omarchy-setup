#!/usr/bin/env bash

get_print_status() {
    local active_job=$(lpstat -o 2>/dev/null | head -1)
    
    if [ -z "$active_job" ]; then
        echo '{"text": "", "class": "idle"}'
        return
    fi
    
    local job_id=$(echo "$active_job" | awk '{print $1}')
    local printer=$(echo "$active_job" | awk '{print $2}')
    local job_name=$(echo "$active_job" | awk '{for(i=5;i<=NF-4;i++) printf $i" "; print ""}' | sed 's/ $//')
    local job_pages=$(tail -20 /var/log/cups/page_log 2>/dev/null | grep "$job_id" | tail -1 | awk '{print $4}')
    
    if [ -n "$job_pages" ]; then
        echo "{\"text\": \" 󰨛 $job_pages pages\", \"class\": \"printing\", \"tooltip\": \"Job: $job_id - $job_name on $printer\"}"
    else
        echo "{\"text\": \" 󰨛 $job_name\", \"class\": \"printing\", \"tooltip\": \"Job: $job_id on $printer\"}"
    fi
}

get_print_status
