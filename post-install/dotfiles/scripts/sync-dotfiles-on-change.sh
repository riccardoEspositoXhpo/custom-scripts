#!/bin/bash

inotifywait -m -r -e create,modify --format '%w%f' $HOME/dotfiles | while read file

do
  echo "$file has been changed."
  stow -d $HOME/dotfiles -t $HOME . 
  /usr/local/bin/git-autopush --repo dotfiles
done
