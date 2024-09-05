#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init 
install_dependencies
install_files config

# run the script for immediate configuration
reflector

start_systemd reflector.service
start_systemd reflector.timer

script_exit