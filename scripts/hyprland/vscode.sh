#!/bin/bash
# Setup vscode

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

note "Choose your vscode version ..."
vscode=$(gum choose "code" "visual-studio-code-bin" "vscodium")

# Install vscode
case "$vscode" in
"code")
    note "Installing VSCode OSS..."
    iPac code
    ;;
"visual-studio-code-bin")
    note "Installing Visual Studio Code (bin)..."
    iAur visual-studio-code-bin
    ;;
"vscodium")
    note "Installing VSCodium..."
    iAur vscodium-bin
    ;;
esac

# Clone dotfiles
temp=$(mktemp -d)
git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$temp" || exit 1

# Detect vscode config directory
case "$vscode" in
"code") vscode_config="$HOME/.config/Code" ;;
"visual-studio-code-bin") vscode_config="$HOME/.config/Code - OSS" ;;
"vscodium") vscode_config="$HOME/.config/VSCodium" ;;
esac

# Create vscode config directory
mkdir -p "$vscode_config/User"

# Copy settings.json, keybindings.json from dotfiles
act "Copying VSCode settings..."
cp -f "$temp/assest/vscode/settings.json" "$vscode_config/User/settings.json"
cp -f "$temp/assest/vscode/keybindings.json" "$vscode_config/User/keybindings.json"

# Install extensions
act "Installing extensions..."
while read -r extension; do
    "$vscode" --install-extension "$extension"
done <"$temp/assest/vscode/extension.txt"

# Done
ok "VSCode setup completed successfully!"
