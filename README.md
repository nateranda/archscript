# Archscript

A set of shell scripts that aim to provide a fast, customizable, and easy way to install Arch Linux.

## Overview

Although there are many automated Arch install scripts, they are mostly tailored to a single user's preferences on certain hardware. I wanted to make a script that served as a baseline for other users to expand upon and customize to their liking, no matter their computer or workflow.

To make this script as easy to configure as possible, the most common customizations like packages, desktop evironments, and bootloaders are done in a .conf file away from the rest of the heavy scripting. If you need to go into the scripts themselves to tweak something, I've tried to annotate the scripts as much as possible to help them make sense.

## Usage

First, burn the [Archiso image](https://archlinux.org/download/) onto a USB flash drive or DVD using your preferred disk utility. My favorites are [Rufus](https://rufus.ie/) for Windows and [Popsicle](https://github.com/pop-os/popsicle) for GNU/Linux. Alternatively, you could just copy the .iso file to your thumb drive with the `cp` command:

```shell
cp path/to/archlinux-version-x86_64.iso /your/drive
```

Once you have booted off of the DVD/USB drive, install github with `pacman`:

```shell
pacman -S github
```

Then, clone the Archscript Github repo, give permissions, and run the script:

```shell
git clone https://github.com/nateranda/archscript
cd archscript
chmod +x install.sh
./install.sh
```