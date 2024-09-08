#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies
start_systemd preload.service
script_exit