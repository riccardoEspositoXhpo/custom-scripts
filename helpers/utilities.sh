#!/bin/bash

# This script collects shared functions and utilities

# Reset and formatting codes
RESET="\033[0m"
BOLD="\033[1m"
UNDERLINE="\033[4m"

# Foreground (text) colors
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

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
    echo -e "${YELLOW}!! $1${RESET}"
}

info() {
    echo -e "${BOLD}$1${RESET}"
}

# Function to colorize external command output
colorize_output() {
    while IFS= read -r line; do
        echo -e "${CYAN}${line}${RESET}"
    done
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}


toolkit_init() {
    cat <<EOF

        ██      ██ ███    ██ ██    ██ ██   ██          
        ██      ██ ████   ██ ██    ██  ██ ██           
        ██      ██ ██ ██  ██ ██    ██   ███            
        ██      ██ ██  ██ ██ ██    ██  ██ ██           
        ███████ ██ ██   ████  ██████  ██   ██          
                                                       
                                                       
████████  ██████   ██████  ██      ██   ██ ██ ████████ 
   ██    ██    ██ ██    ██ ██      ██  ██  ██    ██    
   ██    ██    ██ ██    ██ ██      █████   ██    ██    
   ██    ██    ██ ██    ██ ██      ██  ██  ██    ██    
   ██     ██████   ██████  ███████ ██   ██ ██    ██    

              
EOF

}



cache_sudo() {
    sudo -v 
}

script_init() {

    # enables Ctrl + C to kill script
    trap 'error "Script interrupted. Cleaning up..."; kill 0; exit 1' SIGINT

    # Get the directory name where the script is located
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Extract the last directory name. This is the name of the script
    PARENT_DIR=$(basename "$SCRIPT_DIR")

    
    echo ""
    info "_________________________________________________________________"
    echo ""
    echo ""
    echo -e "${BOLD}==> INSTALLING: ${GREEN}$PARENT_DIR${RESET}"                   
    echo ""
    info "_________________________________________________________________"
    echo ""

}

script_exit() {

    # Get the directory name where the script is located
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Extract the last directory name. This is the name of the script
    PARENT_DIR=$(basename "$SCRIPT_DIR")

    success "Installation of $PARENT_DIR completed successfully. Enjoy!"

    exit 0

}

start_systemd() {
    local service_name="$1"
    local service_type="${2:-system}"

    if [[ -z "$service_name" ]]; then
        error "Error: Service name is required."
        error "Usage: start_systemd <service-name> [user|system]"
        return 1
    fi

    if [[ "$service_type" != "user" && "$service_type" != "system" ]]; then
        error "Error: Invalid service type. Use 'user' or 'system'."
        return 1
    fi

    if [[ "$service_type" == "user" ]]; then
        info "Enabling and starting user systemd service: $service_name"
        systemctl --user enable --now "$service_name"
    else
        info "Enabling and starting systemd service: $service_name"
        sudo systemctl enable --now "$service_name"
    fi
}


