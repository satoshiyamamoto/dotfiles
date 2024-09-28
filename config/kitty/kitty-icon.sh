#!/bin/bash

# Script to change the icon of Kitty.app

# Define the path to the new icon file
ICON_FILE="$GOPATH/src/github.com/k0nserv/kitty-icon/build/neue_outrun.icns"

# Copy the new icon file
sudo cp "$ICON_FILE" /Applications/kitty.app/Contents/Resources/kitty.icns

# Update the timestamp of the application
touch /Applications/kitty.app

# Restart Dock to refresh the icon cache
sudo killall Dock

# Display completion message
echo "Kitty.app icon has been successfully updated."

