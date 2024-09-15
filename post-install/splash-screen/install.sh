#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

# Path to your GRUB config file
GRUB_CONFIG="/etc/default/grub"

# Function to modify the GRUB config, either with or without sudo
modify_grub_config() {
    local cmd=$1
    if [ -w "$GRUB_CONFIG" ]; then
        # If writeable, just execute the command
        eval "$cmd"
    else
        # If not writeable, escalate with sudo
        sudo bash -c "$cmd"
    fi
}

# Extract the current GRUB_CMDLINE_LINUX_DEFAULT value
current_cmdline=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_CONFIG")

# Check if "splash" is the last word
if [[ "$current_cmdline" =~ \ .*splash\"$ ]]; then
    success "Splash is already the last argument. No changes needed."
else
    echo "Adding splash to GRUB_CMDLINE_LINUX_DEFAULT..."
    # Add "splash" to the end
    updated_cmdline=$(echo "$current_cmdline" | sed 's/"$/ splash"/')

    # Command to replace the old line with the new one in the grub config
    cmd="sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|$updated_cmdline|' $GRUB_CONFIG"

    # Modify the GRUB config file, using sudo if necessary
    modify_grub_config "$cmd"

    success "splash added to GRUB_CMDLINE_LINUX_DEFAULT."
    echo "New GRUB_CMDLINE_LINUX_DEFAULT: $updated_cmdline"
fi


info "Setting plymouth theme"

sudo plymouth-set-default-theme -R neat

install_files config

# update the grub config
if [ -w "$GRUB_CONFIG" ]; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

script_exit
