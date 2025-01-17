#!/bin/bash
# GTK Themes & ICONS and  Sourcing from a different Repo #

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

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

# Check dotfiles
cd $HOME
if [ -d dotfiles ]; then
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
else
    note "Clone dotfiles." && git clone -b hyprland https://github.com/nhattVim/dotfiles.git $HOME/dotfiles --depth 1 || {
        err "Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
fi

# Copy gtk_themes file
note "Copying gtk themes file"

# copying icon
mkdir -p $HOME/.icons
cp -r assets/.icons/* $HOME/.icons/ && { ok "Copy icons completed!"; } || {
    err "Failed to copy icons files"
}

# copying font
mkdir -p $HOME/.fonts
cp -r assets/.fonts/* $HOME/.fonts/ && { ok "Copy fonts completed!"; } || {
    err "Failed to copy fonts files"
}

# copying theme
mkdir -p $HOME/.themes
cp -r assets/.themes/* $HOME/.themes && { ok "Copy themes completed!"; } || {
    err "Failed to copy themes files"
}

# reload fonts
fc-cache -fv
