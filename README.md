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

Once you have booted off of the DVD/USB drive, install git with `pacman`:

```shell
pacman -Sy git
```

Then, clone the Archscript Github repo, give permissions, and run the script:

```shell
git clone https://github.com/nateranda/archscript
cd archscript
chmod +x install.sh
./install.sh
```

## Configuration

Almost every option in this script can be specified beforehand using a config file. Just create a config file called `config.conf` and put it in the same folder as the scripts. It will be detected and used automatically. If you choose not to use a config file, you will find an automatically-generated one in your user's home directory after you are finished installing.

NOTE: Because it feels weird to store passwords on the system in plaintext and I can't be bothered to encrypt them myself, passwords can't be specified using the conf file. Thankfully, they're asked only a couple minutes into the install process.

### Base Configs

*If a config takes specific options, they will be shown beside it in brackets.*

`disk` - specify what disk you want to install Arch on. I don't recommend using this except for testing purposes.

`swapsize` - swapfile size in megabytes. Modern computers don't need more than a few gigabytes, if any at all.

`timezone` - the timezone you're located in. Put down whatever comes after /usr/share/zoneinfo/ — for me, it's America/New_York.

`hostname` - the hostname of the machine.

`username` - the username of the main user.

`locale` - your locale. Put down whatever you put in /etc/locale.conf.

`keymap` - your keymap. Defaults to US if left blank because there's not really a good way to display all useful keymaps at once.

`bootloader [grub]` - the bootloader you want to use. Make sure the bootloader you choose matches your boot method, AKA don't use rEFInd on BIOS machines.

`desktop [none, gnome]` - your desired Desktop Environment/Window Manager.

`aurhelper [paru, yay]` - your desired Arch User Repository helper.

### Extra Packages

You can specify any other packages you want using the `packages` and `aurpackages` options. They should be surrounded in quotes and separated by spaces:

```shell
packages='firefox discord vlc'
aurpackages='spotify timeshift ulauncher'
```

### Desktop Additions

These functions are run after the Desktop Environment or Window Manager is installed. Honestly, you could put anything into here, but they are meant to let you further configure your DE/WM automatically. Anything meant to be run as root goes in `[DE/WM]_root_additions` and anything meant to be run as the main user goes in `[DE/WM]_user_additions`:

```shell
gnome_root_additions(){
    commands go here
}

gnome_user_additions(){
    commands go here
}
```

### Tips and Tricks

If you're testing your own config file, I've found it much easier to automate the whole process with a simple shell script with execution privileges that looks something like this:

```shell
git clone https://github.com/nateranda/archscript
cd archscript
chmod +x install.sh
mv config.example.conf config.conf
./install.sh
```

Then, in your virtual machine, save a snapshot right before you run the script. When you need to restart after a test, just go back to the snapshot and hit enter.