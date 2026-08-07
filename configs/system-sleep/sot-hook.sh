#!/bin/bash
# Signal sot-daemon before sleep and after wake via named pipe
for home in /home/*/; do
    pipe="${home}.local/state/omarchy/sot.pipe"
    [[ -p "$pipe" ]] || continue
    case "$1" in
        pre)  echo "sleep"     > "$pipe" 2>/dev/null & ;;
        post) echo "screen-on" > "$pipe" 2>/dev/null & ;;
    esac
done
