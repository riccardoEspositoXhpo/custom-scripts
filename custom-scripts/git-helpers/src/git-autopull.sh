#!/bin/bash

# Function to locate a git repository by name
find_repo_by_name() {
    # Use the `find` command to search for a directory with a .git folder and the given name
    REPO_PATH=$(find / -type d -name "$1" -exec test -e "{}/.git" ';' -print 2>/dev/null | head -n 1)
    echo "$REPO_PATH"
}

# Check if a repository name was passed as an argument
if [ -n "$1" ]; then
    # Find the repository by name
    REPO_PATH=$(find_repo_by_name "$1")

    if [ -n "$REPO_PATH" ]; then
        # If a repository is found, navigate to it
        echo "Found repository: $REPO_PATH"
        cd "$REPO_PATH" || { echo "Directory not found: $REPO_PATH"; exit 1; }
    else
        # If no repository is found, report an error and exit
        echo "Repository '$1' not found."
        exit 1
    fi
else
    # If no argument is passed, use the current directory
    DIR="$(dirname "$(realpath "$0")")"
    cd "$DIR" || { echo "Directory not found: $DIR"; exit 1; }
fi

# Pull the latest changes from the remote repository
git pull origin "$(git rev-parse --abbrev-ref HEAD)"

# Output success message
echo "Repository updated successfully."