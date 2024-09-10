#!/bin/bash

DOTIGNORE_FILE="$HOME/dotfiles/.dotignore"

# Read exclusion patterns from .dotignore into an array
mapfile -t EXCLUDE_PATTERNS < "$DOTIGNORE_FILE"

# Monitor changes with inotifywait
inotifywait -m -r -e create,delete,modify --format '%w%f' "$HOME/dotfiles" | while read -r file
do
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

  # Print the full path of the changed file
  echo "$file has been changed."

  # Perform actions
  stow -d "$HOME/dotfiles" -t "$HOME" . 
  /usr/local/bin/git-autopush --repo dotfiles

done