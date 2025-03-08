#!/bin/bash
# GTK Themes & ICONS and  Sourcing from a different Repo #

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Dotfiles directory
temp_dir=$(mktemp -d)

# start script
engine=(
    unzip
    gtk-engine-murrine
)

# installing engine needed for gtk themes
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

# copying icon
mkdir -p $HOME/.icons
cp -r "$temp_dir/assets/.icons/." "$HOME/.icons/" && { ok "Copy icons completed!"; } || {
    err "Failed to copy icons files"
}

# copying font
mkdir -p $HOME/.fonts
cp -r "$temp_dir/assets/.fonts/." "$HOME/.fonts/" && { ok "Copy fonts completed!"; } || {
    err "Failed to copy fonts files"
}

# copying theme
mkdir -p $HOME/.themes
cp -r "$temp_dir/assets/.themes/." "$HOME/.themes" && { ok "Copy themes completed!"; } || {
    err "Failed to copy themes files"
}

# reload fonts
fc-cache -fv

rm -rf "$temp_dir"
