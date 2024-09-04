#!/bin/bash

VALID_OPTION=false
while [["$VALID_OPTION" == false]]; do
    echo "Which aur helper would you like to install?"
    echo "1 - yay"
    echo "2 - paru"

    read ANSWER

    if [[ $ANSWER -eq [1]]]; then
        $VALID_OPTION=true
        echo "Installing yay"
        git clone https://aur.archlinux.org/yay.git ~/yay
        makepkg -C ~/yay -si
        aurhelper="yay" 

    elif [[ $ANSWER -eq [2]]]; then
        $VALID_OPTION=true
        echo "Installing paru"
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git ~/paru
        makepkg -C ~/paru -si
        aurhelper="paru"

    else 
        echo "Invalid option $ANSWER, please pass 1 or 2 or terminate the script."
    fi
done

echo "$aurhelper successfully installed.