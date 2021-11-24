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
    echo -e "\naurhelper=$aurhelper" >> ~/config.conf
fi

# Install AUR helper & packages
cd ~
case $aurhelper in
    paru)
        sudo pacman -S base-devel git --noconfirm --needed
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin
        makepkg -si --noconfirm
        cd ~
        ;;
    yay)
        sudo pacman -S base-devel git --noconfirm --needed
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
        ;;
    *)
        echo "Invalid/unsupported AUR helper choice. Skipping."
        sleep 5
esac

# Install misc AUR packages
$aurhelper -S $aurpackages --noconfirm

# Install additions if specified
if [[ $(type -t ${desktop}_user_additions) == function ]]; then ${desktop}_user_additions; fi
if [[ $(type -t user_additions) == function ]]; then $user_additions; fi