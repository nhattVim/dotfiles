#!/bin/bash
# Thunar

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

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
note "Installing Thunar Packages..."
for THUNAR in "${thunar[@]}"; do
    iPac "$THUNAR"
    if [ $? -ne 0 ]; then
        err "$THUNAR install had failed"
    fi
done
