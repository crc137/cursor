#!/bin/bash

APPIMAGE_PATH="/opt/cursor.appimage"
ICON_PATH="/opt/cursor.svg"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"
VERSION_FILE="/opt/cursor.version"
CHECK_SCRIPT="$HOME/.cursor_update_check.sh"
CRON_MARKER="# Cursor daily update check"

read -r -d '' ICON_SVG <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="104" height="104" fill="none" viewBox="0 0 104 104" class="size-30">
  <rect width="104" height="104" fill="#0C0C0C" rx="22"></rect>
  <path fill="#939393" d="M51.998 90.405v-37.8L20 71.504z"></path>
  <path fill="#E3E3E3" d="M84 33.703 52.001 90.404v-37.8z"></path>
  <path fill="#fff" d="M20 33.703h63.995l-31.998 18.9z"></path>
  <path fill="#444" d="M52.002 14.804v18.9h31.997z"></path>
  <path fill="#939393" d="M20 33.705h31.998v-18.9zM84 71.504l-16-9.45-15.998 28.35z"></path>
  <path fill="#444" d="m83.996 33.703-15.999 28.35 15.999 9.45zM51.998 52.604 20 71.504v-37.8z"></path>
</svg>
EOF
    
check_dependencies() {
    local missing=()
    for cmd in curl jq zenity; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Installing ${missing[*]}..."
        sudo apt-get update -y
        sudo apt-get install -y "${missing[@]}"
    fi
}

get_latest_info() {
    API_JSON=$(curl -s "https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable")
    if [ -z "$API_JSON" ]; then
        zenity --error --title="Cursor Installer" --text="Failed to fetch Cursor API. Check your internet."
        exit 1
    fi
    LATEST_VERSION=$(echo "$API_JSON" | jq -r '.version')
    LATEST_URL=$(echo "$API_JSON" | jq -r '.downloadUrl')

    if [ -z "$LATEST_VERSION" ] || [ -z "$LATEST_URL" ]; then
        zenity --error --title="Cursor Installer" --text="Failed to parse API response."
        exit 1
    fi
}

get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
        return
    fi

    if [ -x "$APPIMAGE_PATH" ]; then
        local version_tmp
        version_tmp=$(mktemp)

        if "$APPIMAGE_PATH" --appimage-version >"$version_tmp" 2>/dev/null; then
            tr -d '\r' <"$version_tmp"
            rm -f "$version_tmp"
            return
        fi

        if "$APPIMAGE_PATH" --version >"$version_tmp" 2>/dev/null; then
            tr -d '\r' <"$version_tmp"
            rm -f "$version_tmp"
            return
        fi

        rm -f "$version_tmp"
    fi

    echo "none"
}

install_cursor() {
    get_latest_info
    echo "Installing Cursor v${LATEST_VERSION}..."

    local temp_file
    temp_file=$(mktemp)

    if ! curl -fSL "$LATEST_URL" -o "$temp_file"; then
        rm -f "$temp_file"
        zenity --error --title="Cursor Installer" --text="Failed to download Cursor v${LATEST_VERSION}."
        exit 1
    fi

    sudo install -m 0755 "$temp_file" "$APPIMAGE_PATH"
    rm -f "$temp_file"
    echo "$LATEST_VERSION" | sudo tee "$VERSION_FILE" >/dev/null

    echo "$ICON_SVG" | sudo tee "$ICON_PATH" >/dev/null

    sudo tee "$DESKTOP_ENTRY_PATH" >/dev/null <<EOL
[Desktop Entry]
Name=Cursor
Exec=$APPIMAGE_PATH --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL

    if ! grep -q "cursor.appimage" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" <<'EOL'

# Cursor alias
function cursor() {
    if pgrep -f "cursor.appimage" > /dev/null; then
        echo "Cursor is already running."
    else
        /opt/cursor.appimage --no-sandbox "$@" > /dev/null 2>&1 & disown
        echo "Cursor started."
    fi
}
EOL
        source "$HOME/.bashrc"
    fi

    zenity --info --title="Cursor Installer" --text="Cursor v${LATEST_VERSION} installed and available in Show Apps."
}

remove_cursor() {
    if pgrep -f "cursor.appimage" > /dev/null; then
        pkill -f "cursor.appimage"
    fi

    sudo rm -f "$APPIMAGE_PATH" "$ICON_PATH" "$DESKTOP_ENTRY_PATH" "$VERSION_FILE"

    if grep -q "# Cursor alias" "$HOME/.bashrc"; then
        sed -i '/# Cursor alias/,+7d' "$HOME/.bashrc"
    fi

    (crontab -l 2>/dev/null | grep -v "$CRON_MARKER") | crontab -
    rm -f "$CHECK_SCRIPT"

    source "$HOME/.bashrc"
    zenity --info --title="Cursor Installer" --text="Cursor completely removed."
}

setup_daily_check() {
    cp "$(dirname "$0")/cursor_update_check.sh" "$CHECK_SCRIPT"
    chmod +x "$CHECK_SCRIPT"
    
    (crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "0 10 * * * /bin/bash $CHECK_SCRIPT $CRON_MARKER") | crontab -
    zenity --info --title="Cursor Installer" --text="Daily update check scheduled at 10:00"
}

remove_daily_check() {
    (crontab -l 2>/dev/null | grep -v "$CRON_MARKER") | crontab -
    
    rm -f "$CHECK_SCRIPT"
    
    zenity --info --title="Cursor Installer" --text="Daily update check removed."
}

check_dependencies
get_latest_info

CHOICE=$(zenity --list --title="Cursor Installer / Updater" \
    --column="Option" --column="Description" \
    1 "Install/Update Cursor" \
    2 "Remove Cursor" \
    3 "Setup Daily Update Check" \
    4 "Remove Daily Update Check" \
    5 "Exit")

case $CHOICE in
    1)
        INSTALLED_VERSION=$(get_installed_version)
        if [ "$INSTALLED_VERSION" = "none" ]; then
            install_cursor
        elif [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
            remove_cursor
            install_cursor
        else
            zenity --info --title="Cursor Installer" --text="Cursor v$INSTALLED_VERSION is already up to date"
        fi
        ;;
    2)
        remove_cursor
        ;;
    3)
        setup_daily_check
        ;;
    4)
        remove_daily_check
        ;;
    5)
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
