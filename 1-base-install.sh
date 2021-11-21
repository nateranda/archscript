#!/bin/bash

# Sync system clock
timedatectl set-ntp true

# Load keymap if in conf file
if [ -v keymap ]; then loadkeys $keymap; fi

# Prompt for disk if not in conf file
if [ -v disk ]
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
