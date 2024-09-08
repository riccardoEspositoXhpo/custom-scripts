#!/bin/bash

# This installs toolkit specific files in the home directory

echo "Linux Toolkit installer"
source "helpers/utilities.sh"

echo "Setting up local configuration directory"
mkdir -p $HOME/.config/linux-toolkit

echo "Setting up environment variables"

CURRENT_DIR="$(dirname "$(realpath "$0")")"

TOOLKIT_CONFIG="$HOME/.config/linux-toolkit/.linux-toolkit"

cat <<EOF > "$TOOLKIT_CONFIG"
#!/bin/bash

export LINUX_TOOLKIT_DIR=$CURRENT_DIR
export LINUX_TOOLKIT_UTILITIES=$CURRENT_DIR/helpers/utilities.sh

EOF

