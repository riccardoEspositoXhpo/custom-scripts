#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

# TODO - fix this with new dotfile management. seems insane!! cioé lancia il dotfiles installer in pratica con un cd e poi cd back here ... bleh.
setup_dotfiles() {
    echo "Setting up dotfiles repo"
    
    # TBD - kick off the partial install with dotfiles, or something else


}

no_setup() {
    echo "No dotfiles will be set up"
}

echo "Cloning configuration files"

prompt_options  "Would you like to clone dotfile configs and set up symlinks?" \
    "Yes" setup_dotfiles \
    "No"  no_setup


echo "Setting default shell to ZSH for $(whoami) and root user."

chsh -s /bin/zsh
sudo chsh -s /bin/zsh

echo "It is suggested to start a new terminal session to see all changes reflected."

script_exit

