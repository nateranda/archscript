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
        sudo pacman -S base-devel git --noconfirm --needed
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si
        paru -S $aurpackages --noconfirm
        cd ~
        ;;
    yay)
        sudo pacman -S base-devel git --noconfirm --needed
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        yay -S $aurpackages --noconfirm
        cd ~
        ;;
    *)
        echo "Invalid/unsupported AUR helper choice. Skipping."
        sleep 5
esac

# Continue with DE/WM setup
case $desktop in
    gnome-additions)
        # Install AUR packages
        paru -S chrome-gnome-shell nordic-darker-theme gnome-terminal-transparency --noconfirm

        # Install nord gnome terminal theme
        cd Downloads
        git clone https://github.com/arcticicestudio/nord-gnome-terminal.git
        cd nord-gnome-terminal/src
        ./nord.sh
        cd ~
        rm -rf Downloads/nord-gnome-terminal

        # Install extensions
        pip install --user gnome-extensions-cli
        echo "export PATH=/home/$username/.local/bin:$PATH" >> ~/.bashrc
        gnome-extensions-cli install 751 3193 1160 1112 --backend file
        ;;
    *)
        echo "Skipping."
esac