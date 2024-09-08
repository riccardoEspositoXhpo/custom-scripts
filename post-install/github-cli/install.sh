#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init 
install_dependencies

# Post installation configuration

# log in to github-cli to cache credentials
if gh auth status > /dev/null 2>&1; then
    echo "You are logged in to GitHub."
else
    echo "You are NOT logged in to GitHub. Logging in."
    gh auth login
fi

echo "Confirming login status."
gh auth status  

script_exit

