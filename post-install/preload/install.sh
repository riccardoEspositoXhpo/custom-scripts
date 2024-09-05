#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init
install_dependencies
start_systemd preload.service
script_exit