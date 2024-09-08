#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init 
install_dependencies

OPTIONS=$(cat <<EOF
1.Open Deja-Dup
2. Restore Backup
EOF
)

pause_and_open_app deja-dup "$OPTIONS" 

script_exit
