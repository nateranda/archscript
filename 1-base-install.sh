#!/bin/bash

echo "##############"
echo "#BASE INSTALL#"
echo "##############"

# Import configure.conf file if it exists
if [ -e ~/archscript/config.conf ]; then source ~/archscript/config.conf; fi

# Sync system clock
timedatectl set-ntp true

# Load keymap if in conf file
if [ -v keymap ]; then loadkeys $keymap; fi

# Prompt for disk if not in conf file
if [ ! -v disk ]
then
    lsblk
    read -p "What disk do you want to install Arch on?: " disk
fi

# Prompt for confirmation to erase all data on drive
read -p "This will erase all data on $disk. Continue? [y/N]: " consent

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

# Select disk label type
if [ -e /sys/firmware/efi/efivars ]
then
    parted $disk mklabel gpt mkpart "EFI system partition" fat32 1MiB 512MiB set 1 esp on mkpart "root partition" ext4 512MiB 100%
    mount ${disk}2 /mnt
    mkdir /mnt/boot
    mount ${disk}1 /mnt/boot
else
    parted $disk mklabel mbr mkpart primary ext4 1MiB 100% set 1 boot on
    mount ${disk}1 /mnt
fi