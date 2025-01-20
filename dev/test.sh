#!/bin/bash

source <(curl -sSL https://is.gd/nhattVim_lib)

cd "$HOME"
if ! cd hyprland_nhattVim 2>/dev/null; then
    note "Clone dotfiles." &&
        git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 hyprland_nhattVim &&
        cd hyprland_nhattVim &&
        ok "Clone dotfiles successfully" || err "Failed to clone dotfiles" && exit 1
    pwd
fi

cd "$HOME" || exit 1
if [ -d dotfiles ]; then
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
else
    note "Clone dotfiles." && git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 || {
        err "Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
fi
