#!/bin/bash
APPIMAGE_PATH="/opt/cursor.appimage"

for cmd in jq zenity curl; do
    if ! command -v "$cmd" &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y "$cmd"
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

if [ -z "$LATEST_VERSION" ] || [ -z "$LATEST_URL" ]; then
    zenity --error --title="Cursor Update" --text="Failed to fetch the latest Cursor release information."
    exit 1
fi

if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
    if zenity --question --title="Cursor Update" \
        --text="New version available: $LATEST_VERSION\nInstalled: $INSTALLED_VERSION\nDo you want to update?" \
        --ok-label="Update" --cancel-label="Skip"; then
        TEMP_FILE=$(mktemp)
        if ! curl -L "$LATEST_URL" -o "$TEMP_FILE"; then
            rm -f "$TEMP_FILE"
            zenity --error --title="Cursor Update" --text="Failed to download Cursor $LATEST_VERSION."
            exit 1
        fi

        sudo mv "$TEMP_FILE" "$APPIMAGE_PATH"
        sudo chmod +x "$APPIMAGE_PATH"

        zenity --info --title="Cursor Update" --text="Cursor has been updated to v$LATEST_VERSION."
    fi
fi
