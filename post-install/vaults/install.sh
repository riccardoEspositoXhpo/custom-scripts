#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies


prompt_options "Have you restored backup from Deja Dup? Press 1 to continue." "Yes" continue

info "Make sure your files have been restored."
info "Make sure you can find and restore your vault"

script_exit