#!/bin/bash
# Setup firefox

# Source library
. <(curl -fsSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

note "Customizing Firefox..."

# Ensure Firefox is installed
install_arch_pkg "firefox"

get_profile_ini() {
    local paths=(
        "$HOME/.mozilla/firefox/profiles.ini"
        "$HOME/.config/mozilla/firefox/profiles.ini"
        "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/profiles.ini"
    )

    for p in "${paths[@]}"; do
        [[ -f "$p" || -d "$(dirname "$p")" ]] && {
            echo "$p"
            return
        }
    done

    echo "$HOME/.mozilla/firefox/profiles.ini"
}

PROFILE_INI="$(get_profile_ini)"

# Generate Firefox profile if not exists
if [[ ! -f "$PROFILE_INI" ]]; then
    note "Generating Firefox profile..."

    firefox --headless >/dev/null 2>&1 &
    FIREFOX_PID=$!

    timeout=15

    while [[ ! -f "$PROFILE_INI" && $timeout -gt 0 ]]; do
        sleep 1
        ((timeout--))
    done

    if kill -0 "$FIREFOX_PID" 2>/dev/null; then
        kill "$FIREFOX_PID" 2>/dev/null || true
        wait "$FIREFOX_PID" 2>/dev/null || true
    fi

    # Refresh profile path after Firefox creates it
    PROFILE_INI="$(get_profile_ini)"

    if [[ ! -f "$PROFILE_INI" ]]; then
        err "Failed to generate Firefox profile!"
        exit 1
    fi

    ok "Firefox profile generated!"
fi

bash <(curl -fsSL https://nhattVim.github.io/firefox.sh)
