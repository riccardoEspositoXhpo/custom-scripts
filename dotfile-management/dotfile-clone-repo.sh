#!/bin/bash

echo "Constructing github link."
echo "What is your userId? i.e. this is the path for your repositories"
read REPO_USER_ID
echo "What is your repository name? i.e. if the repo is 'dotfiles.git', please input 'dotfiles' only."
read REPO_ID

REPO=https://github.com/"$REPO_USER_ID"/"${REPO_ID}".git
echo "Cloning new git repo into temporary folder."
git clone --separate-git-dir=$HOME/.dotfiles $REPO dotfile-restore-backup

echo "Migrating configs in $HOME directory"
rsync --recursive --verbose --exclude '.git' dotfile-restore-backup/ $HOME/
rm -rf dotfile-restore-backup
