#!/bin/bash

echo "##############"
echo "#BASE INSTALL#"
echo "##############"

# Import config.conf file if it exists
if [ -e ~/archscript/config.conf ]; then source ~/archscript/config.conf; fi

# Sync system clock
echo "Syncing system clock..."
timedatectl set-ntp true

# Load keymap if in conf file
if [ -v keymap ]
then
    echo "Loading keymap..."
    loadkeys $keymap
fi

# List disks
lsblk

# Prompt for disk if not in conf file
if [ ! -v disk ]
then
    read -p "What disk do you want to install Arch on?: " diskshort
    disk=/dev/$diskshort
    echo -e "\ndisk=$disk" >> ~/archscript/config.conf
fi

# Prompt for confirmation to erase all data on drive
read -p "This will erase all data on $disk. Continue? [y/n]: " consent

# Continue if yes
case $consent in
    y|Y|yes|YES)
        echo "Formatting $disk:"
        ;;    
    *)
        echo "Aborting..."
        exit
        ;;
esac

# Format disk
if [ -e /sys/firmware/efi/efivars ]
then
    echo "Formatting for EFI boot..."
    parted $disk mklabel gpt mkpart EFI_system_partition fat32 1MiB 512MiB set 1 esp on mkpart root_partition ext4 512MiB 100%
    mkfs.fat -F 32 ${disk}1
    mkfs.ext4 ${disk}2
    mount ${disk}2 /mnt
    mkdir /mnt/boot
    mount ${disk}1 /mnt/boot
else
    echo "Formatting for legacy boot..."
    parted $disk mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on
    mkfs.ext4 ${disk}1
    mount ${disk}1 /mnt
fi

# Enable parallel downloads
echo "Enabling parallel downloads..."
sed -i 's/^#Para/Para/' /etc/pacman.conf

# Install base, kernel, and firmware
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware

# Prompt for swap size if not in conf file
if [ ! -v swapsize ]
then
    read -p "How big should the swapfile be? (in megabytes): " swapsize
    echo -e "\nswapsize=$swapsize" >> ~/archscript/config.conf
fi

# Create swapfile, set permissions, & load swap
echo "Creating swapfile..."
dd if=/dev/zero of=/mnt/swapfile bs=1M count=$swapsize
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# Generate fstab file
echo "Generating fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab