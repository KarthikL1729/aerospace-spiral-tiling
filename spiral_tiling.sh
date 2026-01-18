#!/usr/bin/env bash

# AeroSpace Spiral Autotiling Script
# Implements Fibonacci/spiral tiling where new windows split alternating directions

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Get current split count to determine orientation
# Shifted pattern for proper spiral tiling
get_split_orientation() {
    local count=$1
    
    # First split (2 windows) should be horizontal
    # Second split (3 windows) should be vertical
    # Third split (4 windows) should be horizontal
    # Pattern uses count to shift the alternating by one level
    
    if [ $(((count) % 2)) -eq 0 ]; then
        echo "vertical"
    else
        echo "horizontal"
    fi
}

# Main monitoring loop
main() {
    log "Spiral Autotiling started (v2)"
    #sleep 2
    
    # Store previous window list
    local prev_windows=""
    
    while true; do
        # Get all current windows
        local curr_windows=$(aerospace list-windows --all 2>/dev/null)
        
        # Check if window list changed
        if [ "$curr_windows" != "$prev_windows" ]; then
            # Count windows in focused workspace
            local focused_ws=$(aerospace list-workspaces --focused 2>/dev/null)
            local win_count=$(aerospace list-windows --workspace "$focused_ws" 2>/dev/null | wc -l | tr -d ' ')
            
            log "Change detected in workspace $focused_ws: $win_count windows"
            
            # Determine split orientation based on count statically
            local orientation=$(get_split_orientation "$win_count")
            log "Applying $orientation split"
                
            # Set the split orientation for the next window placement
            aerospace split "$orientation" 2>&1 | head -1 | while read line; do
                log "Split result: $line"
            done
            
            prev_windows="$curr_windows"
        fi
        sleep 0.3
    done
}

main
