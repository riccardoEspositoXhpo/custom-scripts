#!/bin/bash

source "$(dirname "$(realpath "$0")")/../helpers/utilities.sh"

script_init
install_dependencies

sudo systemctl mask power-profiles-daemon.service
start_systemd auto-cpufreq.service

script_exit
