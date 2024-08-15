#!/bin/bash

# Delete file to dotfiles git repository
dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

for var in "$@"
do
    echo "Deleting $var from dotfiles backup"
    $dotfiles rm -r $var
    $dotfiles commit -m "Deleting $var"
    $dotfiles push
done

echo "Removal successful. Exiting script"