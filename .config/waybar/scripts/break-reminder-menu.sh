#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/waybar/break-reminder"
CONFIG_FILE="$CONFIG_DIR/config"
SCRIPT_PATH="$HOME/.config/waybar/scripts/break-reminder.sh"

# Source current config
source "$CONFIG_FILE"

# Convert seconds to minutes for display
CURRENT_MINUTES=$((INTERVAL / 60))

# Create temporary menu file
MENU_FILE=$(mktemp)

cat >"$MENU_FILE" <<EOF
Break Reminder Settings
Current: ${CURRENT_MINUTES} minutes

󱑆 5 minutes!echo "300" | xargs $SCRIPT_PATH set
󱑆 10 minutes!echo "600" | xargs $SCRIPT_PATH set
󱑆 15 minutes!echo "900" | xargs $SCRIPT_PATH set
󱑆 20 minutes!echo "1200" | xargs $SCRIPT_PATH set
󱑆 25 minutes!echo "1500" | xargs $SCRIPT_PATH set
󱑆 30 minutes!echo "1800" | xargs $SCRIPT_PATH set
󱑆 45 minutes!echo "2700" | xargs $SCRIPT_PATH set
󱑆 60 minutes!echo "3600" | xargs $SCRIPT_PATH set
󱑆 90 minutes!echo "5400" | xargs $SCRIPT_PATH set
󱑆 Custom!zenity --entry --title="Break Reminder" --text="Enter minutes:" | while read minutes; do if [[ "$minutes" =~ ^[0-9]+$ ]] && [[ $minutes -gt 0 ]]; then $SCRIPT_PATH set $((minutes * 60)); fi; done
EOF

# Show menu using rofi or dmenu
if command -v rofi &>/dev/null; then
    choice=$(cat "$MENU_FILE" | tail -n +3 | rofi -dmenu -i -p "Break Reminder")
else
    choice=$(cat "$MENU_FILE" | tail -n +3 | dmenu -i -p "Break Reminder:")
fi

# Execute choice
if [[ -n "$choice" ]]; then
    command=$(echo "$choice" | cut -d'!' -f2)
    echo "$command"
    eval "$command"
fi

# Clean up
rm "$MENU_FILE"
