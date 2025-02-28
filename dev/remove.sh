#!/bin/bash

sudo pacman -Rns code
# yay -Rns visual-studio-code-bin
# yay -Rns vscodium-bin

rm -rf ~/.config/Code
rm -rf "$HOME/.config/Code - OSS"
rm -rf ~/.vscode
rm -rf ~/.cache/Code
rm -rf ~/.local/share/Code

sudo rm -rf /usr/lib/code
sudo rm -rf /usr/share/code

rm -rf ~/.vscode-oss
rm -rf ~/.config/VSCodium
rm -rf ~/.local/share/vscode-oss

sudo rm -rf /var/lib/code
