#!/bin/bash
APPIMAGE_PATH="/opt/cursor.appimage"

for cmd in jq zenity curl; do
    if ! command -v $cmd &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y $cmd
    fi
done

API_JSON=$(curl -s "https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable")
LATEST_VERSION=$(echo "$API_JSON" | jq -r '.version')
LATEST_URL=$(echo "$API_JSON" | jq -r '.downloadUrl')

if [ -f "$APPIMAGE_PATH" ]; then
    INSTALLED_VERSION=$(basename "$APPIMAGE_PATH" | grep -oP '(?<=Cursor-)[0-9]+\.[0-9]+\.[0-9]+')
else
    INSTALLED_VERSION="none"
fi

if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
    RESPONSE=$(zenity --question --title="Cursor Update" \
        --text="New version available: $LATEST_VERSION\nInstalled: $INSTALLED_VERSION\nDo you want to update?" \
        --ok-label="Update" --cancel-label="Skip")

    if [ $? -eq 0 ]; then
        /bin/bash "$(dirname "$0")/install.sh"
    fi
fi