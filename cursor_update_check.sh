 #!/bin/bash
 set -euo pipefail
 
 APPIMAGE_PATH="/opt/cursor.appimage"
 VERSION_FILE="/opt/cursor.version"
 API_URL="https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
 
+show_error() {
+    local message="$1"
+
+    if command -v zenity &>/dev/null; then
+        zenity --error --title="Cursor Update" --text="$message"
+    else
+        printf 'ERROR: %s\n' "$message" >&2
+    fi
+}
+
+show_info() {
+    local message="$1"
+
+    if command -v zenity &>/dev/null; then
+        zenity --info --title="Cursor Update" --text="$message"
+    else
+        printf '%s\n' "$message"
+    fi
+}
+
+confirm_update() {
+    local latest="$1"
+    local installed="$2"
+    local prompt="New version available: $latest\nInstalled: $installed\nDo you want to update?"
+
+    if command -v zenity &>/dev/null; then
+        if zenity --question --title="Cursor Update" \
+            --text="$prompt" --ok-label="Update" --cancel-label="Skip"; then
+            return 0
+        fi
+        return 1
+    fi
+
+    printf '%s\n' "$prompt"
+    read -r -p "Update now? [y/N]: " response
+    case "$response" in
+        [Yy]*) return 0 ;;
+        *) return 1 ;;
+    esac
+}
+
 ensure_dependencies() {
     local missing=()
     for cmd in jq zenity curl; do
         if ! command -v "$cmd" &>/dev/null; then
             missing+=("$cmd")
         fi
     done
 
-    if [ ${#missing[@]} -gt 0 ]; then
-        sudo apt-get update -y
-        sudo apt-get install -y "${missing[@]}"
+    if [ ${#missing[@]} -eq 0 ]; then
+        return
+    fi
+
+    if ! command -v apt-get &>/dev/null; then
+        show_error "Missing required commands: ${missing[*]}. Please install them manually."
+        exit 1
+    fi
+
+    if ! sudo apt-get update -y; then
+        show_error "Failed to update apt repositories. Please install the following commands manually: ${missing[*]}."
+        exit 1
+    fi
+
+    if ! sudo apt-get install -y "${missing[@]}"; then
+        show_error "Failed to install required commands: ${missing[*]}. Please install them manually."
+        exit 1
     fi
 }
 
 fetch_latest_release() {
     local api_json
     if ! api_json=$(curl -fsSL "$API_URL"); then
-        zenity --error --title="Cursor Update" --text="Failed to reach the Cursor download service."
+        show_error "Failed to reach the Cursor download service."
         exit 1
     fi
 
     LATEST_VERSION=$(echo "$api_json" | jq -r '.version // empty')
     LATEST_URL=$(echo "$api_json" | jq -r '.downloadUrl // empty')
 
     if [ -z "${LATEST_VERSION}" ] || [ -z "${LATEST_URL}" ]; then
-        zenity --error --title="Cursor Update" --text="Received an invalid response from the Cursor download service."
+        show_error "Received an invalid response from the Cursor download service."
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
 
 write_installed_version() {
     echo "$1" | sudo tee "$VERSION_FILE" >/dev/null
 }
 
 download_update() {
     local temp_file
     temp_file=$(mktemp)
 
     if ! curl -fSL "$LATEST_URL" -o "$temp_file"; then
         rm -f "$temp_file"
-        zenity --error --title="Cursor Update" --text="Failed to download Cursor $LATEST_VERSION."
+        show_error "Failed to download Cursor $LATEST_VERSION."
         exit 1
     fi
 
     sudo install -m 0755 "$temp_file" "$APPIMAGE_PATH"
     rm -f "$temp_file"
     write_installed_version "$LATEST_VERSION"
 }
 
 main() {
     ensure_dependencies
     fetch_latest_release
     INSTALLED_VERSION=$(get_installed_version)
 
     if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
         exit 0
     fi
 
-    if zenity --question --title="Cursor Update" \
-        --text="New version available: $LATEST_VERSION\nInstalled: $INSTALLED_VERSION\nDo you want to update?" \
-        --ok-label="Update" --cancel-label="Skip"; then
+    if confirm_update "$LATEST_VERSION" "$INSTALLED_VERSION"; then
         download_update
-        zenity --info --title="Cursor Update" --text="Cursor has been updated to v$LATEST_VERSION."
+        show_info "Cursor has been updated to v$LATEST_VERSION."
     fi
 }
 
 main "$@"
