#!/bin/bash

# Source library
. <(curl -sSL https://bit.ly/nhattVim_lib)

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

note "Configuring extension: top-bar-organizer"
gsettings set org.gnome.shell.extensions.top-bar-organizer left-box-order "['LogoMenu', 'Space Bar', 'Clipboard History Indicator', 'activities']"
gsettings set org.gnome.shell.extensions.top-bar-organizer center-box-order "['dateMenu']"
gsettings set org.gnome.shell.extensions.top-bar-organizer right-box-order "['keyboard', 'color-picker@tuberry', 'appindicator-kstatusnotifieritem-livepatch', 'appindicator-kstatusnotifieritem-software-update-available', 'vitalsMenu', 'screenRecording', 'screenSharing', 'dwellClick', 'a11y', 'quickSettings']"

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
# gsettings set org.gnome.shell.extensions.forge auto-exit-tabbed true
# gsettings set org.gnome.shell.extensions.forge auto-split-enabled true
# gsettings set org.gnome.shell.extensions.forge css-last-update 37
# gsettings set org.gnome.shell.extensions.forge css-updated ''
# gsettings set org.gnome.shell.extensions.forge dnd-center-layout 'tabbed'
# gsettings set org.gnome.shell.extensions.forge float-always-on-top-enabled true
# gsettings set org.gnome.shell.extensions.forge focus-border-color 'rgba(236, 94, 94, 1)'
# gsettings set org.gnome.shell.extensions.forge focus-border-size 3
# gsettings set org.gnome.shell.extensions.forge focus-border-toggle true
# gsettings set org.gnome.shell.extensions.forge log-level 0
# gsettings set org.gnome.shell.extensions.forge logging-enabled false
# gsettings set org.gnome.shell.extensions.forge move-pointer-focus-enabled false
# gsettings set org.gnome.shell.extensions.forge preview-hint-enabled true
# gsettings set org.gnome.shell.extensions.forge primary-layout-mode 'tiling'
# gsettings set org.gnome.shell.extensions.forge quick-settings-enabled true
# gsettings set org.gnome.shell.extensions.forge resize-amount 15
# gsettings set org.gnome.shell.extensions.forge showtab-decoration-enabled true
# gsettings set org.gnome.shell.extensions.forge split-border-color 'rgba(255, 246, 108, 1)'
# gsettings set org.gnome.shell.extensions.forge split-border-toggle true
# gsettings set org.gnome.shell.extensions.forge stacked-tiling-mode-enabled true
# gsettings set org.gnome.shell.extensions.forge tabbed-tiling-mode-enabled true
# gsettings set org.gnome.shell.extensions.forge tiling-mode-enabled true
# gsettings set org.gnome.shell.extensions.forge window-gap-hidden-on-single false
# gsettings set org.gnome.shell.extensions.forge window-gap-size 4
# gsettings set org.gnome.shell.extensions.forge window-gap-size-increment 1
# gsettings set org.gnome.shell.extensions.forge workspace-skip-tile ''

# gsettings set org.gnome.shell.extensions.forge.keybindings con-split-horizontal "['<Super>z']"
# gsettings set org.gnome.shell.extensions.forge.keybindings con-split-layout-toggle "['<Super>g']"
# gsettings set org.gnome.shell.extensions.forge.keybindings con-split-vertical "['<Super>v']"
# gsettings set org.gnome.shell.extensions.forge.keybindings con-stacked-layout-toggle "['<Shift><Super>s']"
# gsettings set org.gnome.shell.extensions.forge.keybindings con-tabbed-layout-toggle "['<Shift><Super>t']"
# gsettings set org.gnome.shell.extensions.forge.keybindings con-tabbed-showtab-decoration-toggle "['<Ctrl><Alt>y']"
# gsettings set org.gnome.shell.extensions.forge.keybindings focus-border-toggle "['<Super>x']"
# gsettings set org.gnome.shell.extensions.forge.keybindings mod-mask-mouse-tile "None"
# gsettings set org.gnome.shell.extensions.forge.keybindings prefs-open "['<Super>Period']"
# gsettings set org.gnome.shell.extensions.forge.keybindings prefs-tiling-toggle "['<Super>w']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-down "['<Super>j']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-left "['<Super>h']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-right "['<Super>l']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-focus-up "['<Super>k']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-gap-size-decrease "['<Ctrl><Super>minus']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-gap-size-increase "['<Ctrl><Super>plus']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-down "['<Shift><Super>j']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-left "['<Shift><Super>h']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-right "['<Shift><Super>l']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-move-up "['<Shift><Super>k']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-bottom-decrease "['<Ctrl><Shift><Super>i']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-bottom-increase "['<Ctrl><Super>u']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-left-decrease "['<Ctrl><Shift><Super>o']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-left-increase "['<Ctrl><Super>y']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-right-decrease "['<Ctrl><Shift><Super>y']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-right-increase "['<Ctrl><Super>o']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-top-decrease "['<Ctrl><Shift><Super>u']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-resize-top-increase "['<Ctrl><Super>i']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-snap-center "['<Ctrl><Alt>c']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-snap-one-third-left "['<Ctrl><Alt>d']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-snap-one-third-right "['<Ctrl><Alt>g']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-snap-two-third-left "['<Ctrl><Alt>e']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-snap-two-third-right "['<Ctrl><Alt>t']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-down "['<Ctrl><Super>j']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-last-active "['<Super>Return']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-left "['<Ctrl><Super>h']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-right "['<Ctrl><Super>l']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-swap-up "['<Ctrl><Super>k']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-toggle-always-float "['<Shift><Super>c']"
# gsettings set org.gnome.shell.extensions.forge.keybindings window-toggle-float "['<Super>c']"
# gsettings set org.gnome.shell.extensions.forge.keybindings workspace-active-tile-toggle "['<Shift><Super>w']"

# gsettings list-recursively org.gnome.shell.extensions.burn-my-windows-profile
# gsettings list-recursively org.gnome.shell.extensions.burn-my-windows
