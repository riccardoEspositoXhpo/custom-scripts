#!/bin/bash

# This script collects shared functions and utilities

script_init() {

    # enables Ctrl + C to kill script
    trap 'echo "Script interrupted. Cleaning up..."; kill 0; exit 1' SIGINT

    # Get the directory name where the script is located
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Extract the last directory name. This is the name of the script
    PARENT_DIR=$(basename "$SCRIPT_DIR")

    echo "Starting installation of $PARENT_DIR"

}


install_dependencies() {

    echo "Installing dependencies"
    PACMAN_INSTALLED='/tmp/pacman-installed.txt'
    AUR_INSTALLED='/tmp/aur-installed.txt'
    DEPENDENCIES="dependencies.txt" # the script assumes that dependencies are stored in the same folder

    if [ ! -f "$DEPENDENCIES" ]; then
        echo "Dependency file not found in $DEPENDENCIES. Exiting..."
        exit 1
    fi

    if ! command -v pacman &> /dev/null; then
        echo "pacman is not installed. Something is terribly wrong."
        exit 1
    fi

    if [ -n "$aurhelper" ]; then
        echo "Using $aurhelper as aur-helper"
    else 
        echo "No aur helper detected."
        exit 1
    fi

    # Read the list of packages from the text file
    while read package; do
        if sudo pacman -Ss "$package" &> /dev/null; then
            # Install the package using pacman
            sudo pacman -S --needed "$package"
            echo "$package" >> $PACMAN_INSTALLED

        elif

            # we need to ceck if you have an AUR helper installed.
            if pacman -Qi yay &>/dev/null ; then
                aurhelper="yay"
            elif pacman -Qi paru &>/dev/null ; then
                aurhelper="paru"
            else
                echo "Neither yay nor paru aur helpers are detected. Please install one of the two. Exiting."
                exit 1
            fi

            # Install the package using the AUR helper
            echo "Aur helper $aurhelper detected"
            "$aurhelper" -S --needed --noconfirm "$package"
            echo "$package" >> $AUR_INSTALLED
        else
            echo "Package $package not found either in pacman or in $aurhelper. Please check spelling, skipping for now..."
        fi
    done < "$DEPENDENCIES"

    echo "The following packages were installed with pacman:"
    # TODO: cat or echo? not sure if I can exit interactively here bro 
    cat $PACMAN_INSTALLED
    echo ""

    echo "The following packages were installed with yay:"
    cat $AUR_INSTALLED
    echo ""

    # Remove the temporary files
    rm $PACMAN_INSTALLED $YAY_INSTALLED

}
