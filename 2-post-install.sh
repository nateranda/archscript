#!/bin/bash

# If you're running these scripts manually, this should be run in chroot, AKA after arch-chroot.

echo "##############"
echo "#POST INSTALL#"
echo "##############"

# Import config.conf file if it exists
if [ -e /config.conf ]; then source /config.conf; fi

# Enable parallel downloads on machine
sed -i 's/^#Para/Para/' /etc/pacman.conf

# Prompt for timezone if not in conf file
if [ ! -v timezone ]; then read -p "Timezone (after /usr/share/zoneinfo/, ex. America/New_York): " timezone; fi

# Set timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime

# Generate adjtime
hwclock --systohc

# Prompt for locale if not in conf file
if [ ! -v locale ]; then read -p "Locale: " locale; fi

# Uncomment locale in locale.gen & generate locale
sed -i "/$locale/s/^#//" /etc/locale.gen
locale-gen

# Add locale to locale.conf
echo "LANG=$locale" >> /etc/locale.conf

# Prompt for hostname if not in conf file
if [ ! -v hostname ]; then read -p "Hostname: " hostname; fi

# Add hostname
echo $hostname >> /etc/hostname

# Prompt for bootloader if not in conf file
if [ ! -v bootloader ]; then read -p "Bootloader [grub]: " bootloader; fi

# Install bootloader
case $bootloader in
    grub)
        if [ -e /sys/firmware/efi/efivars ]
        then
            pacman -S grub efibootmgr os-prober dosfstools --noconfirm
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
            echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
        else
            pacman -S grub --noconfirm
            grub-install $disk
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
        ;;
    *)
        echo "invalid or unsupported bootloader"
        ;;
esac

# Set root password
passwd

# Prompt for username if not in conf file
if [ ! -v username ]; then read -p "Username: " username; fi

# Set up user
pacman -S sudo --noconfirm
useradd -m $username
passwd $username
usermod -aG wheel $username

# Add wheel to sudoers
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Install & enable essential internet tools
pacman -S networkmanager dhcpcd --noconfirm
systemctl enable dhcpcd
systemctl enable NetworkManager

# Prompt for desktop if not in conf file
if [ ! -v desktop ]; then read -p "Desktop Environment/Window Manager [none/gnome/gnome-additions]: " desktop; fi

# Download desktop environment or window manager
case $desktop in
    none)
        echo "Skipping DE/WM install."
        ;;
    gnome)
        # Install/enable gnome & bluez
        pacman -S xorg gnome bluez bluez-utils --noconfirm --needed
        systemctl enable bluetooth
        systemctl enable gdm
        ;;
    gnome-additions)
        # Install/enable gnome & bluez
        pacman -S xorg gnome gnome-tweaks bluez bluez-utils --noconfirm --needed
        systemctl enable bluetooth
        systemctl enable gdm

        # Remove GNOME bloat
        pacman -R gnome-books gnome-contacts gnome-maps gnome-music gnome-weather simple-scan --noconfirm

        # Tweak settings to my liking
        dconf write /org/gnome/desktop/peripherals/mouse/accel-profile flat
        dconf write /org/gnome/desktop/wm/preferences/button-layout appmenu:minimize,maximize,close
        dconf write /org/gnome/desktop/interface/clock-format 12h
        dconf write /org/gtk/settings/file-chooser/clock-format 12h
        ;;
    *)
        echo "Invalid DE/WM choice. Skipping install."
        ;;
esac

# Install other packages:
pacman -S $packages