#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies

sudo systemctl mask power-profiles-daemon.service
start_systemd auto-cpufreq.service

script_exit
