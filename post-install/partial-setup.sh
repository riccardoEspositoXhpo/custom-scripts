#!/bin/bash
source $HOME/.config/linux-toolkit/.linux-toolkit-config
source "$(dirname "$(realpath "$0")")/helpers/utilities.sh"

echo "Linux Toolkit - Partial Install"

# Ensure at least one argument is provided
if [ "$#" -eq 0 ]; then
    echo "No packages specified. Please provide a list of packages to install."
    exit 1
fi

echo "Setting up packages, configs, scripts, and files."

DIR=$(pwd)

# Read the list of packages from the text file
for package in "$@"; do

    # Skip empty lines or lines starting with '#'
    [[ -z "$package" || "$package" =~ ^# ]] && continue
 
    # ensure we always start from base directory
    cd $DIR
    PACKAGE_DIR="$DIR/$package"

    if [ ! -d "$PACKAGE_DIR" ]; then
        echo "Could not locate $PACKAGE_DIR. Skipping..."

    else 
        INSTALL_SCRIPT="$PACKAGE_DIR/install.sh"

        if [ ! -f "$INSTALL_SCRIPT" ]; then
            echo "Could not locate $INSTALL_SCRIPT. Skipping..."  

        else 
            # ensure we are installing from the package directory
            cd $PACKAGE_DIR
            sh "./install.sh"
        fi
    fi

done

echo "Congratulations. All relevant packages have been installed, and all relevant configs and files are in their appropriate locations."
exit 0
