#!/bin/bash
# install pacman package

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
pacman_pkgs=(
	linux-lts
	linux-lts-headers
	base-devel
	git
	libxcrypt-compat
	alacritty
	tmux
	zsh
	nano
	vim
	make
	python-pip
	nodejs
	npm
	python-virtualenv
	ripgrep
	fzf
	neofetch
	lsd
	lazygit
	net-tools
	neovim
	bat
	libreoffice-fresh
	jdk-openjdk
	file-roller
	gnome-disk-utility
	discord
	neovide
	ranger
	aria2
	btop
	curl
	mpv
	mpv-mpris
	yt-dlp
	ffmpeg
	cmatrix
	telegram-desktop
	foot
	cargo
)

hypr_pkgs=(
	brightnessctl
	grim
	waybar
	gnome-system-monitor
	jq
	slurp
	swappy
	cliphist
	network-manager-applet
	pamixer
	pavucontrol
	pipewire-alsa
	playerctl
	polkit-gnome
	python-pywal
	qt5ct
	qt6ct
	swappy
	swayidle
	wget
	wl-clipboard
	xdg-user-dirs
	xdg-utils
	yad
	nvtop
	chromium
)

# Installation of main components
printf "\n%s - Installing components\n" "${NOTE}"
for PKG1 in "${pacman_pkgs[@]}" "${hypr_pkgs[@]}"; do
	install_pacman_pkg "$PKG1"
	if [ $? -ne 0 ]; then
		echo -e "${ERROR} - $PKG1 install had failed"
	fi
done
