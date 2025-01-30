#!/bin/bash
# GTK Themes & ICONS and  Sourcing from a different Repo #

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# Dotfiles directory
DOTFILES_DIR="$HOME/hyprland_nhattVim"

# start script
engine=(
    unzip
    gtk-engine-murrine
)

# installing engine needed for gtk themes
for PKG1 in "${engine[@]}"; do
    iAur "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG1 install had failed."
    fi
done

# Remove old dotfiles if exist
if [ -d "$DOTFILES_DIR" ]; then
    rm -rf "$DOTFILES_DIR"
fi

# Clone dotfiles
note "Cloning dotfiles..."
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$DOTFILES_DIR"; then
    ok "Cloned dotfiles successfully"
else
    err "Failed to clone dotfiles" && exit 1
fi

# Copy gtk_themes file
note "Copying gtk themes file"

# copying icon
mkdir -p $HOME/.icons
cp -r "$DOTFILES_DIR/assets/.icons/*" "$HOME/.icons/" && { ok "Copy icons completed!"; } || {
    err "Failed to copy icons files"
}

# copying font
mkdir -p $HOME/.fonts
cp -r "$DOTFILES_DIR/assets/.fonts/*" "$HOME/.fonts/" && { ok "Copy fonts completed!"; } || {
    err "Failed to copy fonts files"
}

# copying theme
mkdir -p $HOME/.themes
cp -r "$DOTFILES_DIR/assets/.themes/*" "$HOME/.themes" && { ok "Copy themes completed!"; } || {
    err "Failed to copy themes files"
}

# reload fonts
fc-cache -fv

# remove dotfiles
if [ -d "$DOTFILES_DIR" ]; then
    rm -rf "$DOTFILES_DIR"
fi
