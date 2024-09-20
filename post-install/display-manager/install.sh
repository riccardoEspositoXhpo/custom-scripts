#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

install_files config
install_files files

SECONDS=5
success "Sddm-greeter installed successfully."

run() {
    sddm-greeter --test-mode --theme /usr/share/sddm/themes/Sugar-Candy
}

display_countdown $SECONDS run
 
script_exit


