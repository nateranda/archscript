#              _               _     _   
#  ___ ___ ___| |_ ___ ___ ___|_|___| |_ 
# | .'|  _|  _|   |_ -|  _|  _| | . |  _|
# |__,|_| |___|_|_|___|___|_| |_|  _|_|  
#  made by nate randa           |_|     

# A set of shell scripts that aim to provide a fast, customizable, and easy way
# to install Arch Linux. 

# In order for this script to be completely autonomous, it needs to be split up
# into parts:

# 1-base-install.sh (everything done before arch-chroot)
# 2-post-install.sh (everything performed in arch-chroot)
# 3-user-install.sh (everything performed as the main user)

# If you want to add anything, make sure you put it in the correct file so it
# doesn't get run by the wrong user or in the wrong place.

# Huge shoutout to Chris Titus Tech and his ArchTitus project - it inspired me
# to make my own scripts and served as a great starting place to build off of.
# -----------------------------------------------------------------------------


# Import configure.conf file if it exists
if [ -e ~/archscript/config.conf ]; then source ~/archscript/config.conf; fi

# Give execution privileges and run base-install
chmod +x 1-base-install.sh
./1-base-install.sh

# Copy file to /mnt, give execution privileges, and run post-install
cp 2-post-install.sh /mnt
chmod +x /mnt/2-post-install.sh
arch-chroot /mnt ~/archscript/2-post-install.sh