#!/bin/bash

. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

androids=(
    android-sdk-cmdline-tools-latest
    android-sdk-build-tools
    android-sdk-platform-tools
    android-platform
    android-emulator
)

note "Installing flutter packages..."
for pkg in "${androids[@]}"; do
    iAur "$pkg"
done

note "Installing flutter..."
iPac fvm
fvm install stable
fvm global stable

source /etc/profile

sudo groupadd android-sdk
sudo gpasswd -a $(whoami) android-sdk
sudo setfacl -R -m g:android-sdk:rwx /opt/android-sdk
sudo setfacl -d -m g:android-sdk:rwX /opt/android-sdk

sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "system-images;android-36;google_apis;x86_64" "emulator"
avdmanager create avd \
    --name "medium_phone_api36" \
    --package "system-images;android-34;google_apis;x86_64" \
    --device "medium_phone"

# sudo rm -rf /opt/android-sdk
# export ANDROID_HOME=$HOME/Android/Sdk
# export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
