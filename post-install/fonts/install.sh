#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

FONT_NAME="JetBrainsMono"
info "Downloading $FONT_NAME font..."
# Fetch the latest JetBrainsMono.zip download URL
url=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep "browser_download_url" | grep "$FONT_NAME.zip" | cut -d '"' -f 4)

# Download the latest JetBrainsMono.zip
curl -L -o /tmp/$FONT_NAME.zip "$url"

info "Extracting $FONT_NAME to local fonts dir"
unzip /tmp/$FONT_NAME.zip -d /tmp/$FONT_NAME

if [ ! -d "$HOME/.local/share/fonts" ]; then
    mkdir -p "$HOME/.local/share/fonts"
fi

cp -r "/tmp/$FONT_NAME" "$HOME/.local/share/fonts/"

info "Refreshing font cache"
fc-cache


script_exit
