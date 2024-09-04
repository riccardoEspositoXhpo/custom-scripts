#!/bin/bash

# Installs git helpers to local bin folder
# TODO: Note, this can be re-run on every update of linux-toolkit bro

# Set PATH so it includes user's private bin and ensure it exists
LOCAL_BIN="/usr/local/bin"

SCRIPTS_DIR="./scripts"

shopt -s nullglob

for file in "$SCRIPTS_DIR"/*.sh; do
    # Remove the .sh extension from the filename
    filename=$(basename "$file" .sh)
    
    # Symlink file to the local bin path with the new name and make it executable
    install -Dm 755 "$file" "$LOCAL_BIN/$filename"

    # Commenting because you can probably trust the install script to be honest...
    # if command -v "$filename" >/dev/null 2>&1; then
    #     echo "$filename is installed and executable"
    # else
    #     echo "$filename is not installed or not executable! Exiting script"
    #     exit 1
    # fi

done

shopt -u nullglob

# Success
exit 0
