#!/bin/bash
# Custom grub theme

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# Variables
theme="Rappa"
grub="/etc/default/grub"
grub_dir="/boot/grub/themes"
grub_theme="$grub_dir/$theme/theme.txt"

# start script
printf "\n%.0s" {1..2}
note "Setting up grub theme."

# Check file
if [[ ! -f "$grub" ]]; then
    note "$grub does not exist. Skipping"
    exit 1
fi

# Check file
if [[ ! -d "$grub_dir" ]]; then
    sudo mkdir -p "$grub_dir"
fi

# Ask user
if gum confirm "Do you want to install grub custom theme?"; then
    cd $HOME
    if [ -d grub_themes ]; then
        rm -rf grub_themes || {
            err "Failed to remove old grub themes folder"
            exit 1
        }
        note "Clone grub themes." && git clone https://github.com/voidlhf/StarRailGrubThemes.git grub_themes --depth 1 || {
            err "Failed to clone grub themes directory"
            exit 1
        }
    else
        note "Clone grub themes." && git clone https://github.com/voidlhf/StarRailGrubThemes.git grub_themes --depth 1 || {
            err "Failed to clone grub themes directory"
            exit 1
        }
    fi

    printf "\n%.0s" {1..2}

    # Update GRUB_TIMEOUT
    sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=\"-1\"/" "$grub"
    sudo sed -i "s/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=\"hidden\"/" "$grub"
    ok "Disable grub timeouts in $grub"

    # # Check and diable SUBMENU
    # if grep -q "^.*GRUB_DISABLE_SUBMENU=" "$grub"; then
    # 	sudo sed -i "s|^.*GRUB_DISABLE_SUBMENU=.*|GRUB_DISABLE_SUBMENU=y|" "$grub"
    # 	echo "${GREEN} Disable submenu in $grub"
    # else
    # 	echo "GRUB_DISABLE_SUBMENU=y" | sudo tee -a "$grub" >/dev/null
    # 	echo "${GREEN} Added GRUB_DISABLE_SUBMENU to $grub"
    # fi

    # Check and update GRUB_THEME
    if grep -q "^.*GRUB_THEME=" "$grub"; then
        sudo sed -i "s|^.*GRUB_THEME=.*|GRUB_THEME=\"$grub_theme\"|" "$grub"
        ok "Updated grub themes in $grub"
    else
        echo "GRUB_THEME=\"$grub_theme\"" | sudo tee -a "$grub" >/dev/null
        ok "Added grub themes in $grub"
    fi

    # Check and update GRUB_DISABLE_OS_PROBER
    if grep -q "^.*GRUB_DISABLE_OS_PROBER=" "$grub"; then
        sudo sed -i "s|^.*GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|" "$grub"
        ok "Updated os-prober in $grub"
    else
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a "$grub" >/dev/null
        ok "Added to GRUB_DISABLE_OS_PROBER in $grub"
    fi

    printf "\n%.0s" {1..2}

    # Extract and copy theme
    tar xzvf grub_themes/themes/"$theme".tar.gz >/dev/null
    rm -fr grub_themes/themes/"$theme".tar.gz
    sudo mkdir -p $grub_dir
    sudo cp -r $theme $grub_dir
    rm -rf $theme
    rm -rf grub_themes

    # Regenerate grub config
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    note "You chose not install grub theme. Skipping..."
fi
