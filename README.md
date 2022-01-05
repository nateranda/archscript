# Archscript

A set of shell scripts that aim to provide a fast, customizable, and easy way to install Arch Linux.

**2.0 is in active development and isn't in a stable state yet. Use the main branch for regular use.**

## Overview

Although there are many automated Arch install scripts, they are either time-consuming or only tailored to a single user's preferences and hardware. I wanted to make a script that served as a baseline for other users to expand upon and customize to their liking, no matter their computer or workflow.

To make this script as easy to configure as possible, all customizations are done in a .conf file with built-in methods for inserting custom bash scripts. However, if you need to go into the scripts themselves to tweak something, I've tried to annotate the scripts as much as possible to help them make sense.

Archscript is NOT built for anyone installing Arch for the first time — you're much better off using a different script entirely or learning how to do it manually before using this script.

## Usage

First, burn the [Archiso image](https://archlinux.org/download/) onto a USB flash drive or DVD using your preferred disk utility. My favorites are [Rufus](https://rufus.ie/) for Windows and [Popsicle](https://github.com/pop-os/popsicle) for GNU/Linux. Alternatively, you could just copy the .iso file to your thumb drive using `cp`, being careful to select the right drive:

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

DO NOT put actual shell commands anywhere other than hooks — they will most likely break the install.

NOTE: Because it feels weird to store user & root passwords on the system in plaintext and I can't be bothered to encrypt them myself, passwords can't be specified using the conf file. Thankfully, they're asked only a couple minutes into the install process. This means no completely autonomous install for the forseeable future. Womp womp.

### Base Configs

*If a config takes specific options, they will be shown beside it in brackets.*

`disk` - specify what disk you want to install Arch on. Be careful with this! I suggest only using it for testing purposes on a VM.

`swapsize` - swapfile size in megabytes. Modern computers don't need more than a few gigabytes, if any.

`timezone` - the timezone you're located in. Put down whatever comes after /usr/share/zoneinfo/ — for me, it's America/New\_York.

`hostname` - the hostname of the machine.

`username` - the username of the main user.

`locale` - your locale. Put down whatever you put in /etc/locale.conf.

`keymap` - your keymap. Defaults to US if left blank because there's not really a good way to display all useful keymaps at once.

`bootloader [grub]` - the bootloader you want to use. Make sure it matches your boot method, e.g. don't use rEFInd on BIOS machines.

`desktop [none, gnome, budgie]` - your desired desktop environment or window manager.

`aurhelper [paru, yay]` - your desired Arch User Repository helper.

### Extra Packages

You can specify any other packages you want using the `packages` and `aurpackages` options. They should be surrounded in quotes and separated by spaces:

```shell
packages='firefox discord vlc'
aurpackages='spotify timeshift ulauncher'
```

### Hooks

Hooks are functions containing custom bash scripts that run at certain points in the install, meant to give users complete customization and control over the entire process. They aren't used at all in the base installation. To define a hook, create a standard bash function in your `.conf` file that ends in `_hook`. You are welcome to define others, but these are the ones built into the script:

`disk_hook` - used for custom disk partitioning.

`[desktop-name]_root_hook` - desktop-specific root hook. Used to configure settings specific to a certain Desktop Environment or Window Manager. Put the (supported) DE/WM's name before `_root_hook` and it'll only run when that DE/WM is chosen. For example, if you want to tweak some GNOME settings as root, create a function called `gnome_root_hook`.

`[desktop-name]_user_hook` - same as `[desktop-name]_root_hook`, but run as the main user.

`root_hook` - catch-all root hook. Holds custom scripts not specific to any desktop and is run as root. If you need to enable or configure packages, apply any patches, or tie down any loose ends, this is the best place.

`user_hook` - same as `root_hook`, but run as the main user.

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
