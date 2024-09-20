#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init

header "Trying to detect existing aur helper installation"
if pacman -Qi yay &>/dev/null ; then
    aurhelper="yay"
    success "Detected aur helper $aurhelper. Exiting script successfully"
    script_exit
elif pacman -Qi paru &>/dev/null ; then
    aurhelper="paru"
    success "Detected aur helper $aurhelper. Exiting script successfully"
    script_exit
else
    warning  "No aur helper detected. Proceeding to next step"
fi

# define custom functions for answer
install_yay() {
    info "Installing yay"
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
    makepkg -C -si
    aurhelper="yay" 
    info "Removing install directory for $aurhelper" 
   # rm -rf ~/$aurhelper

}

install_paru() {
    info "Installing paru"
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git ~/paru
    cd ~/paru
    makepkg -C -si
    aurhelper="paru"
    info "Removing install directory for $aurhelper" 
    rm -rf ~/$aurhelper

}


prompt_options "Which AUR helper would you like to install?" \
    "yay" install_yay \
    "paru" install_paru



script_exit
