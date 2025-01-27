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
    burn-my-windows@schneegans.github.com
    # forge@jmmaranan.com
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
for EXTS in "${disable_exts[@]}"; do
    if gnome-extensions list | grep -q "$EXTS"; then
        gnome-extensions disable "$EXTS" &&
            ok "$EXTS disabled successfully" ||
            err "$EXTS disable failed"
    else
        note "$EXTS is not installed, skipping."
    fi
done

gum confirm "To install Gnome extensions, you need to accept some confirmations. Are you ready?"

export PATH="$HOME/.local/bin:$PATH"

for EXTS2 in "${install_exts[@]}"; do
    if ! gnome-extensions list | grep -q "$EXTS2"; then
        gext install "$EXTS2" && gnome-extensions enable "$EXTS2" &&
            ok "$EXTS2 installed successfully"
    else
        gnome-extensions enable "$EXTS2"
        note "$EXTS2 is already installed, skipping."
    fi

    SCHEMA_SRC="$HOME/.local/share/gnome-shell/extensions/$EXTS2/schemas"
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
gsettings set org.gnome.shell.extensions.search-light shortcut-search "['<Super>D']"
gsettings set org.gnome.shell.extensions.search-light border-radius 1.0
gsettings set org.gnome.shell.extensions.search-light border-thickness 1
gsettings set org.gnome.shell.extensions.search-light background-color "(0.067, 0.067, 0.106, 0.6)"
gsettings set org.gnome.shell.extensions.search-light border-color "(0.705, 0.745, 0.996, 1.0)"

note "Configuring extension: user-theme"
gsettings set org.gnome.shell.extensions.user-theme name "(Modded) Catppuccin-Macchiato-Standard-Lavender-dark"
# gsettings set org.gnome.shell.extensions.user-theme name "(Modded) Catppuccin-Mocha-Standard-Mauve-Dark"

note "Configuring extension: clipboard-history"
gsettings set org.gnome.shell.extensions.clipboard-history toggle-menu "['<Super>V']"
gsettings set org.gnome.shell.extensions.clipboard-history clear-history "['<Super><Shift>V']"

note "Configuring extension: space-bar"
gsettings set org.gnome.shell.extensions.space-bar.behavior smart-workspace-names false
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts false
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts open-menu "@as []"

# note "Configuring extension: top-bar-organizer"
# gsettings set org.gnome.shell.extensions.top-bar-organizer left-box-order "['LogoMenu', 'dateMenu', 'Space Bar', 'Clipboard History Indicator', 'activities']"
# gsettings set org.gnome.shell.extensions.top-bar-organizer center-box-order "['dateMenu']"
# gsettings set org.gnome.shell.extensions.top-bar-organizer center-box-order "['color-picker@tuberry', 'appindicator-kstatusnotifieritem-livepatch', 'appindicator-kstatusnotifieritem-software-update-available', 'vitalsMenu', 'screenRecording', 'screenSharing', 'dwellClick', 'a11y', 'keyboard', 'quickSettings']"

note "Configuring extension: logomenu"
gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-image 5
gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-size 25
gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-click-type 1
gsettings set org.gnome.shell.extensions.logo-menu menu-button-terminal "kitty"

note "Configuring extension: Vitals"
gsettings set org.gnome.shell.extensions.vitals hot-sensors "['_memory_usage_', '__network-rx_max__']"

note "Configuring extension: burn-my-windows"
gsettings set org.gnome.shell.extensions.burn-my-windows active-profile "$HOME/.config/burn-my-windows/profiles/nhattVim.conf"

# note "Configuring extension: forge"
# gsettings set org.gnome.shell.extensions.forge focus-border-toggle true
# gsettings set org.gnome.shell.extensions.forge window-gap-size 4
# gsettings set org.gnome.shell.extensions.forge focus-border-color "rgba(180, 190, 254, 1)"
# gsettings set org.gnome.shell.extensions.forge focus-border-size 1
# gsettings set org.gnome.shell.extensions.forge.keybindings workspace-active-tile-toggle "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings prefs-tiling-toggle "['<Super><Ctrl>T']"
# gsettings set org.gnome.shell.extensions.forge.keybindings con-split-vertical "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-left "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-down "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-up "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-right "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-left-increase "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-left-decrease "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-bottom-increase "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-bottom-decrease "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-top-increase "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-top-decrease "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-right-increase "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-right-decrease "['']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-left "['<Super><Ctrl>H']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-down "['<Super><Ctrl>J']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-up "['<Super><Ctrl>K']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-right "['<Super><Ctrl>L']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-left "['<Super>H']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-down "['<Super>J']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-up "['<Super>K']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-right "['<Super>L']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-toggle-float "['<Super><Shift>F']"

# ~/Workspaces/dotfiles (master*) » gsettings list-recursively org.gnome.shell.extensions.burn-my-windows-profile                                       albedo@nhattVim
