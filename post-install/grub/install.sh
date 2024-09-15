#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

THEME="Xenlism-Arch"
TARGET_DIR="/usr/share/grub/themes/$THEME"


run() {
    sh /tmp/xenlism-grub-arch-1080p/install.sh
}

install_theme() {
    info "Downloading and installing Xenlism-arch grub theme..."
    curl -L -o /tmp/xenlism-grub-arch-1080p.tar.xz https://raw.githubusercontent.com/xenlism/Grub-themes/main/xenlism-grub-arch-1080p.tar.xz
    tar -xf /tmp/xenlism-grub-arch-1080p.tar.xz -C /tmp 
    display_countdown 5 run
}


if [ -d $TARGET_DIR ]; then
    prompt_options "Found existing installation of $THEME. Would you like to overwrite?" \
        "Yes" install_theme \
        "No"  continue
else install_theme    
fi

script_exit

