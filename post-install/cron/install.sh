#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init 
install_dependencies
install_files config

# For convenience
sudo mkdir -p /etc/cron.boot

script_exit