#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init 
install_dependencies
install_files config

# run the script for immediate configuration
reflector

start_systemd reflector.service
start_systemd reflector.timer

script_exit