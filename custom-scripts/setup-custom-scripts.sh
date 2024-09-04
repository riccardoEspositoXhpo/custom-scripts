#!/bin/bash

source ../utilities.sh

echo "Installing custom scripts"

LOCAL_BIN="/usr/local/bin"
SCRIPTS_DIR="./scripts"

shopt -s nullglob

for file in "$SCRIPTS_DIR"/*.sh; do
    # Remove the .sh extension from the filename
    filename=$(basename "$file" .sh)
    sudo install -C -D -m 755 "$file" "$LOCAL_BIN/$filename"
    echo "Installed $LOCAL_BIN/$filename"
done

shopt -u nullglob

# Success
echo "Custom scripts installed successfully"
exit 0


