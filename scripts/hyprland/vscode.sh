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
    if [ $? -ne 0 ]; then
        exit 1
    fi
    ;;
"visual-studio-code-bin")
    note "Installing Visual Studio Code (bin)..."
    iAur visual-studio-code-bin
    if [ $? -ne 0 ]; then
        exit 1
    fi
    ;;
"vscodium")
    note "Installing VSCodium..."
    iAur vscodium-bin
    if [ $? -ne 0 ]; then
        exit 1
    fi
    ;;
esac

# Clone dotfiles
temp=$(mktemp -d)
git clone https://github.com/nhattVim/dotfiles.git --depth 1 "$temp" || exit 1

# Detect vscode config directory
case "$vscode" in
    "code") vscode_config="$HOME/.config/Code - OSS" ;;
"visual-studio-code-bin") vscode_config="$HOME/.config/Code" ;;
"vscodium") vscode_config="$HOME/.config/VSCodium" ;;
esac

# Create vscode config directory
mkdir -p "$vscode_config/User"

# Copy settings.json, keybindings.json from dotfiles
act "Copying VSCode settings..."
cp -f "$temp/assets/vscode/settings.json" "$vscode_config/User/settings.json"
cp -f "$temp/assets/vscode/keybindings.json" "$vscode_config/User/keybindings.json"

# Install extensions
act "Installing extensions..."
while read -r extension; do
    "$vscode" --install-extension "$extension"
done <"$temp/assets/vscode/extensions.txt"

cat "$temp/assets/vscode/extensions.txt" | xargs -I {} code --install-extension {}

# Set ownership
case "$vscode" in
"code") sudo chown -R $(whoami) '/usr/lib/code' ;;
"visual-studio-code-bin") ;;
"vscodium") ;;
esac

# Done
ok "VSCode setup completed successfully!"
