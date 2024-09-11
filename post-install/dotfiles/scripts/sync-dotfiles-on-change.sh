#!/bin/bash

DOTIGNORE_FILE="$HOME/dotfiles/.dotignore"
DOTFILES_DIR="$HOME/dotfiles"
ZSH_FILES=()

# Read exclusion patterns from .dotignore into an array
mapfile -t EXCLUDE_PATTERNS < "$DOTIGNORE_FILE"

# Identify all zsh files (excluding .zsh_history)
for zsh_file in "$DOTFILES_DIR"/*zsh*; do
  if [[ -f "$zsh_file" && ! "$zsh_file" =~ \.zsh_history$ ]]; then
    ZSH_FILES+=("$zsh_file")
  fi
done

# Monitor changes with inotifywait
inotifywait -m -r -e create,delete,modify --format '%w%f' "$DOTFILES_DIR" | while read -r file
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

  # Run zcompile only if the changed file is in ZSH_FILES array
  if [[ " ${ZSH_FILES[@]} " =~ " ${file} " ]]; then
    echo "Compiling $file"
    zcompile "$file"
  fi

  # Perform actions
  stow -d "$HOME/dotfiles" -t "$HOME" . 
  /usr/local/bin/git-autopush --repo dotfiles

done
