#!/bin/bash

# Script to automagically update a git repo irrespective of content

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

# Check the status of the working directory
git_status=$(git status --porcelain)

if [ -z "$git_status" ]; then
    echo "No changes detected. Nothing to commit."
else
    # Stage all changes (including added, modified, and removed files)
    git add -A

    # Commit the changes with a generic message including the date and time
    commit_message="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$commit_message"

    # Push the changes to the remote repository
    git push origin "$(git rev-parse --abbrev-ref HEAD)"
    
    echo "Changes committed and pushed successfully."
fi

