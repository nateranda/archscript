# Archscript

A set of shell scripts that aim to provide a fast, customizable, and easy way to install Arch Linux.

## Overview

Although there are many automated Arch install scripts, they are either time-consuming or only tailored to a single user's preferences and hardware. I wanted to make a script that served as a baseline for other users to expand upon and customize to their liking, no matter their computer or workflow.

To make this script as easy to configure as possible, all customizations are done in a .conf file. However, if you need to go into the scripts themselves to tweak something, I've tried to annotate the scripts as much as possible to help them make sense.

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

DO NOT put actual commands anywhere other than the additions functions — they will be run multiple times in different places otherwise.

NOTE: Because it feels weird to store passwords on the system in plaintext and I can't be bothered to encrypt them myself, passwords can't be specified using the conf file. Thankfully, they're asked only a couple minutes into the install process.

### Base Configs

*If a config takes specific options, they will be shown beside it in brackets.*

`disk` - specify what disk you want to install Arch on. I don't recommend using this except for testing purposes.

`swapsize` - swapfile size in megabytes. Modern computers don't need more than a few gigabytes, if any at all.

`timezone` - the timezone you're located in. Put down whatever comes after /usr/share/zoneinfo/ — for me, it's America/New\_York.

`hostname` - the hostname of the machine.

`username` - the username of the main user.

`locale` - your locale. Put down whatever you put in /etc/locale.conf.

`keymap` - your keymap. Defaults to US if left blank because there's not really a good way to display all useful keymaps at once.

`bootloader [grub]` - the bootloader you want to use. Make sure it matches your boot method, e.g. don't use rEFInd on BIOS machines.

`desktop [none, gnome]` - your desired desktop environment or window manager.

`aurhelper [paru, yay]` - your desired Arch User Repository helper.

### Extra Packages

You can specify any other packages you want using the `packages` and `aurpackages` options. They should be surrounded in quotes and separated by spaces:

```shell
packages='firefox discord vlc'
aurpackages='spotify timeshift ulauncher'
```

### Additions

These functions are run after the Desktop Environment or Window Manager is installed. They provide a way to further configure your system/desktop without having to change the scripts themselves. Commands run by root go in `root_additions` and commands run by the main user go in `user_additions`. For DE/WM-specific commands, add the name of the (supported) DE/WM before the function.

```shell
# Will only run if GNOME is selected
gnome_root_additions(){
    commands go here
}

# Same here, but as the main user
gnome_user_additions(){
    commands go here
}

# Will run every install
user_additions(){
    commands go here
}
```

### Tips and Tricks

If you're testing your own config file, I've found it much easier to automate the whole process with a simple shell script with execution privileges. Mine looks something like this:

```shell
git clone https://github.com/nateranda/archscript
cd archscript
chmod +x install.sh
mv config.example.conf config.conf
./install.sh
```

Then, in your virtual machine, save a snapshot right before you run the script. When you need to restart after a test, just go back to the snapshot and hit enter.
