#!/bin/bash
# Custom grub theme

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Variables
theme="Cerydra"
grub="/etc/default/grub"
grub_dir="/boot/grub/themes"
grub_theme="$grub_dir/$theme/theme.txt"
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

# start script
note "Setting up grub theme."

# Check file
if [[ ! -f "$grub" ]]; then
    err "$grub does not exist. Skipping"
    exit 1
fi

# Check folder
if [[ ! -d "$grub_dir" ]]; then
    sudo mkdir -p "$grub_dir"
fi

# Ask user
if gum confirm "${CYAN}Do you want to install grub custom theme?${RESET}"; then

    if git clone https://github.com/voidlhf/StarRailGrubThemes.git --depth 1 "$temp_dir"; then
        ok "Cloned grub themes successfully"
    else
        err "Failed to clone grub themes directory"
        exit 1
    fi

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

    # Extract and copy theme
    sudo cp -r "$temp_dir/assets/themes/$theme" "$grub_dir/"

    # Detect OS
    if command -v os-prober >/dev/null; then
        sudo os-prober
    fi

    # Regenerate grub config
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    note "You chose not install grub theme. Skipping..."
fi
