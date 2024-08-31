#!/bin/bash

# variables
ZSH_DEPENDENCIES="./zsh-dependencies.txt"
PACMAN_INSTALLED="/tmp/pacman_installed.txt"
YAY_INSTALLED="/tmp/yay_installed.txt"

# Instantly prompt for sudo password to avoid hassle
echo "Prompting for sudo password..."
sudo -v

echo "Beginning zsh install..."


echo "Step 1 - installing dependencies"
# Check if pacman and the AUR helper are installed
if ! command -v pacman &> /dev/null; then
    echo "pacman is not installed."
    exit 1
fi

if ! command -v yay &> /dev/null; then
    echo "yay is not installed."
    exit 1
fi

# Read the list of packages from the text file
while read package; do
    # Check if the package is in the official repositories
    if pacman -Ss "$package" &> /dev/null; then
        # Install the package using pacman
        sudo pacman -S --needed "$package"
        echo "$package" >> $PACMAN_INSTALLED

    else
        # Install the package using the AUR helper
        yay -S --needed --noconfirm "$package"
        echo "$package" >> $YAY_INSTALLED

    fi
done < "$ZSH_DEPENDENCIES"

echo "The following packages were installed with pacman:"
cat $PACMAN_INSTALLED
echo ""

echo "The following packages were installed with yay:"
cat $YAY_INSTALLED
echo ""

# Optionally, remove the temporary files
rm $PACMAN_INSTALLED $YAY_INSTALLED

# ------------------------------------------------------------ # 

echo "Step 2 - Cloning configuration files"

VALID_OPTION=false

while [["$VALID_OPTION" == false]]; do
    echo "Would you like to clone configurations and set up symlinks?"
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
        echo "Invalid option $CLONE_CONFIG, please pass Y o N."
    fi
done

# git clone https://github.com/riccardoEspositoXhpo/dotfiles.git ~/git/dotfiles

# ------------------------------------------------------------ # 

echo "Step 3 - Backing up any existing files"





# ------------------------------------------------------------ # 

echo "Step 4 - Setting up symlinks"











echo "Step 5 - Enjoy!"