#!/bin/bash

# does this work?
source "../utilities.sh"

script_init 
install_dependencies
install_configs
start_systemd reflector.service
script_exit
