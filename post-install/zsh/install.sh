#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init
install_dependencies

setup_dotfiles() {
    echo "Setting up dotfiles repo"
    mkdir -p ~/git/dotfiles
    git clone https://github.com/riccardoEspositoXhpo/dotfiles.git ~/git/dotfiles
    INSTALL_SCRIPT="~/git/dotfiles/install.sh"
    chmod +x $INSTALL_SCRIPT
    echo "Running install script at $INSTALL_SCRIPT."
    $INSTALL_SCRIPT

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

