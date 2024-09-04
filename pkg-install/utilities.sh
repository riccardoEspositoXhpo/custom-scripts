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

start_systemd() {
    echo "Enabling and starting systemctl service: $1"
    systemctl enable --now "$1"

}

install_dependencies() {

    echo "Installing dependencies"
    PACMAN_INSTALLED='/tmp/pacman-installed.txt'
    AUR_INSTALLED='/tmp/aur-installed.txt'
    DEPENDENCIES="dependencies.txt" # the script assumes that dependencies are stored in the same folder

    # add newline to file if it doesn't exist. Necessary to use read command
    sed -i -e '$a\' $DEPENDENCIES

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
            echo "$((i + 1)) - ${options[$i]}"
        done

        read -p "Please enter your choice: " ANSWER < /dev/tty
        # Check if ANSWER is a valid number and within the options range
        if [[ "$ANSWER" =~ ^[0-9]+$ && "$ANSWER" -gt 0 && "$ANSWER" -le ${#options[@]} ]]; then
            VALID_OPTION=true
            # Execute the corresponding function or code block
            local action="${actions[$((ANSWER - 1))]}"
            eval "$action"
        else
            echo "Invalid option $ANSWER, please choose a valid option."
        fi
    done
}

# a wrapper around the install script. It checks whether the target exists and prompts the user to overwrite it.
install_file() {
    local source_file="$1"
    local target_file="$2"
    local base_command="$3"

    # Construct the full install command
    local full_command="$base_command $source_file $target_file"

    # Try to run the install command normally
    if $full_command; then
        echo "Successfully installed $target_file"
        return 0
    else
        # Check if the issue is related to permissions
        if [[ $? -ne 0 ]]; then
            echo "Failed to install $target_file, likely due to lack of permissions."
            read -p "The target file cannot be overwritten. Do you want to proceed with elevated permissions? (Y/y to proceed): " response

            if [[ "$response" =~ ^[Yy]$ ]]; then
                # Re-run the command with sudo
                echo "Attempting to install $target_file with sudo..."
                sudo $full_command
                if [[ $? -eq 0 ]]; then
                    echo "Successfully installed $target_file with elevated permissions"
                    return 0
                else
                    echo "Failed to install $target_file even with elevated permissions."
                    return 1
                fi
            else
                echo "Installation of $target_file aborted by user."
                return 1
            fi
        fi
    fi
}

# installs every configuration file found in ./config directory according to directories and permissions found in the file header.
install_configs() {
    # Get the path to the current script's directory
    local SCRIPT_DIR=$(dirname "$(realpath "$0")")
    local CONFIG_DIR="$SCRIPT_DIR/config"

    # Ensure the config directory exists
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "No config directory found in $SCRIPT_DIR"
        return 1
    fi

    # Loop through all files in the config directory
    for config_file in "$CONFIG_DIR"/*; do
        # Read the metadata at the top of the config file
        local TARGET_DIR=$(grep '^# Target Directory:' "$config_file" | cut -d ' ' -f 4-)
        local PERMISSIONS=$(grep '^# Permissions:' "$config_file" | cut -d ' ' -f 3-)

        # Extract the filename from the config file
        local FILE_NAME=$(basename "$config_file")

        # Check if target directory and permissions were found
        if [ -z "$TARGET_DIR" ] || [ -z "$PERMISSIONS" ]; then
            echo "Skipping $config_file: Missing Target Directory or Permissions metadata."
            continue
        fi

        # Construct the full target path
        local TARGET_PATH="$TARGET_DIR/$FILE_NAME"

        # Install the config file to the target path with specified permissions
        echo "Installing $config_file to $TARGET_PATH with permissions $PERMISSIONS"
        install_file  "$config_file" "$TARGET_PATH" "install -C -D -m $PERMISSIONS"
    done
}
