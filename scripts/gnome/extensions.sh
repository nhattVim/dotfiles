#!/bin/bash

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

SCHEMA_DIR="/usr/share/glib-2.0/schemas/"

pkgs=(
    gnome-shell-extension-manager
    pipx
)

disable_exts=(
    tiling-assistant@ubuntu.com
    ubuntu-appindicators@ubuntu.com
    ubuntu-dock@ubuntu.com
    ding@rastersoft.com
)

install_exts=(
    blur-my-shell@aunetx
    clipboard-history@alexsaveau.dev
    compiz-alike-magic-lamp-effect@hermes83.github.com
    compiz-windows-effect@hermes83.github.com
    CoverflowAltTab@palatis.blogspot.com
    logomenu@aryan_k
    rounded-window-corners@fxgn
    search-light@icedman.github.com
    space-bar@luchrioh
    top-bar-organizer@julian.gse.jsts.xyz
    user-theme@gnome-shell-extensions.gcampax.github.com
    Vitals@CoreCoding.com
    appindicatorsupport@rgcjonas.gmail.com
    forge@jmmaranan.com
)

note "Installing extension tools"
for PKG in "${pkgs[@]}"; do
    iDeb "$PKG"
    if [ $? -ne 0 ]; then
        err "$PKG installation failed"
    fi
done

note "Installing gnome-extensions-cli"
pipx install gnome-extensions-cli --system-site-packages &&
    ok "gnome-extensions-cli installed successfully" ||
    err "Failed to install gnome-extensions-cli"

note "Disabling default Ubuntu extensions"
for EXTS in "${disable_exts[@]}"; do
    gnome-extensions disable "$EXTS" &&
        ok "$EXTS disabled successfully" ||
        err "$EXTS disable failed"
done

gum confirm "To install Gnome extensions, you need to accept some confirmations. Are you ready?"

export PATH="$HOME/.cargo/bin:$PATH"

for EXT2 in "${install_exts[@]}"; do
    gext install "$EXT2" &&
        ok "$EXT2 installed successfully"

    SCHEMA_SRC="$HOME/.local/share/gnome-shell/extensions/$EXT2/schemas"
    if [ -d "$SCHEMA_SRC" ] && compgen -G "$SCHEMA_SRC"/*.gschema.xml >/dev/null; then
        sudo cp "$SCHEMA_SRC"/*.gschema.xml "$SCHEMA_DIR"
    fi
done

note "Compiling gsettings schemas"
sudo glib-compile-schemas "$SCHEMA_DIR"

# Configure Blur My Shell
note "Configuring extension: blur-my-shell"
gsettings set org.gnome.shell.extensions.blur-my-shell.lockscreen blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.screenshot blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.window-list blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.overview blur true

note "Configuring extension: search-light"
gsettings set org.gnome.shell.extensions.search-light shortcut-search "['<Alt>Space']"
gsettings set org.gnome.shell.extensions.search-light border-radius 2.0
gsettings set org.gnome.shell.extensions.search-light border-thickness 1
gsettings set org.gnome.shell.extensions.search-light background-color '(0.0, 0.0, 0.0, 0.5)'

note "Configuring extension: user-theme"
gsettings set org.gnome.shell.extensions.user-theme name "(Modded) Catppuccin-Macchiato-Standard-Lavender-dark"
# gsettings set org.gnome.shell.extensions.user-theme name "(Modded) Catppuccin-Mocha-Standard-Mauve-Dark"

note "Configuring extension: clipboard-history"
gsettings set org.gnome.shell.extensions.clipboard-history toggle-menu "['<Super>V']"
gsettings set org.gnome.shell.extensions.clipboard-history clear-history "['<Super><Shift>V']"
