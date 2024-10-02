#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_files scripts
install_files config

start_systemd notify-upgrade.service user
start_systemd notify-upgrade.timer user

script_exit