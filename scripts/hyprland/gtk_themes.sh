#!/bin/bash
# GTK Themes & ICONS and  Sourcing from a different Repo #

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Dotfiles directory
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

# installing engine needed for gtk themes
engine=(unzip gtk-engine-murrine)
for PKG1 in "${engine[@]}"; do
    iAur "$PKG1"
done

# Clone dotfiles
note "Cloning dotfiles..."
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$temp_dir"; then
    ok "Cloned dotfiles successfully"
else
    err "Failed to clone dotfiles" && exit 1
fi

# Copy gtk_themes file
note "Copying gtk themes file"
for dir in .icons .fonts .themes; do
    mkdir -p "$HOME/$dir"
    if cp -r "$temp_dir/assets/$dir/." "$HOME/$dir/"; then
        ok "Copied $dir successfully"
        [[ "$dir" == ".fonts" ]] && fc-cache -fv
    else
        err "Failed to copy $dir"
    fi
done
