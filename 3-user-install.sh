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
        git clone https://aur.archlinux.org/paru.git
        cd paru
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
if [[ $(type -t ${desktop}_user_additions) == function ]]
then
    ${desktop}_user_additions
fi

# Continue with DE/WM setup
case $desktop in
    gnome-additions)
        # Install AUR packages
        $aurhelper -S chrome-gnome-shell nordic-darker-theme gnome-terminal-transparency --noconfirm

        # Install nord gnome terminal theme
        git clone https://github.com/arcticicestudio/nord-gnome-terminal.git ~/Downloads
        . ~/Downloads/nord-gnome-terminal/src/nord.sh
        rm -rf ~/Downloads/nord-gnome-terminal

        # Install extensions
        pip install --user gnome-extensions-cli
        echo -n "export PATH=/home/$username/.local/bin:$PATH" >> ~/.bashrc
        gnome-extensions-cli install 751 3193 1160 1112 615 --backend file
        ;;
    *)
        echo "Skipping."
esac