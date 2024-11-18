#!/bin/bash
# GTK Themes & ICONS and  Sourcing from a different Repo #

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
engine=(
	unzip
	gtk-engine-murrine
)

# installing engine needed for gtk themes
for PKG1 in "${engine[@]}"; do
	install_aur_pkg "$PKG1"
	if [ $? -ne 0 ]; then
		echo -e "\033[1A\033[K${ERROR} - $PKG1 install had failed"
	fi
done

# Check dotfiles
cd $HOME
if [ -d dotfiles ]; then
	cd dotfiles || {
		printf "%s - Failed to cd dotfiles directory\n" "${ERROR}"
		exit 1
	}
else
	printf "\n${NOTE} Clone dotfiles. " && git clone -b hyprland https://github.com/nhattruongNeoVim/dotfiles.git ~/dotfiles --depth 1 || {
		printf "%s - Failed to clone dotfiles \n" "${ERROR}"
		exit 1
	}
	cd dotfiles || {
		printf "%s - Failed to enter dotfiles directory\n" "${ERROR}"
		exit 1
	}
fi

# Copy gtk_themes file
printf "\n%.0s" {1..2}
printf "${NOTE} - Copying gtk themes file\n"

# copying icon
mkdir -p ~/.icons
cp -r assets/.icons/* ~/.icons/ && { echo "${OK} Copy icons completed!"; } || {
	echo "${ERROR} Failed to copy icons files"
}

# copying font
mkdir -p ~/.fonts
cp -r assets/.fonts/* ~/.fonts/ && { echo "${OK} Copy fonts completed!"; } || {
	echo "${ERROR} Failed to copy fonts files"
}

# copying theme
mkdir -p ~/.themes
cp -r assets/.themes/* ~/.themes && { echo "${OK} Copy themes completed!"; } || {
	echo "${ERROR} Failed to copy themes files"
}

# reload fonts
printf "\n%.0s" {1..2}
fc-cache -fv
