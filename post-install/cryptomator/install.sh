#!/bin/bash

source $LINUX_TOOLKIT_UTILITIES

script_init
install_dependencies


prompt_options "Have you restored backup from Deja Dup? Press 1 to continue." "Yes" continue

OPTIONS=$(cat <<EOF
1. Open Cryptomator
2. Search for Desired Vault
3. Import Vault and password
EOF
)

pause_and_open_app cryptomator
script_exit