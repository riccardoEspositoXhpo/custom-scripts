#!/bin/bash

# This script sets up a git repo to manage dotfiles from scratch

# Tutorial: https://www.atlassian.com/git/tutorials/dotfiles

## Assumptions: You have set up a git repo caled dotfiles.git
echo "Setting up dofiles git repo and alias from scratch." 
echo "Creating directory" 
mkdir $HOME/.dotfiles 
echo "Initializing bare git repo. Your home directory hosts the files to be committed." 
git init --bare $HOME/.dotfiles  
echo "Creating an function 'dotfiles'. Use this instead of git when committing a file to the new repo"
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' >> ~/.bashrc"

$dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
echo "Removing untracked files".
$dotfiles config --local status.showUntrackedFiles no


echo "Please select a file name to commit to test the repo. i.e. .bashrc"
read FIRST_FILE

echo "Constructing github link."
echo "What is your userId? i.e. this is the path for your repositories"
read REPO_USER_ID
echo "What is your repository name? i.e. if the repo is 'dotfiles.git', please input 'dotfiles' only."
read REPO_ID

REPO=https://github.com/"$REPO_USER_ID"/"${REPO_ID}".git

echo "setting up $FIRST_FILE in repo $REPO"

cd $HOME
$dotfiles add $FIRST_FILE
$dotfiles commit -m "Add $FIRST_FILE"
$dotfiles remote add origin $REPO
$dotfiles push --set-upstream origin master

