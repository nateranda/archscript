#!/bin/bash

echo "##############"
echo "#POST INSTALL#"
echo "##############"

# Import config.conf file
source /config.conf

#Enable multilib
echo "Enabling multilib..."
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

# Enable parallel downloads on machine
echo "Enabling parallel downloads again..."
sed -i 's/^#Para/Para/' /etc/pacman.conf

# Prompt for timezone if not in conf file
if [ ! -v timezone ];
then
    read -p "Timezone (after /usr/share/zoneinfo/, ex. America/New_York): " Timezone
    echo -e "\ntimezone=$timezone" >> /config.conf
fi

# Set timezone
echo "Setting the timezone..."
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime

# Generate adjtime
echo "Generating adjtime..."
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
echo "LANG=$locale" >> /etc/locale.conf

# Prompt for hostname if not in conf file
if [ ! -v hostname ]
then
    read -p "Hostname: " hostname
    echo -e "\nhostname=$hostname" >> /config.conf
fi

# Add hostname
echo "Setting hostname..."
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
            echo "Installing GRUB for EFI boot..."
            pacman -S grub efibootmgr os-prober dosfstools --noconfirm
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
            echo -e "\nGRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
        else
            echo "Installing GRUB for legacy boot..."
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
        echo "Installing Intel microcode..."
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
        echo "Installing AMD microcode..."
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Set up user
echo "Setting up user..."
pacman -S sudo --noconfirm
useradd -m $username
echo "Set user Password:"
passwd $username
usermod -aG wheel $username

# Add wheel to sudoers
sed -i 's/^# %wheel ALL=(ALL)/%wheel ALL=(ALL)/' /etc/sudoers

# Install & enable networkmanager
echo "Installing internet..."
pacman -S networkmanager --noconfirm
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
        echo "Installing GNOME..."
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
echo "Installing additions..."
if [[ $(type -t ${desktop}_root_additions) == function ]]; then ${desktop}_root_additions; fi
if [[ $(type -t root_additions) == function ]]; then $root_additions; fi

# Install other packages:
echo "Installing misc packages..."
if [ ! -v packages ]; then pacman -S $packages --noconfirm; fi

# Prompt to restart before running user-install
read -p echo "The post-install is done! The vanilla user-install script runs fine without restarting, but some commands really don't like chroot. Restart? [Y/n]" restart
case $restart in
    y|Y|yes|YES|'')
        echo "The system will now restart. Make sure to run '3-user-install.sh' located in your home directory to finish the install. Restarting in 10 seconds:"
        sleep 10
        reboot
    *)
        echo "Running 3-user-install.sh:"
        