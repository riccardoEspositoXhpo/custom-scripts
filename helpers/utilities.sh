#!/bin/bash

# This script collects shared functions and utilities

# Color and formatting codes
RESET="\033[0m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"

# Generalized functions for formatted output
header() {
    echo -e "${BOLD}${BLUE}==> $1${RESET}"
}

success() {
    echo -e "${GREEN}✔ $1${RESET}"
}

error() {
    echo -e "${RED}✘ $1${RESET}"
}

warning() {
    echo -e "${YELLOW}! $1${RESET}"
}

info() {
    echo -e "${BOLD}$1${RESET}"
}


command_exists() {
    command -v "$1" >/dev/null 2>&1
}



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
    DEPENDENCIES="$(dirname "$(realpath "$0")")/dependencies.txt" # the script assumes that dependencies are stored in the same folder

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
                sudo pacman -S --needed "$package" < /dev/tty
                echo "- $package" >> $PACMAN_INSTALLED
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
                    "$aurhelper" -S --needed --noconfirm "$package" < /dev/tty
                    echo "- $package" >> $AUR_INSTALLED
                fi
            else
                echo "Package $package not found either in pacman or in $aurhelper. Please check, skipping for now..."
            fi
        fi
    done < "$DEPENDENCIES"


    if [ -s "$PACMAN_INSTALLED" ]; then

        echo "The following packages were installed with pacman:"
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
            read -p "The target file cannot be overwritten. Do you want to proceed with elevated permissions? (Y/y to proceed): " response < /dev/tty

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





# install configurations in the target directory based on a metadata file containing source and target location, and permissions. 
# Takes the install folder as argument
install_files() {

    # Get the path to the current script's directory
    local SCRIPT_DIR=$(dirname "$(realpath "$0")")
    local ASSET_DIR="$SCRIPT_DIR/$1"
    local METADATA_FILE="$ASSET_DIR/metadata.txt"

    # add newline to file if it doesn't exist. Necessary to use read command
    sed -i -e '$a\' $METADATA_FILE

    # Ensure the config directory and metadata file exist
    if [ ! -d "$ASSET_DIR" ]; then
        echo "No config directory found in $SCRIPT_DIR"
        return 1
    fi

    if [ ! -f "$METADATA_FILE" ]; then
        echo "Metadata file not found in $ASSET_DIR"
        return 1
    fi

    # Loop through each line of the metadata file
    while IFS=' ' read -r src_file tgt_file permissions; do
        # Skip empty lines or comments
        [[ -z "$src_file" || "$src_file" == \#* ]] && continue

        # Construct the full path to the source file
        local SRC_PATH="$ASSET_DIR/$src_file"

        # Check if the source file exists
        if [ ! -f "$SRC_PATH" ]; then
            echo "Source file not found: $SRC_PATH"
            continue
        fi

        # Install the config file to the target path with specified permissions
        echo "Installing $SRC_PATH to $tgt_file with permissions $permissions"
        install_file "$SRC_PATH" "$tgt_file" "install -C -D -m $permissions"
    done < "$METADATA_FILE"
}


pause_and_open_app() {
    
    app="$1"
    options="$2"
    
    echo "Pausing installation to open $app."
    echo "Installation instructions provided below:"
    echo ""
    echo "$options"
    echo ""

    echo "Opening $app for you. Once installation is complete, close the application and return here."

    $app

    local VALID_OPTION=false
    while [[ "$VALID_OPTION" == false ]]; do
        echo "App was closed. Have you completed the installation?"
        echo "1 - Yes"
        echo "2 - No, open $app again for me"

        read -p "Answer: " ANSWER < /dev/tty 
        
        if [[ "$ANSWER" = 1 ]]; then
            VALID_OPTION=true
        elif [[ "$ANSWER" = 2 ]]; then
            echo "Opening $app"
            $app
        else
            echo "Invalid option $ANSWER, please choose 1 or 2."
        fi
    done

}


