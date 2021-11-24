#!/bin/bash

echo "##############"
echo "#POST INSTALL#"
echo "##############"

# Import config.conf file
source /config.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

# Enable parallel downloads on machine
sed -i 's/^#Para/Para/' /etc/pacman.conf

# Prompt for timezone if not in conf file
if [ ! -v timezone ];
then
    read -p "Timezone (after /usr/share/zoneinfo/, ex. America/New_York): " Timezone
    echo -e "\ntimezone=$timezone" >> /config.conf
fi

# Set timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime

# Generate adjtime
hwclock --systohc

# Prompt for locale if not in conf file
if [ ! -v locale ]
then
    read -p "Locale: " locale
    echo -e "\nlocale=$locale" >> /config.conf
fi

# Uncomment locale in locale.gen & generate locale
sed -i "/$locale/s/^#//" /etc/locale.gen
locale-gen

# Add locale to locale.conf
echo "LANG=$locale" >> /etc/locale.conf

# Prompt for hostname if not in conf file
if [ ! -v hostname ]
then
    read -p "Hostname: " hostname
    echo -e "\nhostname=$hostname" >> /config.conf
fi

# Add hostname
echo $hostname >> /etc/hostname

# Prompt for bootloader if not in conf file
if [ ! -v bootloader ]
then
    read -p "Bootloader [grub]: " bootloader
    echo -e "\nbootloader=$bootloader" >> /config.conf
fi

# Install bootloader
case $bootloader in
    grub)
        if [ -e /sys/firmware/efi/efivars ]
        then
            pacman -S grub efibootmgr os-prober dosfstools --noconfirm
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
            echo -e "\nGRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
        else
            pacman -S grub os-prober --noconfirm
            grub-install $disk
            echo -e "\nGRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
        ;;
    *)
        echo "invalid or unsupported bootloader. Aborting:"
        exit
        ;;
esac

# Set root password
echo "Set Root Password:"
passwd

# Prompt for username if not in conf file
if [ ! -v username ]
then
    read -p "Username: " username
    echo -e "\nusername=$username" >> /config.conf
fi

# Check processor type and install microcode (thanks CTT!)
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Set up user
pacman -S sudo --noconfirm
useradd -m $username
echo "Set user Password:"
passwd $username
usermod -aG wheel $username

# Add wheel to sudoers
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Install & enable essential internet tools
pacman -S networkmanager dhcpcd --noconfirm
systemctl enable dhcpcd
systemctl enable NetworkManager

# Prompt for desktop if not in conf file
if [ ! -v desktop ]
then
    read -p "Desktop Environment/Window Manager [none/gnome/gnome-additions]: " desktop
    echo -e "\ndesktop:$desktop" >> /config.conf
fi

# Download desktop environment or window manager
case $desktop in
    none)
        echo "Skipping DE/WM install."
        ;;
    gnome)
        # Install/enable gnome & bluez
        pacman -S xorg gnome bluez --noconfirm --needed
        systemctl enable bluetooth
        systemctl enable gdm
        ;;
    *)
        echo "Invalid DE/WM choice. Skipping install."
        sleep 5
        ;;
esac

# Install additions if specified
if [[ $(type -t ${desktop}_root_additions) == function ]]; then ${desktop}_root_additions; fi
if [[ $(type -t root_additions) == function ]]; then $root_additions; fi

# Install other packages:
if [ ! -v packages ]; then pacman -S $packages --noconfirm; fi