#!/bin/bash

source "../helpers/utilities.sh"

script_init
install_dependencies
start_systemd preload.service
script_exit