#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

CURRENT_DIR="$(dirname "$(realpath "$0")")"

DOTFILES_DIR="$HOME/dotfiles"
header "Cloning the dotfiles repo to $DOTFILES_DIR"
mkdir -p $DOTFILES_DIR
git clone https://github.com/riccardoEspositoXhpo/dotfiles.git $DOTFILES_DIR

info "Check if required scripts are installed"
if ! command_exists git-autopush || ! command_exists git-autopull; then
    warning "git helpers not installed. Installing now..."
    cd ../custom-scripts
    sh install.sh
fi

# back to this dir for install
cd $CURRENT_DIR

success "git-autopush and git-autopull are installed."

install_files config
install_files scripts

info "Refreshing systemd services"

sudo systemctl daemon-reload
start_systemd dotfiles-sync.service user
start_systemd dotfiles-pull.service user

script_exit