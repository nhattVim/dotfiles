#!/bin/bash
# Thunar

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
thunar=(
	thunar
	thunar-volman
	tumbler
	ffmpegthumbnailer
	thunar-archive-plugin
	file-roller
)

# install thunar
printf "${NOTE} Installing Thunar Packages...\n"
for THUNAR in "${thunar[@]}"; do
	install_pacman_pkg "$THUNAR"
	[ $? -ne 0 ] && {
		echo -e "\e[1A\e[K${ERROR} - $THUNAR install had failed"
	}
done
