#!/bin/bash

# utils
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# Path to pacman log
PACMAN_LOG="/var/log/pacman.log"

# Get the last update date from the pacman log
LAST_UPDATE=$(grep "starting full system upgrade" "$PACMAN_LOG" | tail -1 | cut -d ' ' -f 1 | tr -d '[]')

# Get current date and calculate the difference
CURRENT_DATE=$(date +%s)
LAST_UPDATE_DATE=$(date -d "$LAST_UPDATE" +%s)

# Calculate the difference in days
DIFF_DAYS=$(( (CURRENT_DATE - LAST_UPDATE_DATE) / 86400 ))

echo "Days since last upgrade: $DIFF_DAYS"

# If the last update was more than 7 days ago, send a notification
if [ "$DIFF_DAYS" -ge 7 ]; then
    response=$(notify-send "System Upgrade Reminder" "Your system hasn't been updated in over 7 days." -u critical --action=update="Update" --wait)
fi

if [ "$response" == "update" ]; then

    if command_exists "paru"; then
        cmd="paru"
    elif command_exists "yay"; then
        cmd="yay -Syu"
    else 
        cmd="pacman -Syu"
    fi

    exec "$cmd"

fi
