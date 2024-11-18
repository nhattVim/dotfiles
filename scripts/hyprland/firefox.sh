#!/bin/bash
# Custom firefox

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
install_pacman_pkg firefox

firefox_prefs=$(find "$HOME/.mozilla/firefox" -maxdepth 1 -type d -name "*.default-*" -exec echo {}/prefs.js \;)
firefox_profile=$(find "$HOME/.mozilla/firefox" -maxdepth 1 -type d -name "*.default-*" -exec echo {}/ \;)

if grep -q "^.*toolkit.legacyUserProfileCustomizations.stylesheets.*" "$firefox_prefs"; then
	sudo sed -i "s|^.*toolkit.legacyUserProfileCustomizations.stylesheets.*|user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true);|" "$firefox_prefs"
	echo "${OK} Firefox customization already applied."
else
	echo "user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true);" | sudo tee -a "$firefox_prefs" >/dev/null
	echo "${OK} Added Firefox customization."
fi

if grep -q "^.*widget.gtk.ignore-bogus-leave-notify.*" "$firefox_prefs"; then
	sudo sed -i "s|^.*widget.gtk.ignore-bogus-leave-notify.*|user_pref(\"widget.gtk.ignore-bogus-leave-notify\", 1);|" "$firefox_prefs"
	echo "${OK} Firefox customization already applied."
else
	echo "user_pref(\"widget.gtk.ignore-bogus-leave-notify\", 1);" | sudo tee -a "$firefox_prefs" >/dev/null
	echo "${OK} Added Firefox customization."
fi

cd $HOME
if [ -d dotfiles ]; then
	cd dotfiles || {
		printf "%s - Failed to enter dotfiles config directory\n" "${ERROR}"
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

if cp -r assets/chrome $firefox_profile; then
	echo "${OK} Copy chrome files successfully."
fi
