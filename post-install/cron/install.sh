#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init 
install_dependencies
install_files config

# For convenience
sudo mkdir -p /etc/cron.boot

script_exit