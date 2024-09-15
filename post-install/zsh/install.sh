#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

setup_dotfiles() {
    info "Setting up dotfiles repo"
    
    cd "../dotfiles"
    sh install.sh 

}

no_setup() {
    info "No dotfiles will be set up"
}

echo "Cloning configuration files"

prompt_options  "Would you like to clone dotfile configs and set up symlinks?" \
    "Yes" setup_dotfiles \
    "No"  no_setup


info "Setting default shell to ZSH for $(whoami) and root user."

chsh -s /bin/zsh
sudo chsh -s /bin/zsh

warning "It is suggested to start a new terminal session to see all changes reflected."

script_exit

