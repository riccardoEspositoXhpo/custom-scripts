#!/bin/bash

# does this work?
source "../utilities.sh"

# Trap SIGINT (Ctrl+C) and clean up
trap 'echo "Script interrupted. Cleaning up..."; kill 0; exit 1' SIGINT

# TODO: I literally have no clue how to climb up
echo "Beginning $(dirname $0) install..." # it should print zsh

install_dependencies()


echo "Cloning configuration files"

VALID_OPTION=false

while [["$VALID_OPTION" == false]]; do
    echo "Would you like to clone dotfile configs and set up symlinks?"
    echo "[Y] - yes, set up symlinks"
    echo "[N] - no, I already have my dotfiles"

    read CLONE_CONFIG

    if [[ $CLONE_CONFIG -eq [Nn]]]; then
        VALID_OPTION == true
        echo "Not cloning configs"
    elif [[ $CLONE_CONFIG -eq [Yy]]]; then
        VALID_OPTION == true
        echo "Cloning configs"
    else 
        echo "Invalid option $CLONE_CONFIG, please pass Y o N or terminate the script."
    fi
done


if [[ $CLONE_CONFIG -eq [Yy]]]; then

    mkdir -p ~/git/dotfiles
    git clone https://github.com/riccardoEspositoXhpo/dotfiles.git ~/git/dotfiles
    INSTALL_SCRIPT="~/git/dotfiles/install.sh"
    chmod +x $INSTALL_SCRIPT
    echo "Running install script at $INSTALL_SCRIPT."
    $INSTALL_SCRIPT

fi

echo "It is suggested to start a new terminal session to see all changes reflected."
echo "Installation Complete - Enjoy!"
exit 0

