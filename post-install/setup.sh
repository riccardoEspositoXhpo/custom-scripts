#!/bin/bash
source $HOME/.config/linux-toolkit/.linux-toolkit-config
source $LINUX_TOOLKIT_UTILITIES

# display fancy logo
toolkit_init
info "Full install"

# Installer supports a custom install-order file for selective app installation.
INSTALL_ORDER="${1:-./install-order.txt}"

# ensure file ends with a newline
sed -i -e '$a\' $INSTALL_ORDER

header "Setting up packages, configs, scripts and files according to the order defined in $INSTALL_ORDER."

DIR=$(pwd)


prompt_options "Do you want to run sudo now?" "Yes, cache my sudo" cache_sudo "No, I want to choose when to apply sudo" continue 


# Read the list of packages from the text file
while read package; do

    # Skip empty lines or lines starting with '#'
    [[ -z "$package" || "$package" =~ ^# ]] && continue

    display_countdown 3 
    # ensure we always start from base directory
    cd $DIR
    PACKAGE_DIR="$DIR/$package"

    if [ ! -d "$PACKAGE_DIR" ]; then
        warning "Could not locate $PACKAGE_DIR. Skipping..."

    else 
        INSTALL_SCRIPT="$PACKAGE_DIR/install.sh"

        if [ ! -f "$INSTALL_SCRIPT" ]; then
            warning "Could not locate $INSTALL_SCRIPT. Skipping..."  

        else 
            # ensure we are installing from the package directory
            cd $PACKAGE_DIR
            sh "./install.sh"
            
        fi
    fi

done < "$INSTALL_ORDER"

success "Congratulations!" 
success "All relevant packages have been installed. "
success "All relevant configs and files are in their appropriate locations."
success "Enjoy!"
exit 0
