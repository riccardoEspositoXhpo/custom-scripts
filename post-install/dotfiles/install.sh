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
if ! command_exists git-autopush; then
    error "git-autopush not installed. Exiting ..."
    exit 1
fi

if ! command_exists git-autopull; then
    error "git-autopull not installed. Exiting ..."
    # install it actually... 
    exit 1
fi

success "git-autopush and git-autopull are installed."


USERNAME=$(whoami)
info "Adding $USERNAME to systemd services"

FILES=("dotfiles-pull.service" "dotfiles-sync.service")

for file in "${FILES[@]}"; do
    sed -i "s/User=root/User=$USERNAME/"  "./scripts/$file" 
done



install_files scripts
install_files config


info "Refreshing systemd services"
sudo systemctl daemon-reload

start_systemd dotfiles-sync.service
start_systemd dotfiles-pull.service

script_exit