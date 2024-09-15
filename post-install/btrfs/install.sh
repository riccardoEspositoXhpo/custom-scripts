#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init

echo "Checking if using a btrfs filesystem"

fs_type=$(findmnt -n -o FSTYPE /)

# Check if the file system is NOT btrfs
if [[ "$fs_type" != "btrfs" ]]; then
    error "The root file system is: $fs_type."
    exit 1
fi

echo "Filesystem is $fs_type. Proceeding..."

install_dependencies

install_files config

info "Running btrfsmaintenance-refresh-cron..."
sh /usr/share/btrfsmaintenance/btrfsmaintenance-refresh-cron.sh

# update the grub config
info "Updating grub..."
if [ -w "$GRUB_CONFIG" ]; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi


script_exit