install_dependencies() {

    header "Installing dependencies"
    PACMAN_INSTALLED='/tmp/pacman-installed.txt'
    AUR_INSTALLED='/tmp/aur-installed.txt'
    DEPENDENCIES="$(dirname "$(realpath "$0")")/dependencies.txt" # the script assumes that dependencies are stored in the same folder

    # add newline to file if it doesn't exist. Necessary to use read command
    sed -i -e '$a\' $DEPENDENCIES

    if [ ! -f "$DEPENDENCIES" ]; then
        error "Dependency file not found in $DEPENDENCIES. Exiting..."
        exit 1
    fi

    if ! command_exists pacman; then
        error "pacman is not installed. Something is terribly wrong."
        exit 1
    fi

    # Read the list of packages from the text file
    AUR_HELP_MSG=true
    while read package; do
        
        info "  ==> $package:"
        if pacman -Qs "$package" &> /dev/null; then

            if pacman -Qs "$package" $> /dev/null; then
                info "$package is already installed."
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
                    info "Aur helper $aurhelper detected"
                    AUR_HELP_MSG=false # only display help message once
                elif pacman -Qi paru &>/dev/null ; then
                    aurhelper="paru"
                    info "Aur helper $aurhelper detected"
                    AUR_HELP_MSG=false # only display help message once
                else
                    Error "Neither yay nor paru aur helpers are detected. Please install one of the two. Exiting."
                    exit 1
                fi
            fi

            if "$aurhelper" -Ss "$package" &> /dev/null; then

                if "$aurhelper" -Qs "$package" &> /dev/null; then
                    info "$package is already installed."
                else
                    "$aurhelper" -S --needed --noconfirm "$package" < /dev/tty
                    echo "- $package" >> $AUR_INSTALLED
                fi
            else
                warning "Package $package not found either in pacman or in $aurhelper. Please check, skipping for now..."
            fi
        fi
    done < "$DEPENDENCIES"


    if [ -s "$PACMAN_INSTALLED" ]; then

        info "The following packages were installed with pacman:"
        cat $PACMAN_INSTALLED
        echo ""
        rm $PACMAN_INSTALLED
    fi

    if [ -s "$AUR_INSTALLED" ]; then

        info "The following packages were installed with $aurhelper:"
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
        info "$prompt_message"
        for i in "${!options[@]}"; do
            info "$((i + 1)) - ${options[$i]}"
        done

        read -p "Answer: " ANSWER < /dev/tty
        # Check if ANSWER is a valid number and within the options range
        if [[ "$ANSWER" =~ ^[0-9]+$ && "$ANSWER" -gt 0 && "$ANSWER" -le ${#options[@]} ]]; then
            VALID_OPTION=true
            # Execute the corresponding function or code block
            local action="${actions[$((ANSWER - 1))]}"
            eval "$action"
        else
            error "Invalid option $ANSWER, please choose a valid option."
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
        success "Successfully installed $target_file"
        return 0
    else
        # Check if the issue is related to permissions
        if [[ $? -ne 0 ]]; then
            warning "Failed to install $target_file."
            warning "Do you want to retry with elevated permissions?"
            read -p " (Y/y to proceed): " response < /dev/tty

            if [[ "$response" =~ ^[Yy]$ ]]; then
                # Re-run the command with sudo
                echo "Attempting to install $target_file with sudo..."
                sudo $full_command
                if [[ $? -eq 0 ]]; then
                    success "Successfully installed $target_file with elevated permissions"
                    return 0
                else
                    error "Failed to install $target_file even with elevated permissions."
                    return 1
                fi
            else
                error "Installation of $target_file aborted by user."
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
        error "No config directory found in $SCRIPT_DIR"
        return 1
    fi

    if [ ! -f "$METADATA_FILE" ]; then
        error "Metadata file not found in $ASSET_DIR"
        return 1
    fi

    # Loop through each line of the metadata file
    while IFS=' ' read -r src_file tgt_file permissions; do
        # Skip empty lines or comments
        [[ -z "$src_file" || "$src_file" == \#* ]] && continue

        # expand any variables in source of target file
        src_file=$(expand_vars $src_file)
        tgt_file=$(expand_vars $tgt_file)

        # Construct the full path to the source file
        local SRC_PATH="$ASSET_DIR/$src_file"

        # Check if the source file exists
        if [ ! -f "$SRC_PATH" ]; then
            warning "Source file not found: $SRC_PATH"
            continue
        fi

        # Install the config file to the target path with specified permissions
        info "Installing $src_file to $tgt_file with permissions $permissions"
        install_file "$SRC_PATH" "$tgt_file" "install -C -D -m $permissions"
    done < "$METADATA_FILE"
}


expand_vars() {
    local input="$1"
    
    # Use printf to handle the expansion
    local expanded
    expanded=$(printf "%s" "$input" | xargs -I{} bash -c 'echo {}')
    
    echo "$expanded"
}


pause_and_open_app() {
    
    app="$1"
    options="$2"

    
    echo "Pausing installation to open $app."
    echo "Installation instructions provided below:"
    echo ""
    echo "$options"
    echo ""

    echo "Opening $app for you. Once complete, close the application and return here."

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
            eval $app
        else
            error "Invalid option $ANSWER, please choose 1 or 2."
        fi
    done

}


display_countdown() {
    local seconds=$1
    local func=$2

    echo "Running function in $1 seconds."

    if [ -n "$func" ]; then
        echo "Content of the function:"
        declare -f "$func"
    fi

    echo "... press any key to skip this step ... "

    while [ "$seconds" -gt 0 ]; do
        echo "$seconds..."
        read -t 1 -n 1 key  < /dev/tty # Wait for 1 second or user input
        if [ $? -eq 0 ]; then
            echo ""
            warning "Countdown interrupted"
            return
        fi
        ((seconds--))
    done

    # Execute the function if it is provided
    if [ -n "$func" ]; then
        eval "$func"
    fi
}

