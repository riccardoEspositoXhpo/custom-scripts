#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init
install_files hooks
install_files files
install_files cazzosoio
script_exit
