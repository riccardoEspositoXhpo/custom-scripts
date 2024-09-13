#!/bin/bash

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
DOTIGNORE_FILE="$DOTFILES_DIR/.dotignore"
ZSH_FILES=()
STOW_DIR="$DOTFILES_DIR"
DEBOUNCE_DELAY=5  # Time in seconds to wait before processing
LOCKFILE="/tmp/inotifywait.lock"
COOLDOWN_PERIOD=60  # Time in seconds to wait before processing the same file again
TIMESTAMP_FILE="/tmp/inotifywait_timestamps.txt"

# Read exclusion patterns from .dotignore into an array
mapfile -t EXCLUDE_PATTERNS < "$DOTIGNORE_FILE"

# Identify all zsh files (excluding .zsh_history) and store absolute paths
shopt -s nullglob
for zsh_file in "$DOTFILES_DIR"/arch/.zsh*; do
  if [[ -f "$zsh_file" && ! "$zsh_file" =~ \.zsh_history$ && ! "$zsh_file" =~ \.zwc$ ]]; then
    ZSH_FILES+=("$(realpath "$zsh_file")")
  fi
done

# Create a lockfile to ensure only one instance runs at a time
exec 200>"$LOCKFILE"
flock -n 200 || { echo "Another instance is running. Exiting."; exit 1; }

# Create timestamp file if it does not exist
touch "$TIMESTAMP_FILE"

# Monitor changes with inotifywait
last_processed_time=0
inotifywait -m -r -e create,delete,modify --format '%w%f' "$DOTFILES_DIR" | while read -r file; do
  current_time=$(date +%s)
  
  # Check if the file matches any exclude pattern - prevents spam
  excluded=0
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "$file" == *"$pattern"* ]]; then
      excluded=1
      break
    fi
  done

  # Skip excluded files
  if [[ $excluded -eq 1 ]]; then
    continue
  fi

  # Debounce logic
  if (( current_time - last_processed_time < DEBOUNCE_DELAY )); then
    continue
  fi

  # Cooldown logic
  if grep -q "$file" "$TIMESTAMP_FILE"; then
    file_last_time=$(grep "$file" "$TIMESTAMP_FILE" | cut -d ' ' -f 2)
    if (( current_time - file_last_time < COOLDOWN_PERIOD )); then
      continue
    fi
  fi

  # Update the timestamp file
  grep -v "$file" "$TIMESTAMP_FILE" > "$TIMESTAMP_FILE.tmp"
  mv "$TIMESTAMP_FILE.tmp" "$TIMESTAMP_FILE"
  echo "$file $current_time" >> "$TIMESTAMP_FILE"

  # Update the last processed time
  last_processed_time=$current_time

  # Print the full path of the changed file
  echo "$file has been changed."

  # Run zcompile only if the changed file is in ZSH_FILES array
  if [[ " ${ZSH_FILES[@]} " =~ " $(realpath "$file") " ]]; then
    echo "Compiling $file"
    zsh -c "zcompile $file"
  fi

  # Perform actions
  stow -d "$STOW_DIR" -t "$HOME" arch --adopt 
  /usr/local/bin/git-autopush --repo dotfiles

  echo "Sync complete. Sleeping $DEBOUNCE_DELAY seconds."
  echo "Will not process $file for the next $COOLDOWN_PERIOD seconds."
  sleep "$DEBOUNCE_DELAY"

done

shopt -u nullglob
