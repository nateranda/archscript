#!/bin/bash

echo "##############"
echo "#POST INSTALL#"
echo "##############"

# Import config.conf file if it exists
if [ -e /config.conf ]; then source /config.conf; fi

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
if [ ! -v bootloader ]; then read -p "Bootloader (grub): " bootloader; fi

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
    *)
        echo "invalid or unsupported bootloader choice"
esac