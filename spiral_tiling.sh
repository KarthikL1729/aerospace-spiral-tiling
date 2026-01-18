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
    log "Spiral Autotiling started - handles window add/remove"
    
    # Store all known window IDs across all workspaces
    local known_windows=""
    
    while true; do
        # Get ALL window IDs across all workspaces
        local current_windows=$(aerospace list-windows --all 2>/dev/null | awk '{print $1}' | sort)
        
        # Find newly created and destroyed windows
        if [ -n "$known_windows" ]; then
            local new_windows=$(comm -13 <(echo "$known_windows") <(echo "$current_windows"))
            local removed_windows=$(comm -23 <(echo "$known_windows") <(echo "$current_windows"))
            
            # Handle new windows
            if [ -n "$new_windows" ]; then
                local new_count=$(echo "$new_windows" | grep -c .)
                
                # Only apply split if 1 window appeared (not a mass event)
                if [ "$new_count" -le 1 ]; then
                    local focused_ws=$(aerospace list-workspaces --focused 2>/dev/null)
                    local win_count=$(aerospace list-windows --workspace "$focused_ws" 2>/dev/null | wc -l | tr -d ' ')
                    
                    log "Window added - workspace $focused_ws has $win_count total"
                    
                    local orientation=$(get_split_orientation "$win_count")
                    log "Setting $orientation split"
                    aerospace split "$orientation" 2>/dev/null
                else
                    log "Mass add ($new_count windows) - ignoring"
                fi
            fi
            
            # Handle removed windows
            if [ -n "$removed_windows" ]; then
                local removed_count=$(echo "$removed_windows" | grep -c .)
                
                if [ "$removed_count" -le 2 ]; then
                    local focused_ws=$(aerospace list-workspaces --focused 2>/dev/null)
                    local win_count=$(aerospace list-windows --workspace "$focused_ws" 2>/dev/null | wc -l | tr -d ' ')
                    
                    log "Window removed - workspace $focused_ws has $win_count remaining"
                    
                    if [ "$win_count" -ge 2 ]; then
                        local orientation=$(get_split_orientation "$win_count")
                        log "Setting $orientation split"
                        aerospace split "$orientation" 2>/dev/null
                    fi
                else
                    log "Mass removal ($removed_count windows) - ignoring"
                fi
            fi
        else
            log "Initializing window tracking ($(echo "$current_windows" | grep -c .) windows)"
        fi
        
        # Update known windows
        known_windows="$current_windows"
        
        sleep 0.1
    done
}

main
