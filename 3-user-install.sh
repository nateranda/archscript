#!/bin/bash

echo "##############"
echo "#USER INSTALL#"
echo "##############"

# Import config.conf file if it exists
source ~/config.conf

# Prompt for AUR helper if not in conf file
if [ ! -v aurhelper ]
then
    read -p "AUR Helper [paru/yay]: " aurhelper
    echo "aurhelper=$aurhelper" >> ~/config.conf
fi

# Install AUR helper & packages
cd ~
case $aurhelper in
    paru)
        sudo pacman -S base-devel git --autoconfirm --needed
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si
        paru -S $aurpackages --autoconfirm
        cd ~
        ;;
    yay)
        sudo pacman -S base-devel git --autoconfirm --needed
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        yay -S $aurpackages --autoconfirm
        cd ~
        ;;
    *)
        echo "Invalid/unsupported AUR helper choice. Skipping."
        sleep 5
esac

# Continue with DE/WM setup
case $desktop in
    gnome-additions)
        ;;