#!/bin/bash

# This file contains commonly used utilities across projects

# Function to locate a git repository by name
find_repo_by_name() {
    # Use the `find` command to search for a directory with a .git folder and the given name
    REPO_PATH=$(find / -type d -name "$CUSTOM_REPO_NAME" -exec test -e "{}/.git" ';' -print 2>/dev/null | head -n 1)
    echo "$REPO_PATH"
}
