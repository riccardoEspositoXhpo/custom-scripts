#!/bin/bash

# Add new file to dotfiles git repository
dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

for var in "$@"
do
    echo "Adding $var to dotfiles backup"
    $dotfiles add $var
    $dotfiles commit -m "Backing up $var"
    $dotfiles push
done

echo "Backup successful. Exiting script"