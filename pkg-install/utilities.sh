#!/bin/bash

# This script collects shared functions and utilities

script_init() {

    # enables Ctrl + C to kill script
    trap 'echo "Script interrupted. Cleaning up..."; kill 0; exit 1' SIGINT

    # Get the directory name where the script is located
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Extract the last directory name. This is the name of the script
    PARENT_DIR=$(basename "$SCRIPT_DIR")

    PARENT_DIR_LENGTH=${#PARENT_DIR}

    # Calculate the number of spaces needed to make the total length 10
    NUM_SPACES=$((28 - PARENT_DIR_LENGTH))

    # Ensure NUM_SPACES is not negative
    if ((NUM_SPACES < 0)); then
        NUM_SPACES=0
    fi

    # Generate the spaces
    SPACES=$(printf '%*s' "$NUM_SPACES")
    
    echo ""
    echo "###############################################################"
    echo "####                                                       ####"
    echo "####  Starting installation of $PARENT_DIR$SPACES####"                   
    echo "####                                                       ####"
    echo "###############################################################"
    echo ""

}

script_exit() {

    # Get the directory name where the script is located
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Extract the last directory name. This is the name of the script
    PARENT_DIR=$(basename "$SCRIPT_DIR")

    echo "Installation of $PARENT_DIR completed successfully. Enjoy!"

    exit 0

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

    # Read the list of packages from the text file
    AUR_HELP_MSG=true
    while read package; do

        if pacman -Ss "$package" &> /dev/null; then

            if pacman -Qs "$package" $> /dev/null; then
                echo "$package is already installed."
            else  
                # Install the package using pacman
                sudo pacman -S --needed "$package"
                echo "$package" >> $PACMAN_INSTALLED
            fi
        else

            # we need to ceck if you have an AUR helper installed.
            if [ $AUR_HELP_MSG = true ]; then

                if pacman -Qi yay &>/dev/null ; then
                    aurhelper="yay"
                    echo "Aur helper $aurhelper detected"
                    AUR_HELP_MSG=false # only display help message once
                elif pacman -Qi paru &>/dev/null ; then
                    aurhelper="paru"
                    echo "Aur helper $aurhelper detected"
                    AUR_HELP_MSG=false # only display help message once
                else
                    echo "Neither yay nor paru aur helpers are detected. Please install one of the two. Exiting."
                    exit 1
                fi
            fi

            if "$aurhelper" -Ss "$package" &> /dev/null; then

                if "$aurhelper" -Qs "$package" &> /dev/null; then
                    echo "$package is already installed."
                else
                    "$aurhelper" -S --needed --noconfirm "$package"
                    echo "$package" >> $AUR_INSTALLED
                fi
            else
                echo "Package $package not found either in pacman or in $aurhelper. Please check, skipping for now..."
            fi
        fi
    done < "$DEPENDENCIES"


    if [ -s "$PACMAN_INSTALLED" ]; then

        echo "The following packages were installed with pacman:"
        # TODO: cat or echo? not sure if I can exit interactively here bro 
        cat $PACMAN_INSTALLED
        echo ""
        rm $PACMAN_INSTALLED
    fi

    if [ -s "$AUR_INSTALLED" ]; then

        echo "The following packages were installed with yay:"
        cat $AUR_INSTALLED
        echo ""
        rm $AUR_INSTALLED
    fi

}


# Prompt user for a choice and execute code based on result
prompt_options() {
    # First argument is the prompt message
    local prompt_message="$1"
    shift

    # Remaining arguments are options and corresponding actions (functions or code blocks)
    local -a options=()
    local -a actions=()
    
    while [[ $# -gt 0 ]]; do
        options+=("$1")
        actions+=("$2")
        shift 2
    done

    local VALID_OPTION=false

    while [[ "$VALID_OPTION" == false ]]; do
        echo "$prompt_message"
        for i in "${!options[@]}"; do
            echo "$(($i + 1)) - ${options[$i]}"
        done

        read -p "Please enter your choice: " ANSWER

        if [[ $ANSWER -gt 0 && $ANSWER -le ${#options[@]} ]]; then
            VALID_OPTION=true
            # Execute the corresponding function or code block
            ${actions[$((ANSWER - 1))]}
        else
            echo "Invalid option $ANSWER, please choose a valid option."
        fi
    done
}
