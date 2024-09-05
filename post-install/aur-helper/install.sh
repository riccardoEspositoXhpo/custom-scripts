#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init

echo "Trying to detect existing aur helper installation"
if pacman -Qi yay &>/dev/null ; then
    aurhelper="yay"
    echo "Detected aur helper $aurhelper. Exiting script successfully"
    script_exit
elif pacman -Qi paru &>/dev/null ; then
    aurhelper="paru"
    echo "Detected aur helper $aurhelper. Exiting script successfully"
    script_exit
else
    echo  "No aur helper detected. Proceeding to next step"
fi

# define custom functions for answer
install_yay() {
    echo "Installing yay"
    git clone https://aur.archlinux.org/yay.git ~/yay
    makepkg -C ~/yay -si
    aurhelper="yay" 
    echo "Removing install directory for $aurhelper" 
    rm -rf ~/$aurhelper

}

install_paru() {
    echo "Installing paru"
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git ~/paru
    makepkg -C ~/paru -si
    aurhelper="paru"
    echo "Removing install directory for $aurhelper" 
    rm -rf ~/$aurhelper

}


prompt_options "Which AUR helper would you like to install?" \
    "yay" install_yay \
    "paru" install_paru



script_exit