#!/bin/bash
# Setup firefox

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

note "Installing Firefox"
iPac "firefox"
if [ $? -ne 0 ]; then
    err "Firefox install had failed"
    exit 1
fi

# Generate Firefox profile if not exists
if [ ! -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
    note "Generating Firefox profile"
    firefox --headless &

    # Get Firefox PID
    FIREFOX_PID=$!

    # Wait for profiles.ini to be created
    while [ ! -f "$HOME/.mozilla/firefox/profiles.ini" ]; do
        sleep 1
    done

    # Kill Firefox by PID
    kill $FIREFOX_PID
    wait $FIREFOX_PID 2>/dev/null
fi

# Get the profile path after ensuring it exists
PROFILE_PATH="$HOME/.mozilla/firefox/$(awk -F= '/^Default=/{print $2; exit}' "$HOME/.mozilla/firefox/profiles.ini")"

# Validate PROFILE_PATH
if [ ! -d "$PROFILE_PATH" ]; then
    err "Firefox profile path is invalid: $PROFILE_PATH"
    exit 1
fi

# Clone custom CSS and apply
temp_dir=$(mktemp -d)
note "Cloning firefox customcss"
if git clone https://github.com/nhattVim/firefox.git "$temp_dir"; then
    cp -rf "$temp_dir"/* "$PROFILE_PATH"
    note "Custom CSS applied successfully!"
else
    err "Failed to clone firefox customcss"
    exit 1
fi

# Cleanup
rm -rf "$temp_dir"
