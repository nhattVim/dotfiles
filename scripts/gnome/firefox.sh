#!/bin/bash
# Setup firefox

# Source library
. <(curl -sSL https://nhattVim.github.io/lib.sh)

note "Customizing Firefox..."

iDeb "firefox"
if [ $? -ne 0 ]; then
    exit 1
fi

# Path to profiles.ini
PROFILE_INI="$HOME/.mozilla/firefox/profiles.ini"

# Generate Firefox profile if not exists
if [ ! -f "$PROFILE_INI" ]; then
    note "Generating Firefox profile..."
    firefox --headless &

    # Get Firefox PID
    FIREFOX_PID=$!

    # Wait for profiles.ini to be created
    timeout=10
    while [ ! -f "$PROFILE_INI" ] && [ $timeout -gt 0 ]; do
        sleep 1
        ((timeout--))
    done

    # Kill Firefox if still running
    if ps -p $FIREFOX_PID >/dev/null; then
        kill $FIREFOX_PID
        wait $FIREFOX_PID 2>/dev/null
    fi

    if [ ! -f "$PROFILE_INI" ]; then
        err "Failed to generate Firefox profile!"
        exit 1
    fi

    ok "Firefox profile generated!"
fi

# Get the profile path after ensuring it exists
PROFILE_PATH="$HOME/.mozilla/firefox/$(awk -F= '/^Default=/{print $2; exit}' "$PROFILE_INI")"

# Validate PROFILE_PATH
if [ ! -d "$PROFILE_PATH" ]; then
    err "Firefox profile path is invalid: $PROFILE_PATH"
    exit 1
fi

# Clone custom CSS and apply
temp_dir=$(mktemp -d)
note "Cloning firefox customcss"
if git clone https://github.com/nhattVim/firefox.git "$temp_dir"; then

    # Delete existing chrome folder
    if [ -d "$PROFILE_PATH/chrome" ]; then
        rm -rf "$PROFILE_PATH/chrome"
        ok "Removed existing chrome folder"
    fi

    # Delete existing user.js
    if [ -f "$PROFILE_PATH/user.js" ]; then
        rm "$PROFILE_PATH/user.js"
        ok "Removed existing user.js"
    fi

    # Copy custom CSS
    cp -r "$temp_dir/chrome" "$PROFILE_PATH/"
    cp "$temp_dir/user.js" "$PROFILE_PATH/"

    note "Custom CSS applied successfully!"
else
    err "Failed to clone firefox customcss"
fi

# Cleanup
rm -rf "$temp_dir"
