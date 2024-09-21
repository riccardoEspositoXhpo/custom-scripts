#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies


info "Make sure your files have been restored."

function run() {
    hp-setup -i
}

display_countdown 5 run

script_exit