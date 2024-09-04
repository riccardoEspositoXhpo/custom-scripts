#!/bin/bash

source "./utilities.sh"

echo "Starting package and configuration installation"

INSTALL_ORDER="./install-order.txt"
echo "Setting up packages according to the order defined in $INSTALL_ORDER."

if [ ! -f $INSTALL_ORDER ]; then
    echo "Cold not locate $INSTALL_ORDER file."
    exit 1
fi

DIR=$(pwd)
# Read the list of packages from the text file
while read package; do

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


echo "Congratulations. All relevant packages and configurations have been installed successfully!"
exit 0

