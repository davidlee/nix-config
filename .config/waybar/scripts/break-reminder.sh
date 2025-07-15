#!/usr/bin/env bash

# Configuration
CONFIG_DIR="$HOME/.config/waybar/break-reminder"
STATE_FILE="$CONFIG_DIR/state"
CONFIG_FILE="$CONFIG_DIR/config"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Default configuration
DEFAULT_INTERVAL=1800 # 30 minutes in seconds
DEFAULT_MESSAGE="Time to take a break! Step away from your screen."

# Initialize config file if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat >"$CONFIG_FILE" <<EOF
INTERVAL=$DEFAULT_INTERVAL
MESSAGE="$DEFAULT_MESSAGE"
EOF
fi

# Source configuration
source "$CONFIG_FILE"

# Initialize state file if it doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    cat >"$STATE_FILE" <<EOF
PAUSED=false
LAST_BREAK=$(date +%s)
EOF
fi

# Function to get current state
get_state() {
    source "$STATE_FILE"
    local current_time=$(date +%s)
    local elapsed=$((current_time - LAST_BREAK))
    local remaining=$((INTERVAL - elapsed))

    if [[ "$PAUSED" == "true" ]]; then
        echo "paused"
    elif [[ $remaining -le 0 ]]; then
        echo "break_time"
    else
        echo "active"
    fi
}

# Function to get time remaining
get_time_remaining() {
    source "$STATE_FILE"
    local current_time=$(date +%s)
    local elapsed=$((current_time - LAST_BREAK))
    local remaining=$((INTERVAL - elapsed))

    if [[ "$PAUSED" == "true" ]]; then
        echo "⏸️"
    elif [[ $remaining -le 0 ]]; then
        echo "🔔"
    else
        local minutes=$((remaining / 60))
        local seconds=$((remaining % 60))
        printf "%02d:%02d" $minutes $seconds
    fi
}

# Function to send notification
send_notification() {
    notify-send -u critical -i dialog-information "Break Reminder" "$MESSAGE"
}

# Function to reset timer
reset_timer() {
    local current_time=$(date +%s)
    sed -i "s/LAST_BREAK=.*/LAST_BREAK=$current_time/" "$STATE_FILE"
    sed -i "s/PAUSED=.*/PAUSED=false/" "$STATE_FILE"
}

# Function to toggle pause
toggle_pause() {
    source "$STATE_FILE"
    local current_time=$(date +%s)

    if [[ "$PAUSED" == "true" ]]; then
        # Resume: adjust LAST_BREAK to account for paused time
        local pause_duration=$((current_time - PAUSE_START))
        local adjusted_last_break=$((LAST_BREAK + pause_duration))
        sed -i "s/LAST_BREAK=.*/LAST_BREAK=$adjusted_last_break/" "$STATE_FILE"
        sed -i "s/PAUSED=.*/PAUSED=false/" "$STATE_FILE"
    else
        # Pause: record current time
        echo "PAUSE_START=$current_time" >>"$STATE_FILE"
        sed -i "s/PAUSED=.*/PAUSED=true/" "$STATE_FILE"
    fi
}

# Function to set interval
set_interval() {
    local new_interval=$1
    if [[ $new_interval -gt 0 ]]; then
        sed -i "s/INTERVAL=.*/INTERVAL=$new_interval/" "$CONFIG_FILE"
        reset_timer
    fi
}

# Main logic
case "$1" in
"status")
    get_state
    ;;
"display")
    get_time_remaining
    ;;
"check")
    if [[ "$(get_state)" == "break_time" ]]; then
        send_notification
        reset_timer
    fi
    ;;
"reset")
    reset_timer
    ;;
"toggle")
    toggle_pause
    ;;
"set")
    if [[ -n "$2" ]]; then
        set_interval "$2"
    fi
    ;;
*)
    echo "Usage: $0 {status|display|check|reset|toggle|set <seconds>}"
    exit 1
    ;;
esac
