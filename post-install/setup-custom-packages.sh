#!/bin/bash

source "$(dirname "$(realpath "$0")")/helpers/utilities.sh"

echo "Linux Toolkit - Post Install"

INSTALL_ORDER="./install-order.txt"

# ensure file ends with a newline
sed -i -e '$a\' $INSTALL_ORDER

echo "Setting up packages, configs, scripts and files according to the order defined in $INSTALL_ORDER."

DIR=$(pwd)

# Read the list of packages from the text file
while read package; do

    # Skip empty lines or lines starting with '#'
    [[ -z "$package" || "$package" =~ ^# ]] && continue
 
    # ensure we always start from base directory
    cd $DIR
    PACKAGE_DIR="$DIR/$package"

    if [ ! -d "$PACKAGE_DIR" ]; then
        echo "Could not locate $PACKAGE_DIR. Skipping..."

    else 
        INSTALL_SCRIPT="$PACKAGE_DIR/install.sh"

        if [ ! -f "$INSTALL_SCRIPT" ]; then
            echo "Could not locate $INSTALL_SCRIPT. Skipping..."  

        else 
            # ensure we are installing from the package directory
            cd $PACKAGE_DIR
            sh "./install.sh"
        fi
    fi

done < "$INSTALL_ORDER"

echo "Congratulations. All relevant packages have been installed, and all relevant configs and files are in their appropriate locations."
exit 0
