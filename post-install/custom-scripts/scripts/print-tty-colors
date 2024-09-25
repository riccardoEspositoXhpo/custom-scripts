#!/bin/bash
# Display foreground colors
echo "Foreground Colors:"
for i in {0..255}; do
    printf "\e[38;5;%sm%3d " "$i" "$i"
    # Print a new line after every 10 colors for readability
    if [ $(( (i + 1) % 10 )) == 0 ]; then
        echo
    fi
done
echo -e "\n"

# Display background colors
echo "Background Colors:"
for i in {0..255}; do
    printf "\e[48;5;%sm%3d " "$i" "$i"
    # Print a new line after every 10 colors for readability
    if [ $(( (i + 1) % 10 )) == 0 ]; then
        echo
    fi
done
echo -e "\e[0m\n"  # Reset color at the end

